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
		private readonly IEventHubSenderService _eventHubSenderService;

		public ProfileController(ICosmosDbService cosmosDbService, IEventHubSenderService eventHubSenderService)
		{
			_cosmosDbService = cosmosDbService;
			_eventHubSenderService = eventHubSenderService;
		}

		[HttpGet("{handle}")]
		public async Task<Profile> Get(string handle)
		{
			return await _cosmosDbService.GetPlayerProfileAsync(handle);
		}

		[HttpPost]
		public async Task Post([FromBody] Profile value)
		{
			await _eventHubSenderService.SendAsync<Profile>(value);
		}
	}
}
