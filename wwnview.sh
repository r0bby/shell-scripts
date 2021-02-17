#!/usr/bin/ksh
for i in `lscfg -vp |grep fcs| awk '{print $1}'`
do
echo $i && lscfg -vp -l $i |grep 'Network Address'
done

