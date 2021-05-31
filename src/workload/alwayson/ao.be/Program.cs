using System;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.ApplicationInsights;
using ao.common;

namespace ao.be
{
	class Program
	{
		static void Main(string[] args)
		{
			// Get the App Insights instrumentation key
			//string appInsightsInstrumentationKey = Environment.GetEnvironmentVariable("");

			// Create the DI container.
			IServiceCollection services = new ServiceCollection();

			// Being a regular console app, there is no appsettings.json or configuration providers enabled by default.
			// Hence instrumentation key and any changes to default logging level must be specified here.
			services.AddLogging();
			services.AddApplicationInsightsTelemetryWorkerService();

			// Build ServiceProvider.
			IServiceProvider serviceProvider = services.BuildServiceProvider();

			// Obtain logger instance from DI.
			ILogger<Program> logger = serviceProvider.GetRequiredService<ILogger<Program>>();

			// Obtain TelemetryClient instance from DI, for additional manual tracking or to flush.
			var telemetryClient = serviceProvider.GetRequiredService<TelemetryClient>();

			// Run indefinitely
			var processor = new EventHubReceiverService(telemetryClient);
			processor.RunAsync().Wait();

			// Explicitly call Flush() followed by sleep is required in Console Apps.
			// This is to ensure that even if application terminates, telemetry is sent to the back-end.
			telemetryClient.Flush();
			Task.Delay(5000).Wait();
		}
	}
}
