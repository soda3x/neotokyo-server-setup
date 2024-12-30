param (
  [string]$Hostname = "My Neotokyo Server",
  [string]$RconPassword = "",
  [string]$ServerPassword = "",
  [int]$Port = 27015,
  [switch]$Help
)

if ($Help) {
  Write-Host "Usage: .\SetupNeotokyoServer.ps1 [OPTIONS]" -ForegroundColor Green
  Write-Host "Options:" -ForegroundColor Green
  Write-Host "  -Hostname        Specify the server hostname (default: 'My Neotokyo Server')." -ForegroundColor Yellow
  Write-Host "  -RconPassword    Set the RCON password for server administration (default: none, RCON disabled)." -ForegroundColor Yellow
  Write-Host "  -ServerPassword  Set a password for the server (default: none)." -ForegroundColor Yellow
  Write-Host "  -Port            Specify the server port (default: 27015)." -ForegroundColor Yellow
  Write-Host "  -Help            Display this help message." -ForegroundColor Yellow
  exit
}

$SteamCmdPath = "$PSScriptRoot\steamcmd"
$ServerPath = "$PSScriptRoot\neotokyo"
$SteamCmdExe = "$SteamCmdPath\steamcmd.exe"
$BatchFilePath = "$PSScriptRoot\StartNeotokyoServer.bat"

$logPrefix = "SetupNeotokyoServer:"

if (Test-Path -Path $BatchFilePath) {
  $Host.UI.RawUI.ForegroundColor = "Yellow"
  $batchExists = Read-Host -Prompt "$($logPrefix) It seems the server is already configured. Would you like to just start the server? (Y/N)"
  $Host.UI.RawUI.ForegroundColor = "White"

  if ($batchExists -eq 'y') {
    Write-Host "$($logPrefix) Starting the server..." -ForegroundColor Green
    cmd.exe /c $($BatchFilePath)
    exit
  }

  Write-Host "$($logPrefix) Reconfiguring the server..." -ForegroundColor Green
}

# Create directories if they don't exist
if (-Not (Test-Path -Path $SteamCmdPath)) {
  New-Item -ItemType Directory -Path $SteamCmdPath | Out-Null
}

if (-Not (Test-Path -Path $ServerPath)) {
  New-Item -ItemType Directory -Path $ServerPath | Out-Null
}

# Download SteamCMD
$SteamCmdUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$SteamCmdZip = "$SteamCmdPath\steamcmd.zip"

if (-Not (Test-Path -Path $SteamCmdExe)) {
  Write-Host "$($logPrefix) Downloading SteamCMD..." -ForegroundColor Green
  Invoke-WebRequest -Uri $SteamCmdUrl -OutFile $SteamCmdZip

  Write-Host "$($logPrefix) Extracting SteamCMD..." -ForegroundColor Green
  Expand-Archive -Path $SteamCmdZip -DestinationPath $SteamCmdPath -Force
  Remove-Item $SteamCmdZip
}
else {
  Write-Host "$($logPrefix) SteamCMD already exists. Skipping download." -ForegroundColor Yellow
}

# Install NeoTokyo Dedicated Server
Write-Host "$($logPrefix) Installing Neotokyo server..." -ForegroundColor Green
Start-Process -FilePath $SteamCmdExe -ArgumentList @(
  "+force_install_dir $ServerPath",
  "+login anonymous",
  "+app_update 313600 validate",
  "+quit"
) -NoNewWindow -Wait

# Generate server.cfg
$ServerCfgPath = "$ServerPath\NeotokyoSource\cfg\server.cfg"
Write-Host "$($logPrefix) Creating server.cfg..." -ForegroundColor Green
$ServerCfgContent = @"
hostname "$Hostname"
rcon_password "$RconPassword"
sv_lan 0
sv_password "$ServerPassword"
mp_timelimit 30
"@
New-Item -ItemType File -Path $ServerCfgPath -Force -Value $ServerCfgContent | Out-Null

# Create batch file to start the server
Write-Host "$($logPrefix) Creating batch file to start the server..." -ForegroundColor Green
$BatchFileContent = @"
@echo off
cd /d "$ServerPath"
start .\srcds.exe -console -game NeotokyoSource +map nt_isolation_ctg +maxplayers 24 -port $Port -autoupdate
"@
Set-Content -Path $BatchFilePath -Value $BatchFileContent -Force

Write-Host "$($logPrefix) Neotokyo dedicated server setup complete. To start the server, run $($BatchFilePath)" -ForegroundColor Green

$Host.UI.RawUI.ForegroundColor = "Green"
$startServer = Read-Host -Prompt "$($logPrefix) Do you want to start the server? (Y/N)"
$Host.UI.RawUI.ForegroundColor = "White"

if ($startServer -eq 'Y') {
  Write-Host "$($logPrefix) Starting the server..." -ForegroundColor Green
  cmd.exe /c $($BatchFilePath)
}
else {
  Write-Host "$($logPrefix) Finished." -ForegroundColor Green
}
