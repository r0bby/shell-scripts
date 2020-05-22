#!/usr/bin/ksh
#set -x

exec >> /logs/archive/archive.wily.log 2>&1

echo $(date)


DATE=$(date +"%Y-%m-")

COMPRESS=bzip2
LOG=/logs/archive/archive.wily.log
NUMKEEP=15
OBJRUNNING="*.log"
OBJPATH=/usr/IBM/WebSphere/AppServer/profiles/Custom01/wily/logs
KEEPPATH=/usr/IBM/WebSphere/AppServer/profiles/Custom01/wily/logs/latest
OBJTSM=*.bz2
OBJTSMPATH=/logs/tsm.archive/wily

############## rotazione a mano
cd $OBJPATH
DAY=$(date +"%Y-%m-%d")
for O in $OBJRUNNING
do
	echo "posso ruotare e comprimere $O"
	cp $O $O.$DAY && >$O && $COMPRESS $O.$DAY
done

##############
# tengo una copia dei log degli ultimi KEEP giorni
cd $OBJPATH
cp *.bz2  $KEEPPATH
rm *.bz2

# keep only latest NUMKEEP
for O in $OBJRUNNING
do
	ls -la $O | awk '{print $9}' | while read i;
	do
        	NUMOLDOBJ=$(( $( ls -ltr $KEEPPATH/$i.* | wc | awk '{print $1}') ))
        	if [ $NUMOLDOBJ -gt $NUMKEEP ]; then
                	MYHEAD=$(( $NUMOLDOBJ-$NUMKEEP ))
                	ls -ltr $KEEPPATH/$i.* | head -$MYHEAD | awk '{print $9}' | while read j;
                	do
                        	rm $j
                	done
        	fi
	done
done

##############
# sposto i log compressi nella directory dove li pesca il tsm
#
#echo "MOVING_LOGS_TO $OBJTSMPATH" >>$LOG
#cd $OBJPATH
#mv $OBJTSM $OBJTSMPATH
#
##############
# richiamo il tsm per archiviare i bz2
#
#echo "LAUCHING_DSMC_ARCHIVE: /usr/bin/dsmc archive $OBJTSMPATH/*.bz2 -deletefiles" >> $LOG
#
#for L in $OBJTSMPATH/*.bz2;
#do
#/usr/bin/dsmc archive $L -deletefiles >> $LOG
#done
