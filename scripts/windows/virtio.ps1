$Host.UI.RawUI.WindowTitle = "Downloading VirtIO drivers..."

certutil -f -addstore TrustedPublisher A:\virtio-cert.cer

$url = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
(new-object System.Net.WebClient).DownloadFile($url, "C:\Windows\Temp\virtio-win.iso")

$winversion = [System.Environment]::OSVersion.Version
$winvstr = "$($winversion.Major).$($winversion.Minor)"
$virtiover = switch ($winvstr) {
  "6.2" { "2k12" }
  "6.3" { "2k12R2" }
  "10.0" { "2k16" }
}


$Host.UI.RawUI.WindowTitle = "Mounting VirtIO ISO..."
Mount-DiskImage "C:\Windows\Temp\virtio-win.iso"
$isoletter = (Get-DiskImage "C:\Windows\Temp\virtio-win.iso" | Get-Volume).DriveLetter

$Host.UI.RawUI.WindowTitle = "Installing VirtIO drivers..."
pnputil -i -a "$isoletter`:\viostor\$virtiover\amd64\*.INF"
pnputil -i -a "$isoletter`:\NetKVM\$virtiover\amd64\*.INF"
pnputil -i -a "$isoletter`:\Balloon\$virtiover\amd64\*.INF"

$Host.UI.RawUI.WindowTitle = "Umounting VirtIO ISO..."
Dismount-DiskImage "C:\Windows\Temp\virtio-win.iso"
