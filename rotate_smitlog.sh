#!/usr/bin/ksh
for x in log transaction script 
do
OBJ=smit.$x
NUMKEEP=90
OBJPATH=/
KEEPPATH=/logs/smitty/
OBJCLEAN=smit.$x
DAY=$(date +"%Y%m%d")
#DAY=$(date +"%d-%m-%y")
COMPRESS=bzip2

# rotate auth log  file
cd $OBJPATH
cp $OBJ $OBJ.$DAY && >$OBJ && $COMPRESS $OBJ.$DAY

# keep only latest NUMKEEP
NUMOLDOBJ=$(( $( ls -ltr $OBJPATH$OBJCLEAN | wc | awk '{print $1}') ))
if [ $NUMOLDOBJ -gt $NUMKEEP ]; then
        MYHEAD=$(( $NUMOLDOBJ-$NUMKEEP ))
        ls -ltr $OBJPATH$OBJCLEAN | head -$MYHEAD | awk '{print $9}' | while read i;
        do
                rm $i
        done
fi
mv $OBJ.$DAY.bz2  $KEEPPATH
done
