#!/usr/bin/ksh93
################################################################
function usagemsg_vscsiPriority {
  print "
Program: vscsiPriority

Description: Script to assign priorty to vscsi paths
based on even/odd numbers associated with each disk
and each path to disk.

This script is useful in a Virtualized environment
utilizing dual VIO servers with MPIO on the client LPAR's.
This script provides the system admin with the ability
to manually load balance SAN traffic from client LPAR's
between dual VIO servers.

Usage: ${1##*/} [-?vV] [-s] [-r] [-o] [-i #]
  Where:

    -v = Verbose mode
    -V = Very Verbose Mode
    -s = Show commands being run
    -r = Reverse the priority values
  -i # = Health check interval value (integer)
    -o = ODM change only for health check interval

Author: Dana French (dfrench@mtxia.com) Copyright 2005
\"AutoContent\" enabled
"
}
################################################################
function vscsiPriority {
  typeset TRUE="0"
  typeset FALSE="1"
  typeset VERBOSE="${FALSE}"
  typeset VERYVERB="${FALSE}"
  typeset SHOWCMD="${FALSE}"
  typeset REVERSE="${FALSE}"
  typeset ODM=""
  typeset HCHECK="20"
  typeset -r EVEN="02468acegikmoqsuwy"
  typeset -r ODD="13579bdfhjlnprtvxz"

  while getopts ":vVrsoi#" OPTION
  do
    case "${OPTION}" in
        'v')   VERBOSE="${TRUE}"
               SHOWCMD="${TRUE}";;
        'V')   VERYVERB="${TRUE}";;
        's')   SHOWCMD="${TRUE}";;
        'r')   REVERSE="${TRUE}";;
        'o')   ODM="-P";;
        'i')   HCHECK="${OPTARG}";;
        '?')   usagemsg_vscsiPriority "${0}" && exit 1;;
        ':')   usagemsg_vscsiPriority "${0}" && exit 1;;
    esac
  done
 
  shift $(( ${OPTIND} - 1 ))

################################################################
  trap "usagemsg_vscsiPriority ${0}" EXIT

  trap "-" EXIT

  (( VERYVERB == TRUE )) && set -x

################################################################
# Extract the short hostname value and remove any suffixes following a
# dash or underscore.

typeset -l HNAME=$( hostname )
HNAME="${HNAME%%.*}"
HNAME="${HNAME%%[_-]*}"
(( VERBOSE == TRUE )) && print -- "# Hostname: ${HNAME}"

# Define the numeric priority values of ONE and TWO.  Allow user to
# reverse these values by using the "-r"  command line option.

ONE="1"    TWO="2"
(( REVERSE == TRUE )) && ONE="2"    TWO="1"

# Define the priority levels for highest and lowest priority based on
# whether the last digit of the hostname is  an even or odd number.  

P1="${ONE}"    P2="${TWO}"
[[ "_${HNAME}" == _*[${ODD}] ]] && P1="${TWO}"  P2="${ONE}"

# Loop through each disk, setting the health check interval and priority
# value.

for DISK in $( lsdev -Cc disk -F name )
do

  (( SHOWCMD == TRUE )) && print -n "chdev -l ${DISK} -a hcheck_interval=${HCHECK} ${ODM} # "
  /usr/sbin/chdev -l ${DISK} -a hcheck_interval=${HCHECK} ${ODM}
  (( VERBOSE == TRUE )) &&
      print -n "# " &&
      /usr/sbin/lsattr -El ${DISK} -a hcheck_interval

  case ${DISK} in

# Even Numbered disks

      *[${EVEN}] ) /usr/sbin/lspath -l ${DISK} |
        while read -r -- JUNK1 JUNK2 VSCSI
        do

          case ${VSCSI} in

# Even disk + even path + even host = even  (P1=1, P2=2)
# Even disk + even path + odd  host = odd   (P1=2, P2=1)
# Even disk + odd  path + even host = even  (P1=1, P2=2)
# Even disk + odd  path + odd  host = odd   (P1=2, P2=1)

