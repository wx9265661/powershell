$ip = (ipconfig|select-string "IPv4"|out-string).Split(":")[-1].Trim(" .-`t`n`r")
$ip2 = $ip.Trim(" .-`t`n`r")
write-output $ip2