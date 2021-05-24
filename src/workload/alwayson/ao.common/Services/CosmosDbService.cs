using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Azure.Cosmos;
using ao.common;

namespace ao.common
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

		public CosmosDbService()
		{
			GetConfig();

			Initialize().Wait();
		}

		public CosmosDbService(string connectionString, string databaseName, string profileContainerName, string progressContainerName, IHttpClientFactory httpClientFactory = null)
		{
			this.ConnectionString = connectionString;
			this.DatabaseName = databaseName;
			this.ProfileContainerName = profileContainerName;
			this.ProgressContainerName = progressContainerName;
			this.HttpClientFactory = httpClientFactory;

			Initialize().Wait();
		}

		private void GetConfig()
		{
			this.ConnectionString = Environment.GetEnvironmentVariable("CosmosDbConnectionString");
			this.DatabaseName = Environment.GetEnvironmentVariable("CosmosDbDatabaseName");
			this.ProfileContainerName = Environment.GetEnvironmentVariable("CosmosDbProfileContainerName");
			this.ProgressContainerName = Environment.GetEnvironmentVariable("CosmosDbProgressContainerName");
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

		public async Task<Profile> GetPlayerProfileAsync(string handle)
		{
			try
			{
				ItemResponse<Profile> response = await this.ProfileContainer.ReadItemAsync<Profile>(handle, new PartitionKey(handle));

				return response.Resource;
			}
			catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
			{
				return null;
			}
		}

		public async Task SaveProfile(string handle, Stream profile)
		{
			ResponseMessage response = await this.ProfileContainer.UpsertItemStreamAsync(profile, new PartitionKey(handle));
		}

		public async Task SaveProfile(Profile profile)
		{
			ItemResponse<Profile> response = await this.ProfileContainer.UpsertItemAsync<Profile>(profile, new PartitionKey(profile.Handle));
		}

		public async Task SaveProgress(string handle, Stream progress)
		{
			ResponseMessage response = await this.ProgressContainer.CreateItemStreamAsync(progress, new PartitionKey(handle));
		}

		public async Task SaveProgress(Progress progress)
		{
			ItemResponse<Progress> response = await this.ProgressContainer.CreateItemAsync<Progress>(progress, new PartitionKey(progress.Handle));
		}
	}
}
