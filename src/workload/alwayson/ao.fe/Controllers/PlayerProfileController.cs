using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using ao.common;

namespace ao.fe.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class PlayerProfileController : ControllerBase
	{
		private readonly ICosmosDbService _cosmosDbService;

		public PlayerProfileController(ICosmosDbService cosmosDbService) => _cosmosDbService = cosmosDbService;

		[HttpGet("{id}")]
		public async Task<string> Get(string id)
		{
			return await _cosmosDbService.GetPlayerProfileAsync(id);
		}
	}
}
