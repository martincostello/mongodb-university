# Remove the existing table, if any
$cmd = 'use zipCodes
db.smallZips.drop()'

$cmd | mongo

# Import the data
Get-Content -Path 'small_zips.json' | mongoimport -d zipCodes -c smallZips

# Calculate the average population of cities in California and New York (taken together) with populations over 25,000.
$cmd = '
db.smallZips.aggregate([
    {
        $match: {
            "$or": [
                {"state": "CA"},
                {"state": "NY"}
            ],
            "pop": { "$gt": 25000 }
        }
    },
    {
        $project: {
            "_id": 0,
            "state": "$state",
            "city": "$city",
            "zip": "$_id",
            "pop": "$pop"
        }
    },
    {
        $group: {
            "_id": { "state": "$state", "city": "$city" },
            "pop": { $sum: "$pop" }
        }
    },
    {
        $group: {
            "_id": null,
            "average_population": { "$avg": "$pop" }
        }
    }
]);'

$cmd | mongo zipCodes
