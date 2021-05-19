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

		public CosmosClient CosmosClient { get; private set; }

		public Container ProfileContainer { get; private set; }
		public Container ProgressContainer { get; private set; }

		public static async Task<ICosmosDbService> GetInstance(IConfiguration configuration, IHttpClientFactory httpClientFactory = null)
		{
			CosmosDbService result = new CosmosDbService()
			{
				ConnectionString = configuration["CosmosDbConnectionString"],
				DatabaseName = configuration["CosmosDbDatabaseName"],
				ProfileContainerName = configuration["CosmosDbProfileContainerName"],
				ProgressContainerName = configuration["CosmosDbProgressContainerName"]
			};

			CosmosClientOptions clientOptions = new CosmosClientOptions()
			{
				ConnectionMode = ConnectionMode.Direct,
				ConsistencyLevel = ConsistencyLevel.Eventual,
				EnableContentResponseOnWrite = false,
				HttpClientFactory = (httpClientFactory != null ? httpClientFactory.CreateClient : null)
			};

			// This list is to pre-warm the Cosmos client
			List<ValueTuple<string, string>> containers = new List<(string, string)>();
			containers.Add((result.DatabaseName, result.ProfileContainerName));
			containers.Add((result.DatabaseName, result.ProgressContainerName));

			// Get the actual Cosmos DB client
			result.CosmosClient = await CosmosClient.CreateAndInitializeAsync(result.ConnectionString, containers.AsReadOnly(), clientOptions);

			// Container proxies
			result.ProfileContainer = result.CosmosClient.GetContainer(result.DatabaseName, result.ProfileContainerName);
			result.ProgressContainer = result.CosmosClient.GetContainer(result.DatabaseName, result.ProgressContainerName);

			return result;
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
