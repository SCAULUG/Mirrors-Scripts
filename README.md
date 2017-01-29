# Mirrors-Scripts
***
Mirrors synchronization scripts

###配置
***
 - 在config目录中添加需要同步的发行版配置文件
 - 修改 `./script/start-rsync.sh` 的变量配置

###使用
***
``` bash
./scripts/start-rsync.sh &
```

`rsync-script.sh` 由`start-rsync.sh` 调用。

###结果
***
结果存放在 `Mirrors-Script/result`。

查询结果
``` bash
cat result
```
