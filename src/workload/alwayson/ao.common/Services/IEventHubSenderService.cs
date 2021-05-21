using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ao.common
{
	public interface IEventHubSenderService
	{
		Task SendAsync<T>(T message, List<ValueTuple<string, string>> metadata = null)
			where T : IItem;

		Task SendAsync<T>(IEnumerable<T> messages, List<ValueTuple<string, string>> metadata = null)
			where T : IItem;
	}
}