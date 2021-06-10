using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Azure.Messaging.EventHubs.Processor;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;

namespace ao.common
{
	public class EventHubReceiverService
	{
		public string StorageAccountConnectionString { get; private set; }
		public string StorageAccountName { get; private set; }
		public string StorageContainerName { get; private set; }

		public string EventHubConnectionString { get; private set; }
		public string EventHubName { get; private set; }
		public string EventHubConsumerGroup { get; private set; }

		public TelemetryClient TelemetryClient { get; private set; }
		private CosmosDbService CosmosDbService { get; set; }
		public BlobContainerClient BlobContainerClient { get; private set; }
		public EventProcessorClient EventProcessorClient { get; private set; }

		public int EventHubReceiverBatchSize { get; set; } = 10;
		private bool CheckpointNeeded { get; set; } = false;
		private ConcurrentDictionary<string, List<EventData>> PartitionEventBatches = new ConcurrentDictionary<string, List<EventData>>();

		private readonly string _messageTypeProfile = typeof(Profile).Name;
		private readonly string _messageTypeProgress = typeof(Progress).Name;

		public EventHubReceiverService()
		{
			this.GetConfig();

			this.Initialize();
		}

		public EventHubReceiverService(TelemetryClient telemetryClient)
		{
			this.TelemetryClient = telemetryClient;

			this.GetConfig();

			this.Initialize();
		}

		public EventHubReceiverService
		(
			string storageAccountConnectionString,
			string storageAccountName,
			string storageContainerName,
			string eventHubConnectionString,
			string eventHubName,
			string eventHubConsumerGroup,
			TelemetryClient telemetryClient = null
		)
		{
			this.StorageAccountConnectionString = storageAccountConnectionString;
			this.StorageAccountName = storageAccountName;
			this.StorageContainerName = storageContainerName;

			this.EventHubConnectionString = eventHubConnectionString;
			this.EventHubName = eventHubName;
			this.EventHubConsumerGroup = eventHubConsumerGroup;

			this.TelemetryClient = telemetryClient;

			this.Initialize();
		}

		private void GetConfig()
		{
			this.StorageAccountConnectionString = Environment.GetEnvironmentVariable("StorageAccountConnString");
			this.StorageAccountName = Environment.GetEnvironmentVariable("StorageAccountName");
			this.StorageContainerName = Environment.GetEnvironmentVariable("StorageContainerName");

			this.EventHubConnectionString = Environment.GetEnvironmentVariable("EventHubConnectionString");
			this.EventHubName = Environment.GetEnvironmentVariable("EventHubName");
			this.EventHubConsumerGroup = Environment.GetEnvironmentVariable("EventHubConsumerGroup");

			bool thatWorked = Int32.TryParse(Environment.GetEnvironmentVariable("EventHubReceiverBatchSize"), out int ehBatchSize);

			if (thatWorked)
				this.EventHubReceiverBatchSize = ehBatchSize;
		}

		private void Initialize()
		{
			this.CosmosDbService = new CosmosDbService(this.TelemetryClient);

			this.BlobContainerClient = new BlobContainerClient(this.StorageAccountConnectionString, this.StorageContainerName);

			this.EventProcessorClient = new EventProcessorClient(this.BlobContainerClient, this.EventHubConsumerGroup, this.EventHubConnectionString, this.EventHubName);

			this.TelemetryClient?.TrackTrace("EventHubReceiverService.Initialize:Complete", SeverityLevel.Information);
		}

		public async Task RunAsync()
		{
			try
			{
				using var cancellationSource = new CancellationTokenSource();

				this.EventProcessorClient.ProcessEventAsync += processEventHandler;
				this.EventProcessorClient.ProcessErrorAsync += processErrorHandler;

				try
				{
					await this.EventProcessorClient.StartProcessingAsync(cancellationSource.Token);
					await Task.Delay(Timeout.Infinite, cancellationSource.Token);
				}
				catch (TaskCanceledException tcex)
				{
					// This is expected if the cancellation token is signaled.

					this.TelemetryClient.TrackException(tcex);
				}
				finally
				{
					// This may take up to the length of time defined
					// as part of the configured TryTimeout of the processor;
					// by default, this is 60 seconds.

					this.TelemetryClient?.TrackTrace("EventHubReceiverService.RunAsync:Finally", SeverityLevel.Information);

					await this.EventProcessorClient.StopProcessingAsync();
				}
			}
			catch (Exception ex)
			{
				this.TelemetryClient.TrackException(ex);
			}
			finally
			{
				this.EventProcessorClient.ProcessEventAsync -= processEventHandler;
				this.EventProcessorClient.ProcessErrorAsync -= processErrorHandler;

				this.TelemetryClient?.TrackTrace("EventHubReceiverService.RunAsync:Complete", SeverityLevel.Information);
			}
		}

