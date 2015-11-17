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
            "state" : {
                "$in": [ "CA", "NY" ]
            }
        }
    },
    {
        $group: {
            "_id": { "state": "$state", "city": "$city" },
            "pop": { $sum: "$pop" }
        }
    },
    {
        $match: {
            "pop" : { $gt: 25000 }
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
