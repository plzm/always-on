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
		[HttpGet("{id}")]
		public string Get(string id)
		{
			return $"{{\"foo\": \"{id}\"}}";
		}
	}
}
