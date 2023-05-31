#Watchdog should start at startup and automatically turn on the game.
#Edit the watchdog INI to configure it for each component

$INI = Get-Content "$($PSScriptRoot)\watch_dog_config.ini"

$IniHash = @{}
$IniTemp = @()
ForEach($Line in $INI)
{
If ($Line -ne "" -and $Line.StartsWith("[") -ne $True)
{
    if($Line -and $Line.StartsWith("#") -ne $True)
    {  
    $Line = $Line -replace '\s',''  
    $IniTemp += $Line
    }
}
}

ForEach($Line in $IniTemp)
{

$SplitArray = $Line.Split("=")
$IniHash += [ordered]@{$SplitArray[0] = $SplitArray[1]}
}

$gameTitle = $IniHash.app_name

$CheckTime = $IniHash.check_time

#| where {$_.PingSucceeded} |format-list PingSucceeded 

#Close if OMSI-Admin is currently logged in
$CurUser = (Get-WMIObject -ClassName Win32_ComputerSystem).Username 
$UserString = $CurUser | Out-String -Stream | Select-String -Pattern "OMSI-Admin" -SimpleMatch
$UserString = Out-String -InputObject $UserString


If($UserString.Contains("OMSI-Admin"))
{
Echo "Admin Logged in. Exiting script."
Exit
}
elseif("True" -notin $UserString)
{
Echo "Admin not logged in. Continuing script."
}

sleep -seconds 3
clear

#just forces it to loop forver
$loop = 1
Write-Host ""
Write-Host "*******************************************************************************" 
Write-Host "*** This will watch for the program """$($gameTitle)""" to crash every $($CheckTime) seconds.***"
Write-Host "***  The program will only display a message if the watched program crashes. ***"
Write-Host "*******************************************************************************"
Write-Host ""
Write-Host "Pressing Ctrl+C will cancel the current watch dog"
Write-Host ""
While($loop){
    $runningApp = Get-Process |where {$_.mainWindowTItle} |format-list mainwindowtitle 
    $AppString = $runningApp| Out-String -Stream | Select-String -Pattern $gameTitle -SimpleMatch
    $AppString = Out-String -InputObject $AppString

    If($AppString.Contains($gameTitle)){
    
    sleep -Seconds $CheckTime
    }elseif($gameTitle -notin $AppString){
    Echo "NOT FOUND...Restarting Game..."
    
    #Kills Java in case it is stuck. This prevents a memory being used and not released
    Stop-Process -Name java -force -erroraction 'silentlycontinue'
    Stop-Process -Name javaw -force -erroraction 'silentlycontinue'
	
	try
	{
    Start-Process "C:\OMSI\App\$($gameTitle).lnk" -erroraction 'silentlycontinue'
	}
	catch
	{
		Echo "$($gameTitle) cannot be found. Ensure the game's shortcut is named correctly."
	}
    
    #Sleep before rechecking for running program
    sleep -seconds $CheckTime    
    }
}
