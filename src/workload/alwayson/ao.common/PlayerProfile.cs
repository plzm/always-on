namespace ao.common
{
	public record PlayerProfile
	{
		public string? Id { get; init; }
		public string? AvatarUrl { get; init; }
		public long TotalXp { get; init; }
	}
}
