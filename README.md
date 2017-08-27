# Mirrors-Scripts

Mirrors synchronization scripts

## 配置

 - 在config目录中添加需要同步的发行版配置文件
 - 修改 `./script/start-rsync.sh` 的变量配置

## 用法

```
./scripts/start-rsync.sh &
```

PS: `start-rsync.sh`将调起`rsync-script.sh`。

## 查询结果

同步结果默认存放在 `Mirrors-Scripts/result`。

```
cat result
```
