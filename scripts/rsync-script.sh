#!/bin/bash

# called by start-rsync.sh

echo "Rsync starts at $(date +"%Y-%m-%d %H:%M:%S")" > ${LOG_FILE}
echo "[${UP_STREAM}]" >> ${LOG_FILE}
printf "%-10s \t Synchronizing       %s \n" ${DISTRO} ${UP_STREAM} >> ${RESULT}
echo "--------------------------------------------------" >> ${LOG_FILE}
rsync -avrtH --delete ${UP_STREAM} $LOCAL_PATH >> ${LOG_FILE}
echo "--------------------------------------------------" >> ${LOG_FILE}
sed -i "s/\(${DISTRO}[ \t]*\)Synchronizing/\1Synchronized - $(date +"%Y-%m-%d %H:%M:%S")/g" ${RESULT}
exit 0
