using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text.Json;
using System.Text.Json.Serialization;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using ao.common;

namespace ao.common
{
	public class EventHubService : IEventHubService
	{
		private const string MESSAGE_TYPE = "MessageType";

		public string NamespaceConnectionString { get; private set; }
		public string EventHubName { get; private set; }

		public EventHubProducerClient EventHubProducerClient { get; private set; }

		private EventHubService() { }

		public EventHubService(string namespaceConnectionString, string eventHubName)
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

		public async Task SendAsync<T>(T message)
		{
			string json = JsonSerializer.Serialize(message);

			await SendAsync(new string[] { json }, typeof(T).Name);
		}

		public async Task SendAsync(string messageBody, string messageType)
		{
			if (string.IsNullOrWhiteSpace(messageBody))
				return;

			await SendAsync(new string[] { messageBody }, messageType);
		}

		public async Task SendAsync(IEnumerable<string> messageBodies, string messageType)
		{
			if (messageBodies == null)
				return;

			var eventsToSend = messageBodies.Select(mb => GetEventData(mb, messageType));

			await this.EventHubProducerClient.SendAsync(eventsToSend);
		}

		private EventData GetEventData(string messageBody, string messageType)
		{
			var result = new EventData(new BinaryData(messageBody));
			result.Properties.Add(MESSAGE_TYPE, messageType);
			return result;
		}
	}
}
