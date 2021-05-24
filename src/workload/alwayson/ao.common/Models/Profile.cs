using System.Text.Json.Serialization;

namespace ao.common
{
	public record Profile : IItem
	{
		[JsonPropertyName("id")]
		public string Id => this.Handle;
		public string Handle { get; set; }
		public string AvatarUrl { get; set; }
		public long TotalXp { get; set; }
	}
}
