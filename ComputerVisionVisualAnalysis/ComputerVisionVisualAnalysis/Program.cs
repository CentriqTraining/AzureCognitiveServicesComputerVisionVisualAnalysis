using Common;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision;
using Microsoft.Azure.CognitiveServices.Vision.ComputerVision.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace ComputerVisionVisualAnalysis
{
    class Program
    {
        static void Main(string[] args)
        {
            ApiKeyServiceClientCredentials Credentials = new ApiKeyServiceClientCredentials(Utilities.ReadKeyFromJson("ComputerVision"));
            ComputerVisionClient client = new ComputerVisionClient(Credentials);
            client.Endpoint = "https://eastus.api.cognitive.microsoft.com/";

            var FileList = Directory.GetFiles("../../Images");
            foreach (var item in FileList)
            {
                //  Double-click on each of the images in the folder
                //  NOtice what is in each image

                //  First result will be keywords of what it found
                //  was in the images
                var results = client.TagImageInStreamWithHttpMessagesAsync(File.OpenRead(item)).GetAwaiter().GetResult();
                string contents = results.Response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                Console.WriteLine(Utilities.JsonPrettyPrint(contents));
                Thread.Sleep(250);

                //  Next will be an attempt at describing what that image
                //  is.  Sometimes it is very good...sometimes very bad.
                var results2 = client.DescribeImageInStreamWithHttpMessagesAsync(File.OpenRead(item)).GetAwaiter().GetResult();
                contents = results2.Response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                Console.WriteLine(Utilities.JsonPrettyPrint(contents));
                Thread.Sleep(250);

                //  Finally, we will give a racy/adult rating.  This coule
                //  be useful to automatically remove adult content from 
                //  your site.  The last photo was as close as I 
                //  could get and still be professional
                var result3 = client.AnalyzeImageInStreamAsync(File.OpenRead(item), new List<VisualFeatureTypes>() { VisualFeatureTypes.Adult }).GetAwaiter().GetResult();
                Console.WriteLine("Adult Score (adult, racy): {0},{1}", result3.Adult.AdultScore, result3.Adult.RacyScore);
                Console.WriteLine("Complete: {0}", item);
                Console.ReadLine();
            }
        }
    }
}
