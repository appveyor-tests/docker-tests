$ErrorActionPreference = "Stop"

docker-compose --version
Start-Sleep -s 30
docker version

$images = (docker images --digests)
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

# Check "old" host records
Get-Content "$env:windir\System32\drivers\etc\hosts"

# Testing LCOW mode if Experimental is set
$daemonConfig = Get-Content "$env:programdata\docker\config\daemon.json" | ConvertFrom-Json
if ($daemonConfig.experimental) {
  Write-Host "Testing LCOW..." -ForegroundColor Cyan
  $results = (docker run --rm -v "$env:USERPROFILE`:/user-profile" busybox ls /user-profile) -join "`n"
  $results
  if ($results.indexOf('Application Data') -eq -1) { throw "Error running busybox in LCOW mode"; }
}

# Testing Linux mode
if (Test-Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\docker-appveyor") {
  Write-Host "Testing Linux mode..." -ForegroundColor Cyan
  $results = (docker run --rm -v "C:\Users\:/windows_users" busybox ls /windows_users) -join "`n"
  $results
  if ($results.indexOf('appveyor') -eq -1) { throw "Error running busybox in Linux mode"; }  
}
