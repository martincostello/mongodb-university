namespace MartinCostelo.M101N.Exam.Question7
{
    using System;
    using System.Collections.Generic;
    using System.Globalization;
    using System.Linq;
    using System.Threading.Tasks;
    using MongoDB.Bson;
    using MongoDB.Driver;

    internal static class Program
    {
        internal static void Main(string[] args)
        {
            MainAsync(args).Wait();

            Console.WriteLine("Press enter...");
            Console.ReadLine();
        }

        private static async Task MainAsync(string[] args)
        {
            var client = new MongoClient();
            var db = client.GetDatabase("photos");

            var albums = db.GetCollection<BsonDocument>("albums");

            var result = await albums
                .Aggregate()
                .Unwind("images")
                .Group(@"{ _id: ""$images"" }")
                .ToListAsync();

            var nonOrphansIds = result
                .Select((p) => (int)p["_id"])
                .ToList();

            var images = db.GetCollection<BsonDocument>("images");

            var allImages = await images
                .Find(new BsonDocument())
                .ToListAsync();

            List<int> orphanIds = new List<int>();

            foreach (var image in allImages)
            {
                int id = (int)image["_id"];

                if (!nonOrphansIds.Contains(id))
                {
                    await images.DeleteOneAsync(string.Format(CultureInfo.InvariantCulture, "{{_id: {0}}}", id));
                }
            }
        }
    }
}
