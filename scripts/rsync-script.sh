#!/bin/bash

# called by start-rsync.sh

printf "<p id=\"%s\">Synchronizing</p>\n" ${DISTRO} >> ${RESULT}
rsync -avrtH --delete ${UP_STREAM} $LOCAL_PATH >> ${LOG_FILE}
sed -i "s/\(${DISTRO}.*\)Synchronizing/\1Synchronized - $(date +"%Y-%m-%d %H:%M:%S")/g" ${RESULT}
exit 0
