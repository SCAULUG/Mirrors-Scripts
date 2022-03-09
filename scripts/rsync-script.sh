#!/bin/bash

# called by start-rsync.sh

# 最大尝试次数
MAX_RETRIES=5

# 当前同步次数
sync_times=0

echo "Rsync starts at $(date +"%Y-%m-%d %H:%M:%S")" > ${LOG_FILE}
printf "<p id=\"%s\">Synchronizing</p>\n" ${DISTRO} >> ${RESULT}
echo "--------------------------------------------------" >> ${LOG_FILE}
# 保存同步信息到mirrorz.d.json
MIRRORZ_JSON="/mirrors/mirrorz.d.json"
TMP_JSON="tmp.$$.json"
if [[ $(grep -c '"cname":"'${DISTRO}'"' ${MIRRORZ_JSON}) -eq 0 ]]; then
    MIRRORS_STAT='{"cname":"'${DISTRO}'","url":"/'${DISTRO}'","status":"Y'$(date +%s)'","upstream":"'${UP_STREAM}'"}'
    jq -c ".mirrors |= . + [${MIRRORS_STAT}]" ${MIRRORZ_JSON} > ${TMP_JSON} && mv ${TMP_JSON} ${MIRRORZ_JSON}
fi
jq -c '(.mirrors[] | select(.cname == "'${DISTRO}'") | .status) |= "Y'$(date +%s)'"' ${MIRRORZ_JSON} > ${TMP_JSON} && mv ${TMP_JSON} ${MIRRORZ_JSON}

rsync -avrtH --progress --delay-updates --delete-after --timeout=${TIME_OUT} ${UP_STREAM} ${LOCAL_PATH} >> ${LOG_FILE} 2>&1
while [[ $? -ne 0 ]] && [[ ${sync_times} -lt ${MAX_RETRIES} ]]
do
  sync_times=$(($sync_times+1))
  echo "Retrying ${sync_times} times" >> ${LOG_FILE}
  rsync -avrtH --progress --delay-updates --delete-after --timeout=${TIME_OUT} ${UP_STREAM} ${LOCAL_PATH} >> ${LOG_FILE} 2>&1
done

if [[ $? -ne 0 ]] && [[ ${sync_times} -eq ${MAX_RETRIES} ]]
then
  echo "Hit maximum number of retries, giving up" >> ${LOG_FILE}
  sed -i "s/\(${DISTRO}.*\)Synchronizing/\1Synchroniz failure - $(date +"%Y-%m-%d %H:%M:%S")/g" ${RESULT}
  jq -c '(.mirrors[] | select(.cname == "'${DISTRO}'") | .status) |= "F'$(date +%s)'"' ${MIRRORZ_JSON} > ${TMP_JSON} && mv ${TMP_JSON} ${MIRRORZ_JSON}
  exit 1
fi

echo "--------------------------------------------------" >> ${LOG_FILE}
sed -i "s/\(${DISTRO}.*\)Synchronizing/\1Synchronized - $(date +"%Y-%m-%d %H:%M:%S")/g" ${RESULT}
jq -c '(.mirrors[] | select(.cname == "'${DISTRO}'") | .status) |= "S'$(date +%s)'"' ${MIRRORZ_JSON} > ${TMP_JSON} && mv ${TMP_JSON} ${MIRRORZ_JSON}
exit 0
