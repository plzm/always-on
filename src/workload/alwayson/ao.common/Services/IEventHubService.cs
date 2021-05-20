using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ao.common
{
	public interface IEventHubService
	{
		Task SendAsync<T>(T message);
		Task SendAsync(string messageBody, string messageType);
		Task SendAsync(IEnumerable<string> messageBodies, string messageType);
	}
}