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
