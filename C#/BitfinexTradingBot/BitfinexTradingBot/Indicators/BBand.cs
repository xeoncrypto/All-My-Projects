using System;
using System.Collections.Generic;
using System.Text;
using TicTacTec.TA.Library;

namespace BitfinexTradingBot.Indicators
{
	class BBand : Exchange
	{
		public string pair;

		public int periods;
		public int stdDev;
		private List<float> prices;
		private Core.MAType mAType;

		public double[] Upper;
		public double[] Middle;
		public double[] Lower;

		private int begIdx;
		private int nbElem;

		public BBand(string pair, int periods, int stdDev, Core.MAType mAType = Core.MAType.Sma)
		{
			this.pair = pair;

			this.periods = periods;
			this.stdDev = stdDev;
			prices = new List<float>();
			this.mAType = mAType;

			Upper = new double[periods];
			Middle = new double[periods];
			Lower = new double[periods];

			UpdatePrices();
			Update();

			Events.CandleEvent += Events_CandleEvent;
		}

		private void Events_CandleEvent(object sender, CandleEventArgs e)
		{
			if (e.Candle.Pair == pair)
				Update();
		}

		private void UpdatePrices()
		{
			prices.Clear();

			for (int i = 0; i < Candles[pair].Count; i++)
				prices.Add(Candles[pair][i].Close);
		}

		public void Update(bool debug = false)
		{
			UpdatePrices();

			Core.Bbands(prices.Count - periods, prices.Count - 1, prices.ToArray(), periods, stdDev, stdDev, mAType, out begIdx, out nbElem, Upper, Middle, Lower);

			if (debug)
				OutputDebug();
		}

		private void OutputDebug()
		{
			Console.WriteLine(string.Format("C: {0} Upper: {1} Middle: {2} Lower: {3}", prices[begIdx+nbElem-2], Upper[nbElem-2], Middle[nbElem - 2], Lower[nbElem - 2]));
			Console.WriteLine(string.Format("C: {0} Upper: {1} Middle: {2} Lower: {3}", prices[begIdx + nbElem - 1], Upper[nbElem - 1], Middle[nbElem - 1], Lower[nbElem - 1]));
		}
	}
}
