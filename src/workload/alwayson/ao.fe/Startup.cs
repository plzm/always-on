using System;
using System.Collections.Generic;

using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;

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
			services.AddControllers();

			services.AddHttpClient();

			string cosmosDbConnectionString = Configuration["CosmosDbConnectionString"];
			string cosmosDbDatabaseName = Configuration["CosmosDbDatabaseName"];
			string cosmosDbProfileContainerName = Configuration["CosmosDbProfileContainerName"];
			string cosmosDbProgressContainerName = Configuration["CosmosDbProgressContainerName"];
			string eventHubConnectionString = Configuration["EventHubConnectionString"];

			// Register singleton Cosmos DB service
			services.AddSingleton((s) => 
			{
				ICosmosDbService service = 
					InitializeCosmosClientInstanceAsync
					(
						s,
						cosmosDbConnectionString,
						cosmosDbDatabaseName,
						cosmosDbProfileContainerName,
						cosmosDbProgressContainerName
					)
					.Result
				;

				return service;
			});

			services.AddSwaggerGen(c =>
			{
				c.SwaggerDoc("v1", new OpenApiInfo { Title = "ao.fe", Version = "v1" });
			});
		}

		// This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
		public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
		{
			if (env.IsDevelopment())
			{
				app.UseDeveloperExceptionPage();
				app.UseSwagger();
				app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "ao.fe v1"));
			}

			app.UseRouting();

			app.UseAuthorization();

			app.UseEndpoints(endpoints =>
			{
				endpoints.MapControllers();
			});
		}

		private static async Task<ICosmosDbService> InitializeCosmosClientInstanceAsync
		(
			IServiceProvider serviceProvider,
			string connectionString,
			string databaseName,
			string profileContainerName,
			string progressContainerName
		)
		{

			List<ValueTuple<string, string>> containers = new List<(string, string)>();
			containers.Add((databaseName, profileContainerName));
			containers.Add((databaseName, progressContainerName));

			IHttpClientFactory httpClientFactory = serviceProvider.GetRequiredService<IHttpClientFactory>();

			CosmosClientOptions clientOptions = new CosmosClientOptions()
			{
				ConnectionMode = ConnectionMode.Direct,
				ConsistencyLevel = ConsistencyLevel.Eventual,
				EnableContentResponseOnWrite = false,
				HttpClientFactory = httpClientFactory.CreateClient
			};

			CosmosClient client = await CosmosClient.CreateAndInitializeAsync(connectionString, containers.AsReadOnly(), clientOptions);

			CosmosDbService service = new CosmosDbService(client, databaseName, profileContainerName, progressContainerName);

			return service;
		}
	}
}