		private void ProcessEventBatch(List<EventData> partitionBatch, PartitionContext partitionContext, CancellationToken cancellationToken)
		{
			List<Task> tasks = new List<Task>();

			this.TelemetryClient?.TrackTrace("EventHubReceiverService.ProcessEventBatch:ProcessTasks:Start", SeverityLevel.Information);

			foreach (EventData eventData in partitionBatch)
			{
				tasks.Add(Task.Run(() => ProcessEventAsync(eventData), cancellationToken));
			}

			Task t = Task.WhenAll(tasks);

			try
			{
				t.Wait();
			}
			catch (Exception ex)
			{
				this.TelemetryClient?.TrackException(ex);
			}
			finally
			{
				this.TelemetryClient?.TrackTrace($"EventHubReceiverService.ProcessEventBatch:ProcessTasks:Complete:{t.Status}", SeverityLevel.Information);
			}
		}

		private async Task ProcessEventAsync(EventData eventData)
		{
			string handle = eventData.Properties[Constants.HANDLE].ToString();
			string messageType = eventData.Properties[Constants.MESSAGE_TYPE].ToString();

			byte[] eventBodyBytes = eventData.EventBody.ToArray();

			this.TelemetryClient?.TrackTrace($"EventHubReceiverService.ProcessEventAsync:{handle}:Start", SeverityLevel.Information);

			MemoryStream stream = new MemoryStream(eventBodyBytes);

			if (messageType.Equals(_messageTypeProfile))
			{
				await this.CosmosDbService.SaveProfileAsync(handle, stream);
			}
			else if (messageType.Equals(_messageTypeProgress))
			{
				await this.CosmosDbService.SaveProgressAsync(handle, stream);
			}

			this.TelemetryClient?.TrackTrace($"EventHubReceiverService.ProcessEventAsync:{handle}:Complete", SeverityLevel.Information);

			// Typed
			//if (messageType.Equals(_messageTypeProfile))
			//{
			//	Profile item = JsonSerializer.Deserialize<Profile>(eventBodyBytes);
			//	await this.CosmosDbService.SaveProfile(item);
			//}
			//else if (messageType.Equals(_messageTypeProgress))
			//{
			//	Progress item = JsonSerializer.Deserialize<Progress>(eventBodyBytes);
			//	await this.CosmosDbService.SaveProgress(item);
			//}
		}

		async Task processEventHandler(ProcessEventArgs args)
		{
			try
			{
				if (args.CancellationToken.IsCancellationRequested)
					return;

				string partition = args.Partition.PartitionId;

				List<EventData> partitionBatch = this.PartitionEventBatches.GetOrAdd(partition, new List<EventData>());

				partitionBatch.Add(args.Data);

				this.TelemetryClient?.TrackTrace($"EventHubReceiverService.processEventHandler:CurrentBatchCount={partitionBatch.Count}", SeverityLevel.Information);

				if (partitionBatch.Count >= this.EventHubReceiverBatchSize)
				{
					this.TelemetryClient?.TrackTrace($"EventHubReceiverService.processEventHandler:ProcessBatch:Start", SeverityLevel.Information);

					ProcessEventBatch(partitionBatch, args.Partition, args.CancellationToken);

					this.CheckpointNeeded = true;
					partitionBatch.Clear();

					this.TelemetryClient?.TrackTrace($"EventHubReceiverService.processEventHandler:ProcessBatch:Complete", SeverityLevel.Information);
				}

				if (this.CheckpointNeeded)
				{
					this.TelemetryClient?.TrackTrace($"EventHubReceiverService.processEventHandler:UpdateCheckpoint:Start", SeverityLevel.Information);

					await args.UpdateCheckpointAsync();
					this.CheckpointNeeded = false;

					this.TelemetryClient?.TrackTrace($"EventHubReceiverService.processEventHandler:UpdateCheckpoint:Complete", SeverityLevel.Information);
				}
			}
			catch (Exception ex)
			{
				this.TelemetryClient.TrackException(ex);
				// TODO better handling/logging
				// HandleProcessingException(args, ex);
			}
		}

		Task processErrorHandler(ProcessErrorEventArgs args)
		{
			try
			{
				// TODO handle the error as appropriate for the application

				Dictionary<string, string> errorProps = new Dictionary<string, string>();
				errorProps.Add("Operation", args.Operation);
				errorProps.Add("Exception", args.Exception.Message);
				this.TelemetryClient.TrackEvent("EventHubReceiverService.processErrorHandler", errorProps);
				this.TelemetryClient.TrackException(args.Exception);
			}
			catch (Exception ex)
			{
				this.TelemetryClient.TrackException(ex);
			}

			return Task.CompletedTask;
		}
	}
}
