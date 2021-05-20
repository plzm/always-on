namespace ao.common
{
	public record Profile
	{
		public string Id { get; init; }
		public string AvatarUrl { get; init; }
		public long TotalXp { get; init; }
	}
}
