using System;
using ao.common;

namespace ao.be
{
	class Program
	{
		static void Main(string[] args)
		{
			var processor = new EventHubReceiverService();
			processor.RunAsync().Wait();
		}
	}
}
