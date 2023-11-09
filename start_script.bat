@echo off

:: Define the path to the PowerShell script and flag files
set "ScriptPath=%~dp0setup\OMSI_Setup.ps1"
set "RunOnceFlag=runOnce.flag"
set "RestartFlag=restart.flag"
set "CompletionFlag=OMSI_Setup_Completed.flag"

:: Check if the runOnce flag exists
if not exist "%RunOnceFlag%" (
    echo "Running OMSI_Setup.ps1..."

    :: Start a new PowerShell process as administrator to run the script
    powershell.exe -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%ScriptPath%\"' -Verb RunAs"
    
    echo "Waiting for OMSI_Setup.ps1 to complete..."

    :: Check if the completion flag exists, indicating the script has finished
    :waitForCompletion
    if not exist "%CompletionFlag%" (
        timeout /t 1 /nobreak >nul
        goto waitForCompletion
    )
    
    echo "OMSI_Setup.ps1 finished."

    :: Check if the restart flag exists and open the setup file again
    if exist "%RestartFlag%" (
        echo "Restart flag detected. Opening OMSI_Setup.ps1 again..."
        
        :: Start a new PowerShell process as administrator to run the script
        powershell.exe -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File \"%ScriptPath%\"' -Verb RunAs"
    )
)

:: Optionally, you can delete the runOnce flag here
del "%RunOnceFlag%"
