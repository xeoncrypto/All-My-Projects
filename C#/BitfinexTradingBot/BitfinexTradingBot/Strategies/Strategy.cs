using System;

namespace BitfinexTradingBot.Strategies
{
	public abstract class Strategy : Exchange
	{
		protected abstract bool ShouldBuy(string pair, StrategyProperties properties);
		protected abstract bool ShouldSell(DateTime time, string pair, StrategyProperties properties);
		protected abstract void Buy(float closePrice, DateTime time, string pair, StrategyProperties properties);
		protected abstract void Sell(float closePrice, DateTime time, string pair, StrategyProperties properties);

		protected abstract void Events_CandleEvent(object sender, CandleEventArgs e);
	}
}
