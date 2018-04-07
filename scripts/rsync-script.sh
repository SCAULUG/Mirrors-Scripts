#!/bin/bash

# called by start-rsync.sh

# 最大尝试次数
MAX_RETRIES=5

# 当前同步次数
sync_times=0

echo "Rsync starts at $(date +"%Y-%m-%d %H:%M:%S")" > ${LOG_FILE}
printf "<p id=\"%s\">Synchronizing</p>\n" ${DISTRO} >> ${RESULT}
echo "--------------------------------------------------" >> ${LOG_FILE}

rsync -avrtH --progress --delay-updates --delete-after --timeout=${TIME_OUT} ${UP_STREAM} ${LOCAL_PATH} >> ${LOG_FILE} 2>&1
while [ $? -ne 0 -a $i -lt $MAX_RETRIES ]
do
  echo "Retrying ${sync_times} times" >> ${LOG_FILE}
  rsync -avrtH --progress --delay-updates --delete-after --timeout=${TIME_OUT} ${UP_STREAM} ${LOCAL_PATH} >> ${LOG_FILE} 2>&1
done

if [ $sync_times -eq $MAX_RETRIES ]
then
  echo "Hit maximum number of retries, giving up" >> ${LOG_FILE}
  sed -i "s/\(${DISTRO}.*\)Synchronizing/\1Synchroniz failure - $(date +"%Y-%m-%d %H:%M:%S")/g" ${RESULT}
  exit 1
fi

echo "--------------------------------------------------" >> ${LOG_FILE}
sed -i "s/\(${DISTRO}.*\)Synchronizing/\1Synchronized - $(date +"%Y-%m-%d %H:%M:%S")/g" ${RESULT}
exit 0
