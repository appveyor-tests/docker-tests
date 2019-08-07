echo "Path to docker-compose:"
Write-Output (cmd /c where docker-compose)
echo "Print $LastExitCode:"
$LastExitCode
if ($LastExitCode -ne 0) {$host.SetShouldExit($LastExitCode)}
$images = (docker images)
$images
if ($images.length -ne 7) { throw "Wrong number of images!"; }
#- ps: if ($images[1].indexOf('microsoft/windowsservercore') -eq -1 -or $images[3].indexOf('microsoft/nanoserver') -eq -1) { throw "Images are incomplete!"; }
$run1 = (docker run microsoft/windowsservercore cmd /c dir)
$run1
if ($run1[3].indexOf('Directory of C:\') -eq -1) { throw "Error running microsoft/windowsservercore container"; }
$run2 = (docker run microsoft/nanoserver cmd /c dir)
$run2
if ($run2[3].indexOf('Directory of C:\') -eq -1) { throw "Error running microsoft/nanoserver container"; }
$containers = (docker ps -a -q)
$containers
if ($containers.length -ne 2) { throw "Wrong number of containers!"; }
if ($LastExitCode -ne 0) {$host.SetShouldExit($LastExitCode)}
