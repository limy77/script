执行lua需要先保证可以运行
shell执行命令 ： ./luaexec -i test.cfg，附件中所有文件与shell脚本与同一目录下执行
        其中配置文件test.cfg，内容如下：
 [common]
messageFile=$(OB_REL)/etc/msgFile.txt    先不修改，取决于执行主机的文件路径
luaFile=./sql.lua                         不需要修改
funcName=main                      不需要修改
paraNums=2                            不需要修改
#v8_db
parameter1=ad/ad@10.1.242.22:1520/bjbill       需要修改，为V8连接的数据库，格式:user/passwd@ip:port/alias
#v5_db
parameter2=ad/ad@10.1.242.22:1520/bjbill      需要修改，为V5连接的数据库，格式:user/passwd@ip:port/alias
[luaexec/log]
logFile=./log/sql_lua.log         不需要修改 
logLevel=INFO_LEVEL             日志级别，暂不需要修改
logOn=TRUE                          不需要修改 
consoleOn=TRUE                   不需要修改 
