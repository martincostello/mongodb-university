# Remove the existing table, if any
$cmd = 'use zipCodes
db.zips54.drop();'

$cmd | mongo

# Import the data
Get-Content -Path 'zips.4854d69c2ac3.json' | mongoimport -d zipCodes -c zips54

# Calculate the number of people who live in a zip code in the US where the city starts with a digit.
$cmd = 'db.zips54.aggregate([
    {
        $project: {
            "first_char": { $substr : [ "$city", 0, 1] },
            "pop": "$pop"
        }
    },
    {
        $match: {
            "first_char": { $gte: "0" },
            "first_char": { $lte: "9" }
        }
    },
    {
        $group: {
            "_id": null,
            "people": { "$sum": "$pop" }
        }
    },
    {
        $project: {
            "_id": 0,
            "people": "$people"
        }
    }
]);'

$cmd | mongo zipCodes
