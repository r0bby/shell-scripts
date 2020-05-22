#!/usr/bin/ksh
#set -x

LOG=/logs/archive/archive.IBMWebAS.log

######################################################################
# per ogni applicazione che non ruota i log autonomamente, procedo 
# manualmente alla rotazione (files di estensione *.log)
# N.B. aggiungere le applicazioni anche nella variabile APPS per
#      l'archivizione locale e il backup via TSM
#
#ROTATE="webi"
#
#for APP in $ROTATE; do
#        /public/scripts/rotate_single.ksh $APP "*.log"
#done
#
######################################################################

######################################################################
# per ogni applicazione che si comporta in modo standard nella
# generazione dei log lancio lo script standard

APPS="gtpos gtpos_A gtpos_B mnbatchposopen srhcpci ucamp"

echo -------------------------------------------------- >> $LOG
echo START_ARCHIVE_FOR_IBMWebAS_APPLICATIONS `date +"%Y%m%d %T"` >> $LOG

for APP in $APPS; do
	echo "/public/scripts/archive_logs.single.ksh $APP" >> $LOG
	/public/scripts/archive_logs.single.ksh $APP
done

echo END_ARCHIVE_FOR_IBMWebAS_APPLICATIONS   `date +"%Y%m%d %T"` >> $LOG
echo -------------------------------------------------- >> $LOG

######################################################################
