
#!/bin/bash
#Author Locez
#date 2017-01-28

BASE_DIR="$(cd "$(dirname "$0")";cd ..;pwd)"

#发行版配置目录
CONFIG_PATH="${BASE_DIR}/config"

#执行结果
export RESULT="${BASE_DIR}/result"

#PID进程
LOCK_FILE="/var/run/mirrors.pid"

#存储路径
MIRRORS="/mirrors"


PID=$$

if [ -f $LOCK_FILE ]; then
    pid=`/bin/cat $LOCK_FILE`
    ppid=`/bin/ps -ef|grep -v grep|grep $pid|wc -l`
    if [ $ppid -eq 0 ] ; then
        echo $PID>$LOCK_FILE
    else
        echo "syncing"       
        exit 1
    fi
else
    echo $PID>$LOCK_FILE
fi

echo "start rsync at $(date +"%Y-%m-%d %H:%M:%S")" > $RESULT

Env_List=$(cd "${CONFIG_PATH}";ls)
for distroENV in ${Env_List}
do
    source  ${CONFIG_PATH}/${distroENV}
    if [ ! -f $LOG_PATH ]; then
        mkdir -p $LOG_PATH
    fi
    ${BASE_DIR}/scripts/rsync_script.sh&
done
wait
rm -rf $LOCK_FILE
exit 0
