#!/bin/ksh
#set -x

################################################
OBJ=wtmp
NUMKEEP=90
OBJPATH=/var/adm/
KEEPPATH=/logs/wtmp/
OBJCLEAN=wtmp.*
DAY=$(date +"%d-%m-%y")
COMPRESS=bzip2

# rotate wtmp file
#cd $OBJPATH
#cp $OBJ $OBJ.$DAY && >$OBJ && $COMPRESS $OBJ.$DAY

#mv $OBJCLEAN $KEEPPATH

# keep only latest NUMKEEP
#NUMOLDOBJ=$(( $( ls -ltr $KEEPPATH$OBJCLEAN | wc | awk '{print $1}') ))
#if [ $NUMOLDOBJ -gt $NUMKEEP ]; then
#        MYHEAD=$(( $NUMOLDOBJ-$NUMKEEP ))
#        ls -ltr $KEEPPATH$OBJCLEAN | head -$MYHEAD | awk '{print $9}' | while read i;
#        do
#                rm $i
#        done
#fi



################################################
OBJ=sulog
NUMKEEP=90
OBJPATH=/var/adm/
KEEPPATH=/logs/sulog/
OBJCLEAN=sulog.*
DAY=$(date +"%d-%m-%y")
COMPRESS=bzip2

# rotate wtmp file
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

################################################
OBJ=auth.log
NUMKEEP=90
OBJPATH=/var/adm/
KEEPPATH=/logs/auth/
OBJCLEAN=auth.*
DAY=$(date +"%d-%m-%y")
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
