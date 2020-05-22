#!/bin/ksh 
# rel.0.1 - adattato per AIX
#set -x

# Variabili necessarie per eseguire lo script 
LOG=/tmp/archive_rscd_log.log 
TMP_DIR=/tmp/rscdlog 
CLIENT=$(uname -n)
WORK_DIR1=/opt/bmc/bladelogic/RSCD/Transactions/log/ 
WORK_DIR2=/opt/bmc/bladelogic/RSCD/log/ 
export MAIL="/public/scripts/smtp-cli" 
export SCP="/usr/bin/scp" 
STATO="OK" 
export OGGI="`/opt/freeware/bin/date +"%Y%m%d"`" 
export IERI="`/opt/freeware/bin/date --date='1 day ago' +"%Y%m%d"`" 
logserver="logbch@log01lnx" 
keylogserver=/.ssh/id_rsa_log01lnx 
portserver=22022 
path_log_server="/netapp/archiviazione_log/$CLIENT/logs/rscd" 
mailserver="mail.csebo.it" 

date >> $LOG 
if [ -d $WORK_DIR1 ] 
then 
       cd $WORK_DIR1 
       echo "Archivio log in $WORK_DIR1" >>$LOG 
       ls *.log >>$LOG 
       ${SCP} -i $keylogserver -P $portserver *.log $logserver:$path_log_server  >/dev/null 2>&1 
       if [ $? -ne 0 ]  
               then 
                       # PROBLEMA DI COPIA 
                       STATO="KO" 
                       echo "KO" >> $LOG 
       fi 
fi 
cd $WORK_DIR2 
echo "Archivio log in $WORK_DIR2" >>$LOG 
find . -mtime 1 >>$LOG 
find . -mtime 1 | xargs -I [] cp -p [] $TMP_DIR/[].$IERI 
if [ -z "$(ls -A $TMP_DIR)" ] 
then 
        echo "Non mi piaceva il !"
else
       ${SCP} -i $keylogserver -P $portserver $TMP_DIR/* $logserver:$path_log_server  >/dev/null 2>&1 
       if [ $? -ne 0 ] 
               then 
               # PROBLEMA DI COPIA 
               STATO="KO" 
               echo "KO" >> $LOG 
       fi 
fi 


 if [ $STATO == "KO" ]
        then echo "$STATO invio scp"
                ${MAIL} --server="$mailserver" --missing-modules-ok \
                        --from "${CLIENT} <${CLIENT}@csebo.it>" --to "sisunix@csebo.it" \
                       --to "sisunix@csebo.it"  \
                       --body-plain="Fallito l'invio dei log RSCD il ${OGGI}. Verificare la causa" \
                        --subject "Problema archiviazione log RSCD"                             


             if [ $? -ne 0 ]
             then echo "$? Problema con l'invio della mail"
             fi
       fi
#     done

echo  "-----HO FINITO DI COPIARE I LOG DEL ${IERI} ----- "   >> $LOG 

rm -f $TMP_DIR/*

