using System;

namespace ao.common
{
	public class Progress
	{
		public string Id { get; init; }
		public long Xp { get; init; }
		public string Timestamp { get; init; } = DateTime.UtcNow.ToString("O");
	}
}
