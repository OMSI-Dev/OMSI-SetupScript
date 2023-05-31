Clear
Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!"
       Echo ""       
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
       
        #sleep -Seconds 2
        exit  
             
 
    }
}

Function Install_OMSI {
$powerLoc = powercfg /import "$($pwd)\Misc\OMSIPower.pow" 0f7275a5-0272-43a9-a2ce-8fb27da021dc

Echo "Impporting OMSI Powerplan..."
$powerLoc
powercfg /setactive 0f7275a5-0272-43a9-a2ce-8fb27da021dc

Push-Location

Echo ""
Echo "Creating OMSI Folder at the Root of C:\"
sleep -Seconds 3
CD C:\
mkdir OMSI
mkdir OMSI\ROC
mkdir OMSI\Autologon
mkdir OMSI\HDDLock
mkdir OMSI\App
mkdir OMSI\Scripts
mkdir OMSI\Drivers

clear

echo ""
echo ""
echo "The next Utility is used to purge windows bloat..."
echo "Install Chromium"
echo "Tweaks Set to Desktop - Remove windows related bloat (Apps & Edge)"
echo "Set Updates to Security Only"
echo "Script will continue after closing..."
echo ""
echo ""
echo ""
echo ""
sleep -Seconds 10
iwr -useb https://christitus.com/win | iex

clear

echo ""
echo ""
Echo "Activate Windows"
echo ""
echo ""
irm https://massgrave.dev/get | iex
echo ""
echo ""
clear

echo "Done with activation"
sleep -Seconds 5
clear

echo ""
echo ""
Echo "Copying Restart Scripts, Progams & Watchdog"
echo ""
echo ""
Pop-Location

Echo ""
Echo "Moving Restart on Crash"
Echo "Does not work with Processing games!, Use custom Watchdog located in \OMSI\Scripts\"
Copy-Item -path "$($pwd)\ROC\*" -Destination "C:\OMSI\ROC" -Force -recurse

Echo ""
Echo ""
Echo "Moving AutoLogon"
Copy-Item -path "$($pwd)\AutoLogon\*" -Destination "C:\OMSI\Autologon\" -Force -recurse
Start-Sleep -Seconds 5

Echo ""
Echo ""
Echo "Moving Drivers...This can take a couple minutes"
Copy-Item -path "$($pwd)\Drivers\*" -Destination "C:\OMSI\Drivers\" -Force -recurse
Start-Sleep -Seconds 5

clear

Echo ""
Echo ""
Echo "Editing Group Policies..."
$GPO = "$($PSScriptRoot)\Scripts\GPO_Settings\LGPO.EXE"
$GPO_ARGS = "/t $($PSScriptRoot)\Scripts\GPO_Settings\gpo.txt"
Start-Process -FilePath $GPO -ArgumentList $GPO_ARGS -Wait

Echo ""
Echo ""
Echo "Removing Password Expiration..."
$UsrExp =  "wmic UserAccount where Name='Game' set PasswordExpires=False & timeout /t 3"
Start-Process -Verb RunAs cmd.exe -Args '/c', $UsrExp

Clear

Echo ""
Echo "Copying...Watchdog. It needs to be configured. If you are not using ROC"
Echo "This can be done by modifying the watchdog INI and edit app_name to what ever app is copied later."
Echo "Watchdog copies to C:\OMSI\Scripts\ and will open file explorer to set the proper app"
Echo ""
Copy-Item -path "$($pwd)\Scripts\RunAtStartup\startup.bat*" -Destination "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" -Force
Copy-Item -path "$($pwd)\Scripts\*" -Destination "C:\OMSI\Scripts" -Force -recurse
Start-Sleep -Seconds 5
explorer "C:\OMSI\Scripts\"

clear
Echo ""
Echo ""
Echo "...Creating Shortcuts for OMSI-Admin..."
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\Documents.lnk")
$Shortcut.TargetPath = "C:\Users\OMSI-Admin\Documents\"
$Shortcut.Save()
Clear
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\C Drive.lnk")
$Shortcut.TargetPath = "C:\"
$Shortcut.Save()
Clear
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\OMSI Software.lnk")
$Shortcut.TargetPath = "C:\OMSI\"
$Shortcut.Save()
Clear
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\OMSI-Admin\Desktop\Startup.lnk")
$Shortcut.TargetPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
$Shortcut.Save()
Clear


echo ""
echo ""
echo "Moving OMSI_Layout to C:\"
echo "This locks out the start menu."
Copy-Item -path "$($pwd)\Scripts\OMSI_Layout.xml" -Destination "C:\" -Force -recurse

clear

Echo ""
Echo "Install Reboot Lock ***Prevents Tampering with HDD***"
Echo "This will be ****enabled right after Install!***** You will need to disable to make changes to the system"
Echo "***** This includes any OMSI Custom software *****"
sleep -Seconds 5
Copy-Item -path "$($pwd)\HDDLock\*" -Destination "C:\OMSI\HDDLock" -Force -recurse
Start-Process "C:\OMSI\HDDLock\Setup.exe" -wait

Echo ""
Write-Host -NoNewLine 'Finsished....Closing Script';
sleep -Seconds 3
exit
} 

#Check Script is running with Elevated Privileges
Check-RunAsAdministrator

CD $PSScriptRoot
Echo "Running from: $($PSScriptRoot) "
Echo ""

sleep -Seconds 1

$ProgressPreference = 'SilentlyContinue'
$NetCon = TNC -WarningAction silentlyContinue | where {$_.PingSucceeded} |format-list PingSucceeded 
$NetString = $NetCon | Out-String -Stream | Select-String -Pattern "True" -SimpleMatch
$NetString = Out-String -InputObject $NetString
Echo ""
Echo "Checking connection to internet..."
Echo ""

If($NetString.Contains("True"))
{
	Echo "Online!"
	Clear-Host	
	$delay = 5
	while ($delay -ge 0)
	{
	  start-sleep 1
	  $delay -= 1
	  Write-Host -noNewLine "`r$delay seconds before script continues..."
	  }
	  
	Install_OMSI
	
}
elseif("True" -notin $NetString)
{
Echo "************"
Echo "  Offline!"
Echo "************"
Echo ""
Echo "Run this script with an Internet Connection & Restart."
Echo ""
Exit
}




