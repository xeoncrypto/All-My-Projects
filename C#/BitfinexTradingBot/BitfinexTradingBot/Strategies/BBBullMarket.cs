using BitfinexTradingBot.Indicators;
using System;
using System.Collections.Generic;

namespace BitfinexTradingBot.Strategies
{
	public class StrategyProperties
	{
		public readonly float magicBuyValue = 1.00048f;      // Buy on next long candle if this percentage above Lower-BB is reached
		public readonly float magicSellValue = 0.9987f;      // Sell on next short candle if this percentage of Upper-BB is reached
		public readonly float minStepGain = 1.005f;          // 1.005 equals 100.5% - Sell if price is 0.5 percent higher
		public readonly float downTrendStrength = -11.478f;  // The min slope of downtrend. Everything lower as this will be considered a downtrend
		public readonly int maxHoldTime = 60;

		public bool boughtOnDowntrend;
		public float lastBuyPrice;
		public DateTime lastBuyTime;

		public StrategyProperties(float magicBuyValue, float magicSellValue, float minStepGain, float downTrendStrength, int maxHoldTime)
		{
			this.magicBuyValue = magicBuyValue;
			this.magicSellValue = magicSellValue;
			this.minStepGain = minStepGain;
			this.downTrendStrength = downTrendStrength;
			this.maxHoldTime = maxHoldTime;
		}
	}

	public class BBBullMarket : Strategy
	{
		private Dictionary<string, StrategyProperties> PairProperties = new Dictionary<string, StrategyProperties>();

		private Dictionary<string, BBand> PairBB;
		// How much each pair is bought for in primary currency e.g. USD 
		public static readonly float BuyQty = 116;

		public BBBullMarket()
		{
			PairBB = new Dictionary<string, BBand>();

			PairProperties.Add("tBTCUSD", new StrategyProperties(1.00048f, 0.9987f, 1.005f, -11.478f, 60));
			AddTradingPair("1m", "tBTCUSD", "BTC");

			PairProperties.Add("tETHUSD", new StrategyProperties(1.00048f, 0.9987f, 1.005f, -11.478f, 120));
			AddTradingPair("5m", "tETHUSD", "ETH");

			PairProperties.Add("tLTCUSD", new StrategyProperties(1.00048f, 0.9987f, 1.005f, -11.478f, 120));
			AddTradingPair("5m", "tLTCUSD", "LTC");

			PairProperties.Add("tBCHUSD", new StrategyProperties(1.00048f, 0.9987f, 1.005f, -11.478f, 120));
			AddTradingPair("5m", "tBCHUSD", "BCH");

			// Always make sure to first create the indicators and then subscribe to the event
			foreach (string s in Candles.Keys)
				PairBB.Add(s, new BBand(s, 20, 2));

			Events.CandleEvent += Events_CandleEvent;
		}

		protected override void Events_CandleEvent(object sender, CandleEventArgs e)
		{
			ExecuteStrategy(e.Candle);
		}

		private void ExecuteStrategy(Candle c)
		{
			StrategyProperties props = PairProperties[c.Pair];

			float close = c.Close;
			BitfinexHandler.RetrieveBalances();

			if (Portfolio[c.Symbol] <= 0 && Portfolio["USD"] > BuyQty)
			{
				if (ShouldBuy(c.Pair, props))
				{
					Buy(close, c.time, c.Pair, props);
				}
			}
			else if (Portfolio[c.Symbol] > 0)
			{
				if (ShouldSell(c.time, c.Pair, props))
				{
					Sell(close, c.time, c.Pair, props);
				}
			}
		}

