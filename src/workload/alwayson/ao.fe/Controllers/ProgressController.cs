using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ao.common;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ao.fe.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class ProgressController : ControllerBase
	{
		private readonly IEventHubSenderService _eventHubSenderService;

		public ProgressController(IEventHubSenderService eventHubSenderService)
		{
			_eventHubSenderService = eventHubSenderService;
		}

		[HttpPost]
		public async Task Post([FromBody] Progress value)
		{
			await _eventHubSenderService.SendAsync<Progress>(value);
		}
	}
}
