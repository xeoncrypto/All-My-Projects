using System;
using System.Collections.Generic;
using System.Threading;
using BitfinexTradingBot.JsonBase;
using BitfinexTradingBot.Strategies;

namespace BitfinexTradingBot
{
	public class Exchange
	{
		// Owned currencies, e.g. BTC, ETH, USD and how much
		public static Dictionary<string, float> Portfolio = new Dictionary<string, float>();
		// Pair to Candles, e.g. tBTCUSD -> all candles for USD-BTC
		public static Dictionary<string, List<Candle>> Candles = new Dictionary<string, List<Candle>>();
		// overview of all strategies
		public static List<Strategy> strategies = new List<Strategy>();

		public static void Setup()
		{
			Portfolio.Add("BTC", 0);
			Portfolio.Add("ETH", 0);
			Portfolio.Add("LTC", 0);
			Portfolio.Add("ETC", 0);
			Portfolio.Add("RRT", 0);
			Portfolio.Add("ZEC", 0);
			Portfolio.Add("XMR", 0);
			Portfolio.Add("DSH", 0);
			Portfolio.Add("BCC", 0);
			Portfolio.Add("BCU", 0);
			Portfolio.Add("XRP", 0);
			Portfolio.Add("IOT", 0);
			Portfolio.Add("EOS", 0);
			Portfolio.Add("SAN", 0);
			Portfolio.Add("OMG", 0);
			Portfolio.Add("BCH", 0);
			Portfolio.Add("NEO", 0);
			Portfolio.Add("ETP", 0);
			Portfolio.Add("QTM", 0);
			Portfolio.Add("BT1", 0);
			Portfolio.Add("BT2", 0);
			Portfolio.Add("AVT", 0);
			Portfolio.Add("EDO", 0);
			Portfolio.Add("BTG", 0);
			Portfolio.Add("DAT", 0);
			Portfolio.Add("QSH", 0);
			Portfolio.Add("YYW", 0);

			Portfolio.Add("USD", 0);

			// Get Portfolio from Exchange
			BitfinexHandler.RetrieveBalances();
		}

		public static void Start()
		{
			Events.CandleEvent += Events_CandleEvent;
			strategies.Add(new BBBullMarket());

			while (true)
			{
				foreach (string p in Candles.Keys)
				{
					int secToWait = 120;

					if (Candles[p][0].Resolution == "1m")
						secToWait = 120;
					else if (Candles[p][0].Resolution == "5m")
						secToWait = 600;

					if (Candles[p][Candles[p].Count - 1].time.AddSeconds(secToWait) < DateTime.Now)
					{
						BitfinexCandleGetter.GetNewCandle(Candles[p][0].Resolution, p, Candles[p][0].Symbol);
						Thread.Sleep(2000);
					}
				}

				Thread.Sleep(500);
			}
		}

		private static void Events_CandleEvent(object sender, CandleEventArgs e)
		{
			Console.WriteLine(e.Candle.ToString());

			if (e.Candle.insert)
				Candles[e.Candle.Pair].Insert(0, e.Candle);
			else
				Candles[e.Candle.Pair].Add(e.Candle);
		}

		public static void AddTradingPair(string resolution, string pair, string symbol)
		{
			if (Candles.ContainsKey(pair))
				return;

			BitfinexCandleGetter.GetNewCandle(resolution, pair, symbol);
		}
	}
}
