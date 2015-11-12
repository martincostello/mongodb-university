# Remove the existing table, if any
$cmd = 'use zipCodes
db.zips.drop()'

$cmd | mongo

# Import the data
Get-Content -Path 'zips.json' | mongoimport -d zipCodes -c zips
