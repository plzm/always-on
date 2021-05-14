using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ao.common;

namespace ao.fe
{
	public interface ICosmosDbService
	{
		Task<PlayerProfile> GetPlayerProfileAsync(string id);
	}
}
