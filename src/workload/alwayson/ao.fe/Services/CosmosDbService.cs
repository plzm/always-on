using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Fluent;
using ao.common;
using Microsoft.Extensions.Configuration;
using System.Net.Http;

namespace ao.fe
{
	public class CosmosDbService : ICosmosDbService
	{
		public string ConnectionString { get; private set; }
		public string DatabaseName { get; private set; }
		public string ProfileContainerName { get; private set; }
		public string ProgressContainerName { get; private set; }

		public IHttpClientFactory HttpClientFactory { get; private set; }

		public CosmosClient CosmosClient { get; private set; }

		public Container ProfileContainer { get; private set; }
		public Container ProgressContainer { get; private set; }

		private CosmosDbService() { }

		public CosmosDbService(string connectionString, string databaseName, string profileContainerName, string progressContainerName, IHttpClientFactory httpClientFactory = null)
		{
			this.ConnectionString = connectionString;
			this.DatabaseName = databaseName;
			this.ProfileContainerName = profileContainerName;
			this.ProgressContainerName = progressContainerName;
			this.HttpClientFactory = httpClientFactory;

			Initialize().Wait();
		}

		private async Task Initialize()
		{
			// Cosmos DB client configuration options
			CosmosClientOptions clientOptions = new CosmosClientOptions()
			{
				ConnectionMode = ConnectionMode.Direct,
				ConsistencyLevel = ConsistencyLevel.Eventual,
				EnableContentResponseOnWrite = false,
				HttpClientFactory = (this.HttpClientFactory != null ? this.HttpClientFactory.CreateClient : null)
			};

			// This list is to pre-warm the Cosmos DB client
			List<ValueTuple<string, string>> containers = new List<(string, string)>();
			containers.Add((this.DatabaseName, this.ProfileContainerName));
			containers.Add((this.DatabaseName, this.ProgressContainerName));

			// Get the actual Cosmos DB client
			this.CosmosClient = await CosmosClient.CreateAndInitializeAsync(this.ConnectionString, containers.AsReadOnly(), clientOptions);

			// Container proxies
			this.ProfileContainer = this.CosmosClient.GetContainer(this.DatabaseName, this.ProfileContainerName);
			this.ProgressContainer = this.CosmosClient.GetContainer(this.DatabaseName, this.ProgressContainerName);
		}

		public async Task<PlayerProfile> GetPlayerProfileAsync(string id)
		{
			try
			{
				ItemResponse<PlayerProfile> response = await this.ProfileContainer.ReadItemAsync<PlayerProfile>(id, new PartitionKey(id));

				return response.Resource;
			}
			catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
			{
				return null;
			}
		}
	}
}
