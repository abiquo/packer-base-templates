Install-PackageProvider -Force NuGet
Install-Module -SkipPublisherCheck -Force PSWindowsUpdate
Get-Command –module PSWindowsUpdate
Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot
Install-WindowsUpdate –MicrosoftUpdate –AcceptAll –AutoReboot
