using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ao.common;

namespace ao.common
{
	public interface ICosmosDbService
	{
		Task<Profile> GetPlayerProfileAsync(string handle);
	}
}
