#!/usr/bin/ksh
#ver 0.1
LOGPATH=/logs/errpt
[ -d $LOGPATH ] || mkdir -p $LOGPATH
cd $LOGPATH

errpt -a > errpt.`date +"%Y%m%d"`.txt
bzip2 errpt.`date +"%Y%m%d"`.txt
errclear 0

