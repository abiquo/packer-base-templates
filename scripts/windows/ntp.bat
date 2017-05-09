powershell -Command "W32tm /config /manualpeerlist:pool.ntp.org /syncfromflags:MANUAL"
powershell -Command "W32tm /config /update"
powershell -Command "Stop-Service w32time"
powershell -Command "Start-Service w32time"
