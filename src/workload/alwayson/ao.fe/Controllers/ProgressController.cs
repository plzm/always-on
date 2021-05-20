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
		private readonly IEventHubService _eventHubService;

		public ProgressController(IEventHubService eventHubService)
		{
			_eventHubService = eventHubService;
		}

		[HttpPost]
		public async Task Post([FromBody] Progress value)
		{
			await _eventHubService.SendAsync<Progress>(value);
		}
	}
}
