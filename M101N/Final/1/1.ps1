# Extract the ZIP if not already extracted
$BackupPath = Join-Path $PSScriptRoot "..\enron.zip"
$Destination = Join-Path $PSScriptRoot "..\_enron"

if ((Test-Path $BackupPath) -eq $false)
{
    throw "$BackupPath was not found."
}

if ((Test-Path $Destination) -eq $false)
{
    Write-Host "Extracting '$BackupPath' to '$Destination'..."
    Add-Type -Assembly "System.IO.Compression.FileSystem"
    [IO.Compression.ZipFile]::ExtractToDirectory($BackupPath, $Destination)
}

$cmd = 'db.dropDatabase()'

$cmd | mongo enron
mongorestore (Join-Path $Destination "dump")

$cmd = 'use enron
db.messages.count();'

$cmd | mongo
