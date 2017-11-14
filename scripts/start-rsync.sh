#!/bin/bash
# Author Locez
# Date 2017-01-28

BASE_DIR="$(cd "$(dirname "$0")";cd ..;pwd)"

# 发行版配置目录
CONFIG_PATH="${BASE_DIR}/config"

# 执行结果
export RESULT="${BASE_DIR}/result"

# PID进程
LOCK_FILE="/var/run/mirrors.pid"

# 存储路径
MIRRORS="/mirrors/mirrors"


PID=$$

if [ -f ${LOCK_FILE} ]; then
    echo "syncing"
    exit 1
else
    echo ${PID} > ${LOCK_FILE}
fi

echo "start rsync at $(date +"%Y-%m-%d %H:%M:%S")" > ${RESULT}

Env_List=$(ls "${CONFIG_PATH}")
for distroENV in ${Env_List}
do
    source  ${CONFIG_PATH}/${distroENV}
    if [ ! -f ${LOG_PATH} ]; then
        mkdir -p ${LOG_PATH}
    fi
    ${BASE_DIR}/scripts/rsync-script.sh &
done
wait
rm -rf ${LOCK_FILE}
exit 0
