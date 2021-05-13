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

			// Register singleton Cosmos DB client
			services.AddSingleton(async (s) => 
			{
				CosmosClient client = await GetCosmosClient(s);

				return client;
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

		private async Task<CosmosClient> GetCosmosClient(IServiceProvider s)
		{
			IHttpClientFactory httpClientFactory = s.GetRequiredService<IHttpClientFactory>();

			CosmosClientOptions clientOptions = new CosmosClientOptions()
			{
				ConnectionMode = ConnectionMode.Direct,
				ConsistencyLevel = ConsistencyLevel.Eventual,
				EnableContentResponseOnWrite = false,
				HttpClientFactory = httpClientFactory.CreateClient
			};

			List<ValueTuple<string, string>> dbsColls = new List<(string, string)>();
			dbsColls.Add(("db1", "profiles"));
			dbsColls.Add(("db1", "progress"));
			IReadOnlyList<ValueTuple<string, string>> dbsCollsRo = dbsColls.AsReadOnly();

			CosmosClient client = await CosmosClient.CreateAndInitializeAsync("foo", dbsCollsRo, clientOptions);

			return client;
		}
	}
}
