using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Fluent;
using ao.common;

namespace ao.fe
{
	public class CosmosDbService : ICosmosDbService
	{
		private static Container _profileContainer;
		private static Container _progressContainer;

		public CosmosDbService(CosmosClient cosmosClient, string databaseName, string profileContainerName, string progressContainerName)
		{
			_profileContainer = cosmosClient.GetContainer(databaseName, profileContainerName);
			_progressContainer = cosmosClient.GetContainer(databaseName, progressContainerName);
		}

		public async Task<PlayerProfile> GetPlayerProfileAsync(string id)
		{
			try
			{
				ItemResponse<PlayerProfile> response = await _profileContainer.ReadItemAsync<PlayerProfile>(id, new PartitionKey(id));

				return response.Resource;
			}
			catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
			{
				return null;
			}
		}
	}
}
