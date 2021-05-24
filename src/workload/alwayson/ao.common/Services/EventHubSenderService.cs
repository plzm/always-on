using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text.Json;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;

namespace ao.common
{
	public class EventHubSenderService : IEventHubSenderService
	{
		public string NamespaceConnectionString { get; private set; }
		public string EventHubName { get; private set; }

		public EventHubProducerClient EventHubProducerClient { get; private set; }

		private EventHubSenderService() { }

		public EventHubSenderService(string namespaceConnectionString, string eventHubName)
		{
			this.NamespaceConnectionString = namespaceConnectionString;
			this.EventHubName = eventHubName;

			Initialize();
		}

		private void Initialize()
		{
			EventHubConnectionOptions connectionOptions = new EventHubConnectionOptions()
			{
				TransportType = EventHubsTransportType.AmqpTcp
			};

			EventHubsRetryOptions retryOptions = new EventHubsRetryOptions()
			{
				MaximumRetries = 1,
				Mode = EventHubsRetryMode.Exponential
			};

			EventHubProducerClientOptions clientOptions = new EventHubProducerClientOptions()
			{
				ConnectionOptions = connectionOptions,
				RetryOptions = retryOptions
			};

			this.EventHubProducerClient = new EventHubProducerClient(this.NamespaceConnectionString, this.EventHubName, clientOptions);
		}

		public async Task SendAsync<T>(T message, IEnumerable<ValueTuple<string, string>> metadata = null)
			where T : IItem
		{
			if (message == null)
				return;

			await SendAsync(new T[] { message }, metadata);
		}

		public async Task SendAsync<T>(IEnumerable<T> messages, IEnumerable<ValueTuple<string, string>> metadata = null)
			where T : IItem
		{
			if (messages == null)
				return;

			var eventsToSend = messages.Select(m => GetEventData(m, metadata));

			await this.EventHubProducerClient.SendAsync(eventsToSend);
		}

		private EventData GetEventData<T>(T message, IEnumerable<ValueTuple<string, string>> metadata = null)
			where T : IItem
		{
			var result = new EventData(new BinaryData(message));

			result.Properties.Add(Constants.HANDLE, message.Handle);
			result.Properties.Add(Constants.MESSAGE_TYPE, typeof(T).Name);

			if (metadata != null)
			{
				foreach (var tuple in metadata)
					result.Properties.Add(tuple.Item1, tuple.Item2);
			}

			return result;
		}
	}
}
