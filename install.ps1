$installation = Split-Path -Parent $MyInvocation.MyCommand.Definition
#配置文件
$conf_path = "$installation\conf.json"
$conf = (Get-Content -path $conf_path) | ConvertFrom-Json
Start-Process -filepath $conf.program