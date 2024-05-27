Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!"
       Write-Host ""       
  }
  else
    {
        #Create a new Elevated process to Start PowerShell
        $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
               
               
        # Specify the current script path and name as a parameter
        $ElevatedProcess.Arguments = "-NoExit -ExecutionPolicy bypass -File $($PWD)\OMSI_Setup.ps1"
       
        
        #Set the Process to elevated
        $ElevatedProcess.Verb = "runas"
        #$elevatedprocess.UseShellExecute = 0
        
        #Start the new elevated process
        [System.Diagnostics.Process]::Start($ElevatedProcess)
       
        #Start-Sleep -Seconds 2
        exit  
             
 
    }
}

Write-Host "Starting install..."
Start-Sleep 3


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
if(-not (Test-Path "C:\OMSI")){ mkdir C:\OMSI}
if(-not (Test-Path "C:\OMSI\ROC")){ mkdir C:\OMSI\ROC}
if(-not (Test-Path "C:\OMSI\Autologon")){ mkdir C:\OMSI\Autologon}
if(-not (Test-Path "C:\OMSI\HDDLock")){ mkdir C:\OMSI\HDDLock}
if(-not (Test-Path "C:\OMSI\App")){ mkdir C:\OMSI\App}
if(-not (Test-Path "C:\OMSI\Scripts")){ mkdir C:\OMSI\Scripts}
if(-not (Test-Path "C:\OMSI\Drivers")){ mkdir C:\OMSI\Drivers}



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
	Start-Sleep -Seconds 3
	#irm https://christitus.com/win | iex
	irm https://christitus.com/win | iex -Config "D:\setup\CTT_Program_Preset.json" -Run
	

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
	

	Write-Host "Done with activation"
	Start-Sleep -Seconds 3
	
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
Start-Sleep -Seconds 3

Write-Host ""
Write-Host ""
Write-Host "Moving Drivers...This can take a couple minutes"
Copy-Item -path "$($pwd)\Drivers\*" -Destination "C:\OMSI\Drivers\" -Force -recurse
Start-Sleep -Seconds 3



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



Write-Host ""
Write-Host "Copying...Watchdog. It needs to be configured. If you are not using ROC"
Write-Host "This can be done by modifying the watchdog INI and edit app_name to what ever app is copied later."
Write-Host "Watchdog copies to C:\OMSI\Scripts\ and will open file explorer to set the proper app"
Write-Host ""
Copy-Item -path "$($pwd)\Scripts\RunAtStartup\startup.bat*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" -Force
Copy-Item -path "$($pwd)\Scripts\*" -Destination "C:\OMSI\Scripts" -Force -recurse
Start-Sleep -Seconds 3
explorer "C:\OMSI\Scripts\"


Write-Host ""
Write-Host ""
Write-Host "...Creating Shortcuts for OMSI-Admin..."
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\Documents.lnk")
$Shortcut.TargetPath = "C:\Users\OMSI-Admin\Documents\"
$Shortcut.Save()

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\C Drive.lnk")
$Shortcut.TargetPath = "C:\"
$Shortcut.Save()

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\OMSI Software.lnk")
$Shortcut.TargetPath = "C:\OMSI\"
$Shortcut.Save()

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\Startup.lnk")
$Shortcut.TargetPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
$Shortcut.Save()



Write-Host ""
Write-Host ""
Write-Host "Moving OMSI_Layout to C:\"
Write-Host "This locks out the start menu."
Copy-Item -path "$($pwd)\Scripts\OMSI_Layout.xml" -Destination "C:\" -Force -recurse

Write-Host ""
Write-Host -NoNewLine 'Finsished....Closing Script';
Start-Sleep -Seconds 3
exit
} 

#Check Script is running with Elevated Privileges
Write-Host "Checking admin level"
Start-Sleep -Seconds 3
Check-RunAsAdministrator

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
	
	$delay = 5
	
	while ($delay -ge 1)
	{
	  Start-Sleep 1
	  $delay -= 1
	  Write-Host -noNewLine "`r$delay seconds before script continues..."
	  }
	  
	$response = 'Y'  

	# get latest download url
	$URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
	$URL = (Invoke-WebRequest -Uri $URL).Content -UseBasicParsing | ConvertFrom-Json |
			Select-Object -ExpandProperty "assets" |
			Where-Object "browser_download_url" -Match '.msixbundle' |
			Select-Object -ExpandProperty "browser_download_url"

	# download
	Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing

	# install
	Add-AppxPackage -Path "Setup.msix"

	# delete file
	Remove-Item "Setup.msix"
		
	
	Write-Host "Winget Should be installed...and show its version number below."
	winget --version
	Write-Host "Moving on regardless, CTT should attempt to install anyways."
	Start-Sleep 5
	Clear-Host
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




