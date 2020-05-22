umask 027                                                                                
#set -x
#2016-03-22
#Aggiunto controllo per esistenza delle directories
# /logs/nmon
# /logs/nmon/latest

[ -d /logs/nmon ] || mkdir -p /logs/nmon
[ -d /logs/nmon/latest ] || mkdir -p /logs/nmon/latest
exec >> /logs/nmon/nmon_logs.compress.log 2>&1

# Variabili necessarie per inviare i file alla log01lnx
CLIENT=$(uname -n)                                     
WORK_DIR=/logs/nmon                                    
export SENDEMAIL="/public/scripts/sendEmail"           
export SCP="/usr/bin/scp"                              
STATO="OK"
export OGGI="`date +"%Y%m%d"`"
logserver="logbch@log01lnx"
keylogserver=/.ssh/id_rsa_log01lnx
portserver=22022
path_log_server="/netapp/archiviazione_log/${CLIENT}/logs/nmon"
mailserver="mail.csebo.it"

cd $WORK_DIR

echo "\n---------------------------------- $OGGI ----------------------------------------"
echo "Ci sono dei file da inviare?"


NOMEFILE=$(ls ${CLIENT}* | grep -v ${OGGI})
echo $NOMEFILE

if [ -f "$WORK_DIR/$NOMEFILE" ]
then echo "Bizippo il file"

     bzip2 $NOMEFILE
     if [ $? -ne 0 ]
     then echo "Problema su bzip"
     fi

     echo  "Invio il file"
     ${SCP} -i $keylogserver -P $portserver $(ls ${CLIENT}* | grep -v ${OGGI}) $logserver:$path_log_server$i
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
                       -a "$WORK_DIR/nmon_logs.compress.log"                       \
                       -m "Fallito l'invio dei log il ${OGGI}. Verificare la causa"

          if [ $? -ne 0 ]
          then echo "$? Problema con l'invio della mail"
          fi
    fi

    echo "Sposto il file in latest"
    mv $(ls ${CLIENT}* | grep -v ${OGGI}) /logs/nmon/latest
else echo "Non ci sono file da inviare"
fi

