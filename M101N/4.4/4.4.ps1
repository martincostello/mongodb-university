# Remove the existing table, if any
$cmd = 'use m101
db.profile.drop()'

$cmd | mongo

# Import the data
Get-Content -Path 'sysprofile.acfbb9617420.json' | mongoimport -d m101 -c profile

# Find the longest running operation of the students collection in school2
$cmd = 'use m101
db.profile.find({ "ns": "school2.students" }, { "_id": 0, "millis": 1 }).sort({ "millis": -1 }).limit(1).pretty()'

$cmd | mongo
