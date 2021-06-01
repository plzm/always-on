using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Microsoft.ApplicationInsights;

namespace ao.common
{
	public class EventHubSenderService : IEventHubSenderService
	{
		public string EventHubConnectionString { get; private set; }
		public string EventHubName { get; private set; }

		public TelemetryClient TelemetryClient { get; private set; }

		public EventHubProducerClient EventHubProducerClient { get; private set; }

		public EventHubSenderService()
		{
			this.GetConfig();

			this.Initialize();
		}

		public EventHubSenderService(TelemetryClient telemetryClient)
		{
			this.TelemetryClient = telemetryClient;

			this.GetConfig();

			this.Initialize();
		}

		public EventHubSenderService(string eventHubConnectionString, string eventHubName, TelemetryClient telemetryClient = null)
		{
			this.EventHubConnectionString = eventHubConnectionString;
			this.EventHubName = eventHubName;

			this.TelemetryClient = telemetryClient;

			this.Initialize();
		}

		private void GetConfig()
		{
			this.EventHubConnectionString = Environment.GetEnvironmentVariable("EventHubConnectionString");
			this.EventHubName = Environment.GetEnvironmentVariable("EventHubName");
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

			this.EventHubProducerClient = new EventHubProducerClient(this.EventHubConnectionString, this.EventHubName, clientOptions);
		}

		public async Task SendAsync<T>(T message, IEnumerable<ValueTuple<string, string>> metadata = null)
			where T : IItem
		{
			if (message == null)
				return;

			await this.SendAsync(new T[] { message }, metadata);
		}

		public async Task SendAsync<T>(IEnumerable<T> messages, IEnumerable<ValueTuple<string, string>> metadata = null)
			where T : IItem
		{
			if (messages == null)
				return;

			var eventsToSend = messages.Select(m => this.GetEventData(m, metadata));

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
