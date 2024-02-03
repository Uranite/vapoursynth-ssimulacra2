$jsonUrl = "https://raw.githubusercontent.com/ziglang/www.ziglang.org/master/data/releases.json"
$jsonContent = Invoke-RestMethod -Uri $jsonUrl -Method Get
$version = $jsonContent.master.version
$zipUrl = $jsonContent.master.'x86_64-windows'.tarball

$parentFolder = Split-Path -Path $PSScriptRoot -Parent
$zipFilePath = Join-Path $PSScriptRoot "zig-windows-x86_64-$version.zip"
$zigPath = Join-Path $PSScriptRoot "\zig-windows-x86_64-$version\zig.exe"
$dllFilePath = Join-Path $parentFolder "\zig-out\lib\ssimulacra2.dll"
$destinationFileFolder = Join-Path $env:APPDATA "\VapourSynth\plugins64"
New-Item -ItemType Directory -Force -Path $destinationFileFolder | Out-Null
$destinationFilePath = Join-Path $destinationFileFolder "\ssimulacra2.dll"

if (-not (Test-Path $zipFilePath)){
    Write-Host "Downloading zig-windows-x86_64-$version.zip..." -ForegroundColor Green
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipFilePath
}

if (-not (Test-Path $zigPath)){
    Write-Host "Extracting zig-windows-x86_64-$version.zip..." -ForegroundColor Green
    Expand-Archive -Path $zipFilePath -DestinationPath $PSScriptRoot -Force
}

Write-Host "Building ssimulacra2.dll..." -ForegroundColor Green
& $zigPath build -Doptimize=ReleaseFast

if (Test-Path $dllFilePath){
    Write-Host "Installing 'ssimulacra2.dll' to '$destinationFilePath'" -ForegroundColor Blue
    Copy-Item -Path $dllFilePath -Destination $destinationFilePath -Force
} else {
    Write-Host "No '\zig-out\lib\ssimulacra2.dll' file, build error." -ForegroundColor Red
}
