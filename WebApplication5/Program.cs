using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Serilog;
using Serilog.Events;

namespace WebApplication5
{
    public class Program
    {
        public static void Main(string[] args)
        {
            Log.Logger = new LoggerConfiguration()
                //.MinimumLevel.Information() // this is the default
                // Suppress framework log noise eg routing and handling
                // so we'll see warnings and errors from the framework
               .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
               .Enrich.FromLogContext()
               .WriteTo.Console()
               .WriteTo.File(@"logs/warning.txt", restrictedToMinimumLevel: LogEventLevel.Warning, rollingInterval: RollingInterval.Day)
               .WriteTo.File(@"logs/info.txt", restrictedToMinimumLevel: LogEventLevel.Information, rollingInterval: RollingInterval.Day)
               .CreateLogger();
            try
            {
                Log.Information("");
                Log.Information("Starting up BLC.Website (Program.cs)");
                CreateHostBuilder(args).Build().Run();
            }
            catch (Exception ex)
            {
                Log.Fatal(ex, "Application start-up failed");
            }
            finally
            {
                Log.CloseAndFlush();
            }
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
               .UseSerilog()
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });
    }
}
