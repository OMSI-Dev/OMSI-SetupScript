Clear-Host
Write-Host "Starting install..."
Start-Sleep 5


Function Install_OMSI {
$powerLoc = powercfg /import "$($pwd)\Misc\OMSIPower.pow" 0f7275a5-0272-43a9-a2ce-8fb27da021dc

Write-Host "Impporting OMSI Powerplan..."
$powerLoc
powercfg /setactive 0f7275a5-0272-43a9-a2ce-8fb27da021dc

Push-Location

Write-Host ""
Write-Host "Creating OMSI Folder at the Root of C:\"
Start-Sleep -Seconds 3
Set-Location C:\
mkdir OMSI
mkdir OMSI\ROC
mkdir OMSI\Autologon
mkdir OMSI\HDDLock
mkdir OMSI\App
mkdir OMSI\Scripts
mkdir OMSI\Drivers

Clear-Host
if ($response -eq 'Y' -or $response -eq 'y') {
	Write-Host ""
	Write-Host ""
	Write-Host "The next Utility is used to purge windows bloat..."
	Write-Host "Install Chromium"
	Write-Host "Tweaks Set to Desktop - Remove windows related bloat (Apps & Edge)"
	Write-Host "Set Updates to Security Only"
	Write-Host "Script will continue after closing..."
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Start-Sleep -Seconds 5
	Invoke-WebRequest -useb https://christitus.com/win | Invoke-Expression

	Clear-Host

	Write-Host ""
	Write-Host ""
	Write-Host "Activate Windows"
	Write-Host "Press HWID (1)"
	Write-Host "Press 1 to confirm"
	Write-Host "Press 0 to exit"
	Write-Host ""
	Write-Host ""
	Invoke-RestMethod https://massgrave.dev/get | Invoke-Expression
	Write-Host ""
	Write-Host ""
	Clear-Host

	Write-Host "Done with activation"
	Start-Sleep -Seconds 5
	Clear-Host
}

Write-Host ""
Write-Host ""
Write-Host "Copying Restart Scripts, Progams & Watchdog"
Write-Host ""
Write-Host ""
Pop-Location

Write-Host ""
Write-Host "Moving Restart on Crash"
Write-Host "Does not work with Processing games!, Use custom Watchdog located in \OMSI\Scripts\"
Copy-Item -path "$($pwd)\ROC\*" -Destination "C:\OMSI\ROC" -Force -recurse

Write-Host ""
Write-Host ""
Write-Host "Moving AutoLogon"
Copy-Item -path "$($pwd)\AutoLogon\*" -Destination "C:\OMSI\Autologon\" -Force -recurse
Start-Start-Sleep -Seconds 5

Write-Host ""
Write-Host ""
Write-Host "Moving Drivers...This can take a couple minutes"
Copy-Item -path "$($pwd)\Drivers\*" -Destination "C:\OMSI\Drivers\" -Force -recurse
Start-Start -Seconds 5

Clear-Host

Write-Host ""
Write-Host ""
Write-Host "Editing Group Policies..."
$GPO = "$($PSScriptRoot)\Scripts\GPO_Settings\LGPO.EXE"
$GPO_ARGS = "/t $($PSScriptRoot)\Scripts\GPO_Settings\gpo.txt"
Start-Process -FilePath $GPO -ArgumentList $GPO_ARGS -Wait

Write-Host ""
Write-Host ""
Write-Host "Removing Password Expiration..."
$UsrExp =  "wmic UserAccount where Name='Game' set PasswordExpires=False & timeout /t 3"
Start-Process -Verb RunAs cmd.exe -Args '/c', $UsrExp

Clear-Host

Write-Host ""
Write-Host "Copying...Watchdog. It needs to be configured. If you are not using ROC"
Write-Host "This can be done by modifying the watchdog INI and edit app_name to what ever app is copied later."
Write-Host "Watchdog copies to C:\OMSI\Scripts\ and will open file explorer to set the proper app"
Write-Host ""
Copy-Item -path "$($pwd)\Scripts\RunAtStartup\startup.bat*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" -Force
Copy-Item -path "$($pwd)\Scripts\*" -Destination "C:\OMSI\Scripts" -Force -recurse
Start-Start-Sleep -Seconds 5
explorer "C:\OMSI\Scripts\"

Clear-Host
Write-Host ""
Write-Host ""
Write-Host "...Creating Shortcuts for OMSI-Admin..."
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\Documents.lnk")
$Shortcut.TargetPath = "C:\Users\OMSI-Admin\Documents\"
$Shortcut.Save()
Clear-Host
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\C Drive.lnk")
$Shortcut.TargetPath = "C:\"
$Shortcut.Save()
Clear-Host
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\OMSI Software.lnk")
$Shortcut.TargetPath = "C:\OMSI\"
$Shortcut.Save()
Clear-Host
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\Startup.lnk")
$Shortcut.TargetPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
$Shortcut.Save()
Clear-Host


Write-Host ""
Write-Host ""
Write-Host "Moving OMSI_Layout to C:\"
Write-Host "This locks out the start menu."
Copy-Item -path "$($pwd)\Scripts\OMSI_Layout.xml" -Destination "C:\" -Force -recurse

Clear-Host

Write-Host ""
Write-Host "Install Reboot Lock ***Prevents Tampering with HDD***"
Write-Host "This will be ****enabled right after Install!***** You will need to disable to make changes to the system"
Write-Host "***** This includes any OMSI Custom software *****"
Start-Sleep -Seconds 5
Copy-Item -path "$($pwd)\HDDLock\*" -Destination "C:\OMSI\HDDLock" -Force -recurse
Start-Process "C:\OMSI\HDDLock\Setup.exe" -wait

Write-Host ""
Write-Host -NoNewLine 'Finsished....Closing Script';
Start-Sleep -Seconds 3
exit
} 

