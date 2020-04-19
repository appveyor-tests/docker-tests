$ErrorActionPreference = "Stop"

docker-compose --version
Start-Sleep -s 5
docker version

$images = (docker images)
$images
if ($images.length -ne ([int]$env:TOTAL_IMAGES + 1)) { throw "Wrong number of images!"; }

$run1 = (docker run mcr.microsoft.com/windows/servercore:ltsc2019 cmd /c dir)
$run1
if ($run1[3].indexOf('Directory of C:\') -eq -1) { throw "Error running mcr.microsoft.com/windows/servercore:ltsc2019 container"; }

$run2 = (docker run mcr.microsoft.com/windows/nanoserver:1809 cmd /c dir)
$run2
if ($run2[3].indexOf('Directory of C:\') -eq -1) { throw "Error running mcr.microsoft.com/windows/nanoserver:1809 container"; }

$containers = (docker ps -a -q)
$containers
if ($containers.length -ne 2) { throw "Wrong number of containers!"; }

# Testing LCOW mode if Experimental is set
Write-Host "Testing LCOW..." -ForegroundColor Cyan
$daemonConfig = Get-Content "$env:programdata\docker\config\daemon.json" | ConvertFrom-Json
if ($daemonConfig.experimental) {
  $results = (docker run --rm -v "$env:USERPROFILE`:/user-profile" busybox ls /user-profile) -join "`n"
  if ($results.indexOf('Application Data') -eq -1) { throw "Error running busybox in LCOW mode"; }
}

# Testing Linux mode
if ((Get-Command Switch-DockerLinux -ErrorAction SilentlyContinue) -ne $null) {
  Switch-DockerLinux
  $results = (docker run --rm -v "C:\:/disk_c" busybox ls /disk_c) -join "`n"
  if ($results.indexOf('Program Files') -eq -1) { throw "Error running busybox in Linux mode"; }  
}
