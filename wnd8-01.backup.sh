#!/usr/bin/ksh
set -x

for n in 1 2
do
for env in p u v
do  CLIENT="wnd8"$env"0"$n"vir-int"
#n=2
#env=p
#CLIENT="wnd8"$env"0"$n"vir-int"
echo $CLIENT

LOGPATH=/export/nim/logs/dr_wnd8
LOG=$LOGPATH/wnd8-01.$CLIENT.log
ERRLOG=$LOGPATH/wnd8-01.$CLIENT.err
>$LOG
>$ERRLOG
echo "Starting..." | tee -a $LOG

#Verifico nimsh sul nim client
nim -o lslpp $CLIENT  >/dev/null 2>&1
RC=`echo $?`
if [[ $RC -ne 0 ]];then
echo "Verificare NIMSH su $CLIENT" | tee -a $ERRLOG
continue
fi

#rimuovo le vecchie risorse
nim -Fo deallocate -a subclass=all $CLIENT
nim -Fo remove spot-$CLIENT
nim -Fo remove mksysb-$CLIENT
nim -Fo remove savevg-$CLIENT

#Definisco MKSYSB
nim -o define -t mksysb -a server=master -a location=/export/mksysb/mksysb-$CLIENT -a source=$CLIENT -a mk_image=yes -a exclude_files=wnd8-dr-exclude mksysb-$CLIENT | tee -a $LOG
listvgbackup -f /export/mksysb/mksysb-$CLIENT -r -d /download/DR/$CLIENT/ ./etc/ssh/*
listvgbackup -f /export/mksysb/mksysb-$CLIENT -r -d /download/DR/$CLIENT/ ./opt/ibm-ucd/agent/conf/*
listvgbackup -f /export/mksysb/mksysb-$CLIENT -r -d /download/DR/$CLIENT/ ./usr/java8_64/jre/lib/security/cacerts

#Definisco SAVEVG
if [[ $n -eq 1 ]];then
nim -o define -t savevg -a server=master -a location=/export/savevg/savevg-$CLIENT -a source=$CLIENT -a mk_image=yes -a savevg_flags=Xi -a volume_group=wsvg savevg-$CLIENT | tee -a $LOG
fi

done
done
