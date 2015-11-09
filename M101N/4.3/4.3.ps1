$BackupPath = Join-Path $PSScriptRoot ".\mongodump.9bf811a61f67.zip"
$Destination = Join-Path $PSScriptRoot ".\dump"

if ((Test-Path $Destination) -eq $false)
{
    Write-Host "Extracting '$BackupPath' to '$Destination'..."
    Add-Type -Assembly "System.IO.Compression.FileSystem"
    [IO.Compression.ZipFile]::ExtractToDirectory($BackupPath, $Destination)
}

$cmd = 'db.dropDatabase()'

$cmd | mongo blog
mongorestore (Join-Path $Destination "dump")

$cmd = 'use blog
db.posts.createIndex({ "CreatedAtUtc": -1 })
db.posts.createIndex({ "Tags": 1, "CreatedAtUtc": -1 })'

$cmd | mongo
