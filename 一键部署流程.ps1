#低版本powershell无法使用convert-json命令，以下为该命令的替代

function ConvertTo-Json20([object] $item){
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer
    return $ps_js.Serialize($item)
}

function ConvertFrom-Json20([object] $item){ 
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer

    #The comma operator is the array construction operator in PowerShell
    return ,$ps_js.DeserializeObject($item)
}

#设置调试参数（输出调试信息，询问用户是否继续执行。）
$DebugPreference = "inquire"
#获取安装包路径
$installation = Split-Path -Parent $MyInvocation.MyCommand.Definition
#配置文件
$conf_path = "$installation\conf.json"
$conf_content = Get-Content -path $conf_path
$conf = ConvertFrom-Json20 ($conf_content)
#$conf = (Get-Content -path $conf_path) | ConvertFrom-Json
#停止业务服务
$service = $conf.service
try
{
  Get-Process -Name $service   | foreach-object{$_.Kill()}  -ErrorAction Stop
  Write-Output ("业务停止!")
}
catch
{
  Write-Debug "Error: $_"
}
#测试服务状态?

#备份需保护文件
$path = $conf.path
$path_bak = $path + '_bak.zip'
try
{
  Start-Process $installation\7z1900-extra\7za.exe -argumentlist "a -tzip $path_bak $path"  -Wait   -ErrorAction Stop
  Write-Output ("备份完成!")
}
catch
{
  Write-Debug "Error: $_"
}
#检测系统环境，安装.net
$net_exe = "$installation\dotNetFx40_Full_x86_x64.exe"
if (Test-Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client'){
    Write-Output (".net4.0已安装!")
} else {
    Start-Process $net_exe -Verb runAs -argumentlist "/q /norestart /ChainingPackage FullX64Bootstrapper"  -Wait 
    if ((get-wmiobject -class win32_product | where-object {$_.name -like '*.NET*'}) -ne $null){
        Write-Output ("安装完毕!(.net4.0)")
    }else {
        Write-Debug ("安装失败，请手动安装后继续执行!!!(.net4.0)")
    }
    
}
#安装更新
Start-Process wusa -Verb runAs -argumentlist "$installation\Windows6.1-KB3033929-x64.msu /qn"  -Wait 

#安装SE
Start-Process msiexec -Verb runAs -argumentlist "/i $installation\BicDroidQDocSE.msi /qb"  -Wait 
 
if ((get-wmiobject -class win32_product | where-object {$_.name -like '*QDocu*'}) -ne $null){
    Write-Output ("安装完毕!(SE)")
}else {
    Write-Debug ("安装失败，请手动安装后继续执行!!!(SE)")
}

#重载环境变量
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
#激活SE

cmd /c "qdocseconsole -c view"
Write-Debug "请手动激活SE后继续执行！！！"
#保护文件
cmd /c "qdocseconsole -c protect -d $path"
#授权进程
$program = $conf.program
cmd /c "qdocseconsole -c adjust -apf $program"
#降权
cmd /c "qdocseconsole -c finalize"
#启动业务服务
cd (Get-Item $conf.program).DirectoryName
Start-Process  $conf.program