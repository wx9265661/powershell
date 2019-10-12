




#设置调试参数（输出调试信息，询问用户是否继续执行。）
$DebugPreference = "inquire"
#获取安装包路径
$installation = Split-Path -Parent $MyInvocation.MyCommand.Definition
#配置文件
$conf_path = "$installation\conf.json"
$a = Get-Content -path $conf_path
$conf = ConvertFrom-Json20 ($a)
#$conf = (Get-Content -path $conf_path) | ConvertFrom-Json
#停止业务服务
$service = $conf.service

Write-Output ("$service")