		protected override bool ShouldBuy(string pair, StrategyProperties properties)
		{
			float aktuellerPreis = Candles[pair][Candles[pair].Count - 1].Close;
			float letzterPreis = Candles[pair][Candles[pair].Count - 2].Close;
			float vorletzterPreis = Candles[pair][Candles[pair].Count - 3].Close;

			float aktuellerLowBB = (long)PairBB[pair].Lower[PairBB[pair].Lower.Length - 1];
			float letzterLowBB = (long)PairBB[pair].Lower[PairBB[pair].Lower.Length - 2];
			float vorletzterLowBB = (long)PairBB[pair].Lower[PairBB[pair].Lower.Length - 3];

			float aktuellerMidBB = (long)PairBB[pair].Middle[PairBB[pair].Middle.Length - 1];

			float aktuellerLMBB = (aktuellerMidBB - aktuellerLowBB) / 1.5f;

			if (letzterPreis < letzterLowBB * (float)properties.magicBuyValue && aktuellerPreis > letzterPreis && aktuellerPreis < aktuellerMidBB - aktuellerLMBB)
				return true;

			return false;
		}

		protected override bool ShouldSell(DateTime time, string pair, StrategyProperties properties)
		{
			float aktuellerPreis = Candles[pair][Candles[pair].Count - 1].Close;
			float letzterPreis = Candles[pair][Candles[pair].Count - 2].Close;
			float vorletzterPreis = Candles[pair][Candles[pair].Count - 3].Close;

			float letzterUpperBB = (long)PairBB[pair].Upper[PairBB[pair].Upper.Length - 2];
			float aktuellerMidBB = (long)PairBB[pair].Middle[PairBB[pair].Middle.Length - 1];

			if (
				(!properties.boughtOnDowntrend && letzterPreis > letzterUpperBB * properties.magicSellValue && aktuellerPreis < letzterPreis && aktuellerPreis > properties.lastBuyPrice * properties.minStepGain) ||    // Sell at top if candle shifted to short with stepGain
				(properties.boughtOnDowntrend && aktuellerPreis < letzterPreis && aktuellerPreis > properties.lastBuyPrice * properties.minStepGain) ||    // If boughtOnDowntrend then sell at next best price with profit
				(LastBuyTimeExceedsMaxHold(time, pair, properties) && aktuellerPreis >= properties.lastBuyPrice) ||                   // If holding for longer than an hour sell at next price close and lower to buy price
				(aktuellerPreis > properties.lastBuyPrice * properties.minStepGain && aktuellerPreis > aktuellerMidBB)
				)
				return true;

			return false;
		}

		protected override void Buy(float closePrice, DateTime time, string pair, StrategyProperties properties)
		{
			Console.WriteLine("Trying to buy " + pair + " at " + closePrice);

			properties.lastBuyPrice = closePrice;
			properties.lastBuyTime = time;
			properties.boughtOnDowntrend = IsDownTrend(pair, properties);

			BitfinexHandler.Buy(pair, closePrice, BuyQty);
		}

		protected override void Sell(float closePrice, DateTime time, string pair, StrategyProperties properties)
		{
			Console.WriteLine("Trying to sell " + pair + " at " + closePrice);

			float pl = closePrice - properties.lastBuyPrice;
			properties.boughtOnDowntrend = false;

			BitfinexHandler.Sell(pair);

			Console.WriteLine("Sold! - P/L: " + pl);
		}

		private bool LastBuyTimeExceedsMaxHold(DateTime currentTime, string pair, StrategyProperties properties)
		{
			if (DateTime.Compare(properties.lastBuyTime.AddMinutes(properties.maxHoldTime), currentTime) <= 0)
				return true;

			return false;
		}

		private bool IsDownTrend(string pair, StrategyProperties properties)
		{
			long aktuellerMidBB = (long)PairBB[pair].Middle[PairBB[pair].Middle.Length - 1];
			long letzterMidBB = (long)PairBB[pair].Middle[PairBB[pair].Middle.Length - 2];
			long vorletzterMidBB = (long)PairBB[pair].Middle[PairBB[pair].Middle.Length - 3];


			if (vorletzterMidBB > letzterMidBB && letzterMidBB > aktuellerMidBB)
			{
				// Sekantensteigung
				float s = (aktuellerMidBB - vorletzterMidBB) / (1.5f);

				if (s < properties.downTrendStrength)
					return true;
			}

			return false;
		}
	}
}
