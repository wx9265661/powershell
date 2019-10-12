#!/bin/bash

#停止业务进程
pid=`ps -ef | grep $(cat service) | grep -v grep | awk '{print $2}'`
for p in $pid
do
    kill -9 $p
done


#备份被保护文件
path=$(cat path)
tar -czvf "${path}bak.tar.gz" $path

#安装SE
rpm -ivh /software/*.rpm

#手动激活
QDocSEConsole -c view 
read -p "激活SE后，按任意键继续！" 



#配置保护及授权
program=$(cat program)
QDocSEConsole -c protect -d $path -e no
QDocSEConsole -c adjust -apf $program

#降权
QDocSEConsole -c finalize

#启动业务进程
sh $program

