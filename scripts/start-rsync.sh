#!/bin/bash
# Author Locez
# Date 2017-01-28
# Update 2018-4-7

BASE_DIR="$(cd "$(dirname "$0")";cd ..;pwd)"

# 发行版配置目录
CONFIG_PATH="${BASE_DIR}/config"

# PID进程
LOCK_FILE="/var/run/mirrors.pid"

# 存储路径
MIRRORS="/mirrors"

# 日志路径
LOG_PATH="${BASE_DIR}/logs"

# 执行结果
export RESULT="${MIRRORS}/result"

# 进程数目
THREAD_NUM=5

PID=$$

# 创建管道文件
MIRRORS_FIFO=${PID}.fifo

mkfifo ${MIRRORS_FIFO}
exec 7<>${MIRRORS_FIFO}
rm -rf ${MIRRORS_FIFO}

for((i=1; i<=${THREAD_NUM}; i++));
do
    echo >&7
done

if [ -f ${LOCK_FILE} ]; then
    echo "syncing"
    exit 1
else
    echo ${PID} > ${LOCK_FILE}
fi

if [ ! -f ${LOG_PATH} ]; then
    mkdir -p ${LOG_PATH}
fi

echo "start rsync at $(date +"%Y-%m-%d %H:%M:%S")" > ${RESULT}

Env_List=$(ls "${CONFIG_PATH}")
for distroENV in ${Env_List}
do
    read -u7
   {
        source  ${CONFIG_PATH}/${distroENV}
        ${BASE_DIR}/scripts/rsync-script.sh
        echo >&7
    }&
done
wait

exec 7>&-
exec 7<&-
rm -rf ${LOCK_FILE}
exit 0