# odd  disk + even path + even host = even  (P1=1, P2=2)
# odd  disk + even path + odd  host = odd   (P1=2, P2=1)
# odd  disk + odd  path + even host = even  (P1=1, P2=2)
# odd  disk + odd  path + odd  host = odd   (P1=2, P2=1)


            *[${EVEN}] ) P1="${ONE}"    P2="${TWO}"
               [[ "_${HNAME}" == _*[${ODD}] ]] && P1="${TWO}"  P2="${ONE}"
               (( SHOWCMD == TRUE )) && 
               for C in $( lspath -l ${DISK} -p ${VSCSI} -F"connection" )
               do
                 print -n -- /usr/sbin/chpath -l ${DISK} -p ${VSCSI} -a priority=${P1} -w "${C}"
                 /usr/sbin/chpath -l ${DISK} -p ${VSCSI} -w "${C}" -a priority=${P1}
                 (( VERBOSE == TRUE )) &&
                   print -n "# " &&
                   /usr/sbin/lspath -AEl ${DISK} -p ${VSCSI} -w "${C}"
               done
               ;;

#     Odd numbered paths get lower priority for even numbered disks

            *[${ODD}] ) P1="${TWO}"    P2="${ONE}"
               [[ "_${HNAME}" == _*[${ODD}] ]] && P1="${ONE}"  P2="${TWO}"
               (( SHOWCMD == TRUE )) && 
               for C in $( lspath -l ${DISK} -p ${VSCSI} -F"connection" )
               do
                 print -n -- /usr/sbin/chpath -l ${DISK} -p ${VSCSI} -a priority=${P1} -w "${C}"
                 /usr/sbin/chpath -l ${DISK} -p ${VSCSI} -w "${C}" -a priority=${P1}
                 (( VERBOSE == TRUE )) &&
                   print -n "# " &&
                   /usr/sbin/lspath -AEl ${DISK} -p ${VSCSI} -w "${C}"
               done
               ;;
          esac
        done
        ;; 

# Odd Numbered disks

      *[${ODD}] ) /usr/sbin/lspath -l ${DISK} |
        while read -r -- JUNK1 JUNK2 VSCSI
        do
          case ${VSCSI} in

#     Even numbered paths get lower priority for odd numbered disks

            *[${EVEN}] ) P1="${TWO}"    P2="${ONE}"
               [[ "_${HNAME}" == _*[${ODD}] ]] && P1="${ONE}"  P2="${TWO}"
               (( SHOWCMD == TRUE )) && 
               for C in $( lspath -l ${DISK} -p ${VSCSI} -F"connection" )
               do
                 print -n -- /usr/sbin/chpath -l ${DISK} -p ${VSCSI} -a priority=${P1} -w "${C}"
                 /usr/sbin/chpath -l ${DISK} -p ${VSCSI} -w "${C}" -a priority=${P1}
                 (( VERBOSE == TRUE )) &&
                   print -n "# " &&
                   /usr/sbin/lspath -AEl ${DISK} -p ${VSCSI} -w "${C}"
               done
               ;;

#     Odd numbered paths get highest priority for odd numbered disks

            *[${ODD}] ) P1="${ONE}"    P2="${TWO}"
               [[ "_${HNAME}" == _*[${ODD}] ]] && P1="${TWO}"  P2="${ONE}"
               (( SHOWCMD == TRUE )) && 
               for C in $( lspath -l ${DISK} -p ${VSCSI} -F"connection" )
               do
                 print -n -- /usr/sbin/chpath -l ${DISK} -p ${VSCSI} -w "${C}" -a priority=${P1}
                 (( VERBOSE == TRUE )) &&
                   print -n "# " &&
                   /usr/sbin/lspath -AEl ${DISK} -p ${VSCSI} -w "${C}"
               done
               ;;
          esac
        done
        ;; 
  esac
done

}
################################################################

vscsiPriority "${@}"
