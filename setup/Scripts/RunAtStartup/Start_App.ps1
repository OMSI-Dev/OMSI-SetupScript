$password = ConvertTo-SecureString "ismoomsi" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ('OMSI-Admin', $password)
$WatchDog = "C:\OMSI\Scripts\WatchDog.ps1"
$arg = "-NoExit -WindowStyle Minimized -ExecutionPolicy bypass -File $WatchDog"

Start powershell.exe -ArgumentList $arg -credential $credential