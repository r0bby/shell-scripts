#!/usr/bin/ksh
echo "Disk         Status   ODM_Config     Running_Config"
for disk in `lspv | awk '{print $1}'`; do
        odm=`lsattr -El $disk | grep ^queue_depth | awk '{print $2}'`
        run=$(( 16#`echo scsidisk $disk | kdb | grep queue_depth | awk '{print $4}' | tr -d ';' | sed 's/0x//'` ))
        [ "$odm" = "$run" ] && status=OK || status="DIFF!"
        printf "%-12s %-8s %-14s %-14s\n"  $disk $status $odm $run
done