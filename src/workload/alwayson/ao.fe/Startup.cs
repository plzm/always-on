using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using ao.common;
using System.Net.Http;
using Microsoft.ApplicationInsights;

namespace ao.fe
{
	public class Startup
	{
		public Startup(IConfiguration configuration)
		{
			Configuration = configuration;
		}

		public IConfiguration Configuration { get; }

		// This method gets called by the runtime. Use this method to add services to the container.
		public void ConfigureServices(IServiceCollection services)
		{
			var cosmosDbConnectionString = Configuration["CosmosDbConnectionString"];
			var cosmosDbDatabaseName = Configuration["CosmosDbDatabaseName"];
			var cosmosDbProfileContainerName = Configuration["CosmosDbProfileContainerName"];
			var cosmosDbProgressContainerName = Configuration["CosmosDbProgressContainerName"];
			var eventHubNamespaceConnectionString = Configuration["EventHubConnectionString"];
			var eventHubName = Configuration["EventHubName"];


			services.AddApplicationInsightsTelemetry();

			services.AddControllers();

			services.AddHttpClient();

			// Register singleton Cosmos DB service
			services.AddSingleton<ICosmosDbService, CosmosDbService>(s => new CosmosDbService(cosmosDbConnectionString, cosmosDbDatabaseName, cosmosDbProfileContainerName, cosmosDbProgressContainerName, s.GetRequiredService<IHttpClientFactory>(), s.GetRequiredService<TelemetryClient>()));

			// Register singleton Event Hub service
			services.AddSingleton<IEventHubSenderService, EventHubSenderService>(s => new EventHubSenderService(eventHubNamespaceConnectionString, eventHubName, s.GetRequiredService<TelemetryClient>()));


			services.AddSwaggerGen(c =>
			{
				c.SwaggerDoc("v1", new OpenApiInfo { Title = "aofe", Version = "v1" });
			});
		}

		// This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
		public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
		{
			if (env.IsDevelopment())
			{
				app.UseDeveloperExceptionPage();
			}

			app.UseSwagger();
			app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "aofe v1"));

			app.UseRouting();

			app.UseAuthorization();

			app.UseEndpoints(endpoints =>
			{
				endpoints.MapControllers();
			});
		}
	}
}
