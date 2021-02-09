#!/bin/bash
# creazione FS per istanze DW e DM

for X in w m
do
        for N in 0 1 2 3 4 5 6
        do
        /usr/sbin/mklv -y db2lgd${X}node${N} -t jfs2 -x 16384 d${X}11vg 40
        /usr/sbin/crfs -v jfs2 -d db2lgd${X}node${N} -m /db2plog/pdhah${X}/NODE000${N} -A yes -p rw -a agblksize=4096 -a logname=loglvd${X}11 -a isnapshot=no
        done
        for N in 0 1 2 3 4 5 6
        do
        /usr/sbin/mklv -y db2pad${X}node${N} -t jfs2 -x 16384 d${X}11vg 40
        /usr/sbin/crfs -v jfs2 -d db2pad${X}node${N} -m /db2path/pdhah${X}/NODE000${N} -A yes -p rw -a agblksize=4096 -a logname=loglvd${X}11 -a isnapshot=no
        done
        for N in 0 1 2 3 4 5 6
        do
        /usr/sbin/mklv -y db2fsd${X}node${N} -t jfs2 -x 16384 d${X}11vg 40
        /usr/sbin/crfs -v jfs2 -d db2fsd${X}node${N} -m /db2fs/pdhah${X}/NODE000${N} -A yes -p rw -a agblksize=4096 -a logname=loglvd${X}11 -a isnapshot=no
        done
done
