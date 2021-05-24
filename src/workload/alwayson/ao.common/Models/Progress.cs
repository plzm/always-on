using System;

namespace ao.common
{
	public class Progress : IItem
	{
		public string id { get; } = Guid.NewGuid().ToString();
		public string Handle { get; set; }
		public long Xp { get; set; }
	}
}