#Check Script is running with Elevated Privileges
Write-Host "Checking admin level"
Start-Sleep -Seconds 5
#Check-RunAsAdministrator

Set-Location $PSScriptRoot
Write-Host "Running from: $($PSScriptRoot) "
Write-Host ""

Start-Sleep -Seconds 1

$ProgressPreference = 'SilentlyContinue'
$NetCon = TNC -WarningAction silentlyContinue | where-Object {$_.PingSucceeded} |format-list PingSucceeded 
$NetString = $NetCon | Out-String -Stream | Select-String -Pattern "True" -SimpleMatch
$NetString = Out-String -InputObject $NetString
Write-Host ""
Write-Host "Checking connection to internet..."
Write-Host ""

If($NetString.Contains("True"))
{
	Write-Host "Online!"
	Clear-Host
	$delay = 5
	
	while ($delay -ge 0)
	{
	  start-Start-Sleep 1
	  $delay -= 1
	  Write-Host -noNewLine "`r$delay seconds before script continues..."
	  }
	$response = 'Y'  
	

	
	if(Test-Path -Path $flagFile -PathType Leaf)
	{
	Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "choco install winget"	-wait
	Remove-Item "restart.flag"
	} else {
		Write-Host "Installing & chocolatey before Win10 Utility Starts..."
	
		Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -ErrorAction Stop
		powershell choco feature enable -n allowGlobalConfirmation
		$flagFile = "restart.flag"
		$flagFIle = "OMSI_Setup_Completed.flag"
		Start-Sleep -Seconds 10
		Exit-PSHostProcess
	}

	Clear-Host-Host
	Write-Host "Winget Should be installed..."
	winget --version
	Write-Host "Moving on..."
	Start-Start-Sleep 5
	Install_OMSI
	
}
elseif("True" -notin $NetString)
{
	Write-Host "************"
	Write-Host "  Offline!"
	Write-Host "************"
	Write-Host ""
	Write-Host "You will not be able to use the Win10 Utility or the Activation Script"
	Write-Host ""

	# Prompt the user for input
	$response = Read-Host "Do you want to continue without internet? (Y/N)"

	# Check the response and take appropriate action
	if ($response -eq 'Y' -or $response -eq 'y') {
		Write-Host "continuing without internet..."
		#set to no to skip the utility functions 
		$response = 'N'
		Start-Sleep 3
		Install_OMSI
		
	} elseif ($response -eq 'N' -or $response -eq 'n') {
		Write-Host "Exiting script..."
		Start-Sleep 3
		Exit
	} else {
		Write-Host "Invalid response. Please enter Y or N."
	}

}




