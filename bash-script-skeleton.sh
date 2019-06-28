#!/bin/bash
#set -x
LOG=<LOGFILE>
SCRIPT=<SCRIPT_NAME>


ShowHelp() {
  echo "Errore: numero di parametri errato!"
  echo "Uso: $SCRIPT <STARTLUN> <ENDLUN>"
}


#Check sul numero dei parametri, se necessario
if [ $# -lt 2 ]
then
  ShowHelp
  exit 1
fi


