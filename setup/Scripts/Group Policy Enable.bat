@echo off
Echo "Restoring Group Policy"
wmic UserAccount set PasswordExpires=False
C:\OMSI\Scripts\GPO_Settings\LGPO.exe /t C:\OMSI\Scripts\GPO_Settings\gpo.txt 
gpupdate /force
timeout /t 5