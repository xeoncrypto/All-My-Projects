using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BitfinexTradingBot
{
	public class Events
	{
		public static event EventHandler<CandleEventArgs> CandleEvent;

		public static void OnCandleEvent(CandleEventArgs e)
		{
			CandleEvent?.Invoke(typeof(Events), e);
		}
	}
}
