using System;

namespace BitfinexTradingBot
{
	public class CandleEventArgs : EventArgs
	{
		private readonly Candle candle;

		public CandleEventArgs(Candle candle)
		{
			this.candle = candle;
		}

		public Candle Candle { get { return candle; } }
	}

	public class Candle
	{
		private readonly string symbol;
		private readonly string pair;
		private readonly string resolution;

		public long mts;
		public DateTime time;
		public bool insert;

		private readonly float open;
		private readonly float high;
		private readonly float low;
		private readonly float close;

		public Candle(string symbol, string pair, string resolution, long mts, DateTime time, float open, float high, float low, float close, bool insert = false)
		{
			this.symbol = symbol;
			this.pair = pair;
			this.resolution = resolution;
			this.mts = mts;
			this.time = time;
			this.open = open;
			this.high = high;
			this.low = low;
			this.close = close;
			this.insert = insert;

			Events.OnCandleEvent(new CandleEventArgs(this));
		}

		public string Symbol { get { return symbol; } }
		public string Pair { get { return pair; } }
		public string Resolution {  get { return resolution; } }
		public float Open { get { return open; } }
		public float High { get { return high; } }
		public float Low { get { return low; } }
		public float Close { get { return close; } }

		public override string ToString()
		{
			return string.Format("{0} {1} {2}  O: {3}  H: {4}  L: {5}  C: {6}", time, pair, resolution, open, high, low, close);
		}
	}
}
