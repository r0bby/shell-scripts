#!/usr/bin/ksh
#set -x
#2016-03-22
#Aggiunto controllo per esistenza delle directories 
# /logs/archive
# /var/adm/latest

umask 027

[ -d /logs/archive ] || mkdir -p /logs/archive
[ -d /var/adm/latest ] || mkdir -p /var/adm/latest
exec >> /logs/archive/archive.var.log 2>&1

echo "\n---------------------------------- $(date) ----------------------------------------"

COMPRESS=bzip2
NUMKEEP=90
OBJRUNNING="auth.log sulog wtmp daemon.log"
OBJ="auth.log.* sulog.* wtmp.* daemon.log.*"
OBJPATH=/var/adm
KEEPPATH=/var/adm/latest

# Variabili necessarie per inviare i file alla log01lnx
CLIENT=$(uname -n)
export SENDEMAIL="/public/scripts/sendEmail"
export SCP="/usr/bin/scp"
STATO="OK"
export OGGI="`date +"%Y%m%d"`"
logserver="logbch@log01lnx"
keylogserver=/.ssh/id_rsa_log01lnx
portserver=22022
path_log_server="/netapp/archiviazione_log/${CLIENT}/logs/var/adm"
mailserver="mail.csebo.it"




cd $OBJPATH

echo "Ci sono file da ruotare?"
ls -la $OBJRUNNING | grep -v wtmp | while read i
do FILE=$(echo $i| awk '{print $9}')
   echo "Ruoto il file $FILE"
   DATA="`date +"%Y-%m-%d"`"
   cp $FILE $FILE.$DATA && > $FILE
   echo "Ruotato il file $FILE"
done

ls -la $OBJRUNNING | grep wtmp | while read i
do FILE=$(echo $i| awk '{print $9}')
   echo "Ruoto il file $FILE"
   DATA="`date +"%Y-%m-%d"`"
   /usr/sbin/acct/fwtmp < $FILE > $FILE.$DATA && > $FILE
#   cp $FILE $FILE.$DATA && > $FILE
   echo "Ruotato il file $FILE"
done

echo "Ci sono dei file da archiviare?"
echo "$(ls $OBJ)"
NUMFILE=$(ls $OBJ 2>/dev/null | wc -l)
echo "Ci sono $NUMFILE file da archiviare"


if [ $NUMFILE -gt 0 ]
then ls -la $OBJ | grep -v bz2$ | while read i
     do FILE=$(echo $i| awk '{print $9}')
        echo "Posso comprimere il file $FILE"
        cat $FILE|$COMPRESS > $FILE.bz2
        rm $FILE
        chmod 664 $FILE.bz2

        echo  "Invio il file $FILE.bz2"
        echo  "${SCP} -i $keylogserver -P $portserver $FILE.bz2 $logserver:$path_log_server"
        ${SCP} -i $keylogserver -P $portserver $FILE.bz2 $logserver:$path_log_server
        if [ $? -ne 0 ]
        then STATO="KO"
             echo "Problema sulla copia via scp"
        fi

        if [ $STATO == "KO" ]
        then echo "$STATO invio scp"
             ${SENDEMAIL} -f "${CLIENT} <${CLIENT}@csebo.it>"                         \
                          -t "sisunix@csebo.it"                                       \
                          -u "Problema archiviazione log"                             \
                          -s "$mailserver"                                            \
#                          -a "/logs/archive/archive.$APPLICATION.log"                       \
                          -m "Fallito l'invio dei var log. Verificare la causa"

             if [ $? -ne 0 ]
             then echo "$? Problema con l'invio della mail"
             fi
       fi
     done

     echo "Tengo una copia dei log degli ultimi $NUMKEEP giorni in $KEEPPATH"
     cd $OBJPATH
     cp *.bz2 $KEEPPATH
     rm *.bz2

     ls -la $OBJRUNNING | awk '{print $9}' | while read i
     do NUMOLDOBJ=$(( $( ls -ltr $KEEPPATH/$i.* | wc | awk '{print $1}') ))
        if [ $NUMOLDOBJ -gt $NUMKEEP ]
        then MYHEAD=$(( $NUMOLDOBJ-$NUMKEEP ))
             ls -ltr $KEEPPATH/$i.* | head -$MYHEAD | awk '{print $9}' | while read j
             do rm $j
             done
        fi
     done

else echo "Non ci sono file da archiviare"
fi

