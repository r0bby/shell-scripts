#!/bin/ksh
#set -x

################################################
OBJ=wtmp
NUMKEEP=90
OBJPATH=/var/adm/
LOGPATH=/logs/wtmp/
OBJCLEAN=wtmp.*
DAY=$(date +"%d-%m-%y")
COMPRESS=bzip2

# rotate wtmp file
[ -d $LOGPATH ] || mkdir -p $LOGPATH
cd $LOGPATH
/usr/sbin/acct/fwtmp < /var/adm/wtmp > $OBJ.$DAY && $COMPRESS $OBJ.$DAY && >/var/adm/wtmp && mv $OBJ.$DAY.bz2 $LOGPATH

