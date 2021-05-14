using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ao.fe.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class ConfigController : ControllerBase
	{
		// GET api/<ConfigController>/5
		[HttpGet("{key}")]
		public string Get(string key)
		{
			string result = Environment.GetEnvironmentVariable(key);

			return (string.IsNullOrWhiteSpace(result) ? "Not Found!" : result);
		}
	}
}
