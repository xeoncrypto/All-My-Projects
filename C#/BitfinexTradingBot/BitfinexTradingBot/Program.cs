using BitfinexTradingBot.Indicators;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using TicTacTec.TA.Library;

namespace BitfinexTradingBot
{
	class Program
	{
		[STAThread]
		static void Main()
		{
			Exchange.Setup();
			Exchange.Start();
		}
	}
}
