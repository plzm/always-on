using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Azure.Messaging.EventHubs.Processor;
using System.Threading;

namespace ao.be
{
    public class Processor
    {
        public string StorageAccountConnectionString { get; private set; }
        public string StorageAccountName { get; private set; }
        public string StorageContainerName { get; private set; }

        public string EventHubConnectionString { get; private set; }
        public string EventHubName { get; private set; }
        public string EventHubConsumerGroup { get; private set; }

        public BlobContainerClient BlobContainerClient { get; private set; }

		public EventProcessorClient EventProcessorClient { get; private set; }

        public int EventHubBatchSize { get; set; } = 2;
        private bool CheckpointNeeded { get; set; } = false;
        private ConcurrentDictionary<string, List<EventData>> PartitionEventBatches = new ConcurrentDictionary<string, List<EventData>>();

        //private ConcurrentDictionary<string, int> PartitionEventCount = new ConcurrentDictionary<string, int>();

        public Processor()
		{
			GetConfig();

			Initialize();

            Run().Wait();
		}

		private void GetConfig()
		{
			this.StorageAccountConnectionString = Environment.GetEnvironmentVariable("StorageAccountConnString");
			this.StorageAccountName = Environment.GetEnvironmentVariable("StorageAccountName");
			this.StorageContainerName = Environment.GetEnvironmentVariable("StorageContainerName");

			this.EventHubConnectionString = Environment.GetEnvironmentVariable("EventHubConnectionString");
			this.EventHubName = Environment.GetEnvironmentVariable("EventHubName");
			this.EventHubConsumerGroup = Environment.GetEnvironmentVariable("EventHubConsumerGroup");
		}

		private void Initialize()
		{
			this.BlobContainerClient = new BlobContainerClient(this.StorageAccountConnectionString, this.StorageContainerName);

			this.EventProcessorClient = new EventProcessorClient(this.BlobContainerClient, this.EventHubConsumerGroup, this.EventHubConnectionString, this.EventHubName);
		}

        private async Task Run()
		{
            try
            {
                using var cancellationSource = new CancellationTokenSource();
                //cancellationSource.CancelAfter(TimeSpan.FromSeconds(30));

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
                }
                finally
                {
                    // This may take up to the length of time defined
                    // as part of the configured TryTimeout of the processor;
                    // by default, this is 60 seconds.

                    await this.EventProcessorClient.StopProcessingAsync();
                }
            }
            catch (Exception ex)
            {
                // The processor will automatically attempt to recover from any
                // failures, either transient or fatal, and continue processing.
                // Errors in the processor's operation will be surfaced through
                // its error handler.
                //
                // If this block is invoked, then something external to the
                // processor was the source of the exception.
            }
            finally
            {
                this.EventProcessorClient.ProcessEventAsync -= processEventHandler;
                this.EventProcessorClient.ProcessErrorAsync -= processErrorHandler;
            }
        }

        private async Task ProcessEventBatchAsync(List<EventData> partitionBatch, PartitionContext partitionContext, CancellationToken cancellationToken)
		{
            try
			{
                foreach (EventData eventData in partitionBatch)
				{
                    byte[] eventBodyBytes = eventData.EventBody.ToArray();
                    Debug.WriteLine($"Read event of length { eventBodyBytes.Length } from { partitionContext.PartitionId }");

                    string eventBody = Encoding.UTF8.GetString(eventBodyBytes);
                    Debug.WriteLine(eventBody);
                }
			}
            catch (Exception ex)
			{
                // TODO
			}
		}

        async Task processEventHandler(ProcessEventArgs args)
        {
            try
            {
                if (args.CancellationToken.IsCancellationRequested)
                {
                    return;
                }

                string partition = args.Partition.PartitionId;

                List<EventData> partitionBatch = this.PartitionEventBatches.GetOrAdd(partition, new List<EventData>());

                partitionBatch.Add(args.Data);

                if (partitionBatch.Count >= this.EventHubBatchSize)
                {
                    await ProcessEventBatchAsync(partitionBatch, args.Partition, args.CancellationToken);

                    this.CheckpointNeeded = true;
                    partitionBatch.Clear();
                }

                if (this.CheckpointNeeded)
                {
                    await args.UpdateCheckpointAsync();
                    this.CheckpointNeeded = false;
                }
            }
            catch (Exception ex)
            {
                // TODO better handling/logging
                // HandleProcessingException(args, ex);
            }
        }

        Task processErrorHandler(ProcessErrorEventArgs args)
        {
            try
            {
                // TODO handle the error as appropriate for the application

                Debug.WriteLine("Error in the EventProcessorClient");
                Debug.WriteLine($"\tOperation: { args.Operation }");
                Debug.WriteLine($"\tException: { args.Exception }");
                Debug.WriteLine("");
            }
            catch (Exception ex)
            {
                // TODO better handling/logging
                // HandleErrorProcessError(args, ex);
            }

            return Task.CompletedTask;
        }
    }
}
