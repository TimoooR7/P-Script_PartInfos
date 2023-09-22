$action = New-ScheduledTaskAction -Execute 'notepad.exe' -Argument 'T:\test.txt'
$hour = "10:30"
$trigger = New-ScheduledTaskTrigger -Once -At $hour
 
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName Salut -TaskPath "\Projet" -Description "Ceci est une description"
