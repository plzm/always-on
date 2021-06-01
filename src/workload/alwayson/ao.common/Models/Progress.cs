using System;
using System.Text.Json.Serialization;

namespace ao.common
{
	public class Progress : IItem
	{
		[JsonPropertyName("id")]
		public string Id { get; set; } = Guid.NewGuid().ToString();
		public string Handle { get; set; }
		public long Xp { get; set; }
	}
}
