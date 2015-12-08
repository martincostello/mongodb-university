# Extract the ZIP if not already extracted
$BackupPath = Join-Path $PSScriptRoot ".\final7.55e3678c7664.zip"
$Destination = Join-Path $PSScriptRoot ".\final7"

if ((Test-Path $Destination) -eq $false)
{
    Write-Host "Extracting '$BackupPath' to '$Destination'..."
    Add-Type -Assembly "System.IO.Compression.FileSystem"
    [IO.Compression.ZipFile]::ExtractToDirectory($BackupPath, $Destination)
}

# Remove the existing collections, if any
$cmd = 'use photos
db.albums.drop();
db.images.drop();'

$cmd | mongo

# Import the albums and photos
Get-Content -Path '.\final7\final7\albums.json' | mongoimport -d photos -c albums
Get-Content -Path '.\final7\final7\images.json' | mongoimport -d photos -c images

$cmd = 'db.albums.createIndex({ "images": 1 });
db.images.createIndex({ "tags": 1 });
db.albums.aggregate([
    {
        $unwind: "$images"
    },
    {
        $group: {
            "_id": "$images"
        }
    },
    {
        $group: {
            _id: null,
            count: {
                $sum: 1
            }
        }
    }
]);'

$cmd | mongo photos

# Delete the orphans...

$cmd = 'db.images.find({ "tags": "sunrises" }).count()'

$cmd | mongo photos
