#!/usr/bin/ksh
# Reset a NIM client.
if [[ "$1" = "" ]] ; then
	echo Please specify a NIM client to reset e.g. LPAR4.

else

	if /usr/sbin/lsnim -l $1 > /dev/null 2>&1 ; then
		/usr/sbin/nim -o reset -F $1
		/usr/sbin/nim -Fo deallocate -a subclass=all $1
		/usr/sbin/nim -Fo change -a cpuid= $1
	else
			echo Not a valid NIM client!
	fi
fi
