#!/bin/bash
# Author Locez
# Date 2017-01-28
# Update Date 2017/10/12

#脚本执行开始
startTime=`date +%s`

#脚本当前目录的父目录
BASE_DIR="$(cd "$(dirname "$0")";cd ..;pwd)"

# 发行版配置目录
CONFIG_PATH="${BASE_DIR}/config"

# 执行结果
export RESULT="${BASE_DIR}/result"

# PID进程
LOCK_FILE="/var/run/mirrors.pid"

# 存储路径
MIRRORS="/mirrors"

#脚本进程
PID=$$


#控制线程数
 THREAD_NUM=200

#管道名称
tmpfile=$$.fifo

#创建管道
mkfifo $tmpfile

#创建文件标示3
exec 3<>$tmpfile

#删除管道文件
rm $tmpfile

#并发线程创建相应的占位,并将占位信息写入管道
for ((i=1;i<=$THREAD_NUM;i++))
do
    echo >&3
done


if [ -f ${LOCK_FILE} ]; then
    echo "syncing"
    exit 1
else
    echo ${PID} > ${LOCK_FILE}
fi

#将同步开始时间写入同步结果文件
echo "start rsync at $(date +"%Y-%m-%d %H:%M:%S")" > ${RESULT}

Env_List=$(ls "${CONFIG_PATH}")


for distroENV in ${Env_List}
do
read -u3
{

        source  ${CONFIG_PATH}/${distroENV}
        if [ ! -f ${LOG_PATH} ]; then
            mkdir -p ${LOG_PATH}
        fi

          ${BASE_DIR}/scripts/rsync-script.sh 
        echo >&3        
}&
done
wait

stopTime=`date +%s`

echo "TIME:`expr $stopTime - $startTime`" >> {RESULT}
exec 3>&-                     
exec 3<&-   

rm -rf ${LOCK_FILE}
exit 0
