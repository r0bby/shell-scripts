#!/bin/bash

cd /var/log/audit_bash
if [ -e audit_bash.log ]
then
	cp audit_bash.log audit_bash.log.$(date +"%Y-%m-%d") && >audit_bash.log
	bzip2 audit_bash.log.$(date +"%Y-%m-%d")
	mv *.bz2 old/
fi
