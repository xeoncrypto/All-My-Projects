using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BitfinexTradingBot.JsonBase
{
	public class ErrorResponse
	{
		[JsonProperty("message")]
		public string Message { get; set; }
	}
}
