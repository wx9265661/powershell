#设置调试参数（输出调试信息，询问用户是否继续执行。）
$DebugPreference = "inquire"

#获取安装文件夹路径
$current_path = Split-Path -Parent $MyInvocation.MyCommand.Definition

#安装数据库
Start-Process $current_path\vcredist_x64-2013.exe  –Wait
#Write-output "VC安装完毕！"
Start-Process $current_path\NDP452-KB2901907-x86-x64-AllOS-ENU.exe  –Wait
#Write-output ".net安装完毕！"
Start-Process $current_path\mysql-installer-community-5.7.22.1.msi  –Wait
Write-Debug "等待MYSQL安装完成后继续执行！！！"

#修改my.ini
"default-time-zone=+00:00" | Out-File -Encoding utf8 -Append "C:\ProgramData\MySQL\MySQL Server 5.7\my.ini"

#重启mysql服务
restart-service -displayname *MySql*

#执行sql脚本
$mysql = "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe"
start-process $mysql -ArgumentList "-uroot -pBicdroid2019 -e ""source $current_path\create.sql"""  -RedirectStandardOutput $current_path\Out.Log -RedirectStandardError $current_path\Err.Log -Wait



#安装collector
Start-Process $current_path\QDocSEEventCollector.msi -ArgumentList "/qn" –Wait
$ip = (ipconfig|select-string "IPv4"|out-string).Split(":")[-1]
$ip2 = $ip.Trim(" .-`t`n`r")
$Collect = "C:\Program Files (x86)\BicDroid\QDocumentSE\QDocSEEventCollectServerSetup.exe"
Start-Process $Collect -ArgumentList "-ip $ip2 -p 8001 -dip localhost -dp 3306 -u qdocument -pw qdocument -n ccpbackenddb" -Wait

#安装java
Start-Process $current_path\jdk-8u221-windows-x64.exe –Wait

#拷贝jar及dist
New-Item -Path C:\ -Name csp -type directory
New-Item -Path C:\csp -Name java-work -type directory
Copy-Item $current_path\ccpbackend-webserver.jar -destination C:\csp\java-work
New-Item -Path C:\csp -Name web-work -type directory
Copy-Item $current_path\nginx-1.16.0 -destination C:\csp\web-work -Recurse
Copy-Item $current_path\dist -destination C:\csp\web-work -Recurse

#运行nginx及jar
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
cmd /c 'start javaw -jar C:\csp\java-work\ccpbackend-webserver.jar'
cd C:\csp\web-work\nginx-1.16.0
Start-Process .\nginx.exe
