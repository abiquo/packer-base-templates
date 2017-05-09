$Host.UI.RawUI.WindowTitle = "Downloading Cloudbase-Init..."

# $url = "http://www.cloudbase.it/downloads/CloudbaseInitSetup_Beta_x64.msi"
$url = "https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi"
(new-object System.Net.WebClient).DownloadFile($url, "C:\Windows\Temp\cloudbase-init.msi")

$Host.UI.RawUI.WindowTitle = "Installing Cloudbase-Init..."

$serialPortName = @(Get-WmiObject Win32_SerialPort)[0].DeviceId

$p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/i C:\Windows\Temp\cloudbase-init.msi /qn /l*v C:\Windows\Temp\cloudbase-init.log LOGGINGSERIALPORTNAME=$serialPortName USERNAME=Administrator"
if ($p.ExitCode -ne 0) {
    throw "Installing Cloudbase-Init failed. Log: C:\Windows\Temp\cloudbase-init.log"
}

$Host.UI.RawUI.WindowTitle = "Running Cloudbase-Init SetSetupComplete..."
& "${env:ProgramFiles}\Cloudbase Solutions\Cloudbase-Init\bin\SetSetupComplete.cmd"

$MDS = "metadata_services='cloudbaseinit.metadata.services.configdrive.ConfigDriveService'"
$FLB = "first_logon_behaviour=no"
$ConfFile = "${env:ProgramFiles}\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"
$ConfFileUnattend = "${env:ProgramFiles}\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf"
Add-Content $ConfFile $MDS
Add-Content $ConfFile $FLB
Add-Content $ConfFileUnattend $MDS
Add-Content $ConfFileUnattend $FLB

# Start-Sleep -s 1000

$Host.UI.RawUI.WindowTitle = "Running Sysprep..."
$unattendedXmlPath = "${env:ProgramFiles}\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
& "${env:SystemRoot}\System32\Sysprep\Sysprep.exe" `/generalize `/oobe `/quit `/unattend:"$unattendedXmlPath"
