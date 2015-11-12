# Remove the existing table, if any
$cmd = 'use grades
db.grades.drop()'

$cmd | mongo

# Import the data
Get-Content -Path 'grades.json' | mongoimport -d grades -c grades

$cmd = '
db.grades.aggregate([
	{
		$unwind: "$scores"
	},
	{
		$match: {
			$or: [
				{ "scores.type": "exam" },
				{ "scores.type": "homework" }
			]
		}
	},
	{
		$group: {
			"_id": { "student_id": "$student_id", "class_id": "$class_id" },
			"gpa": { $avg: "$scores.score" }
		}
	},
	{
		$group: {
			"_id": "$_id.class_id",
			"average": { $avg: "$gpa" }
		}
	},
	{
		$sort: { "average": -1 }
	},
	{
		$project: {
			"_id": 0,
			"class_id": "$_id",
			"average_student_gpa": "$average"
		}
	},
	{
		$limit: 1
	}
]);'

$cmd | mongo grades
