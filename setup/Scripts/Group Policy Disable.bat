@echo off
echo "Set Policy to Defaults..."
echo "It is safe to ignore any file not found messages."
CD C:\Windows\SysWOW64
RD /S /Q "%WinDir%\SysWOW64\GroupPolicyUsers" 
RD /S /Q "%WinDir%\SysWOW64\GroupPolicy"
CD C:\Windows\System32\
RD /S /Q "%WinDir%\System32\GroupPolicyUsers"
RD /S /Q "%WinDir%\System32\GroupPolicy"
gpupdate /force

