# Remove the existing table, if any
<#
$cmd = 'use zipCodes
db.zips54.drop();'

$cmd | mongo
#>

# Import the data
#Get-Content -Path 'zips.4854d69c2ac3.json' | mongoimport -d zipCodes -c zips54

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
            $or: [
                { "first_char": "0" },
                { "first_char": "1" },
                { "first_char": "2" },
                { "first_char": "3" },
                { "first_char": "4" },
                { "first_char": "5" },
                { "first_char": "6" },
                { "first_char": "7" },
                { "first_char": "8" },
                { "first_char": "9" }
            ]
        }
    },
    {
        $group: {
            "_id": 0,
            "people": { "$sum": "$pop" }
        }
    }
]);'

$cmd | mongo zipCodes
