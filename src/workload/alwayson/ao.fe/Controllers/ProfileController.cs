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
	public class ProfileController : ControllerBase
	{
		private readonly ICosmosDbService _cosmosDbService;
		private readonly IEventHubService _eventHubService;

		public ProfileController(ICosmosDbService cosmosDbService, IEventHubService eventHubService)
		{
			_cosmosDbService = cosmosDbService;
			_eventHubService = eventHubService;
		}

		[HttpGet("{id}")]
		public async Task<Profile> Get(string id)
		{
			return await _cosmosDbService.GetPlayerProfileAsync(id);
		}

		[HttpPost]
		public async Task Post([FromBody] Profile value)
		{
			await _eventHubService.SendAsync<Profile>(value);
		}
	}
}
