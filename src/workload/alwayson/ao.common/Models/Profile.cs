namespace ao.common
{
	public record Profile : IItem
	{
		public string Id { get; set; }
		public string AvatarUrl { get; set; }
		public long TotalXp { get; set; }
	}
}
