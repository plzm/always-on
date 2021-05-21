using System;

namespace ao.common
{
	public class Progress : IItem
	{
		public string Id { get; set; }
		public long Xp { get; set; }
		public string Timestamp { get; set; } = DateTime.UtcNow.ToString("O");
	}
}
