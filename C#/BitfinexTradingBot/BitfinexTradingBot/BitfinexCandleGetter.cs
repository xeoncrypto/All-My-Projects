using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Threading;

namespace BitfinexTradingBot
{
	class BitfinexCandleGetter : Exchange
	{
		private static readonly string requestUrl = "https://api.bitfinex.com/v2/candles/trade:{0}:{1}/hist?limit=2";
		private static readonly string requesthistory = "https://api.bitfinex.com/v2/candles/trade:{0}:{1}/hist";

		public static bool GetNewCandle(string resolution, string pair, string symbol)
		{
			if (!Candles.ContainsKey(pair))
				Candles.Add(pair, new List<Candle>());

			string requestStr = requestUrl;

			if (Candles[pair].Count <= 0)
				requestStr = requesthistory;

			requestStr = string.Format(requestStr, resolution, pair);

			try
			{
				HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requestStr);
				HttpWebResponse response = (HttpWebResponse)request.GetResponse();
				string raw = new StreamReader(response.GetResponseStream()).ReadToEnd();

				string[] sep = { "," };
				string[] dataArray = raw.Replace("[", "").Replace("]", "").Split(sep, StringSplitOptions.RemoveEmptyEntries);

				if (Candles[pair].Count <= 0)
				{
					Console.WriteLine(string.Format("No history available for {0} with resolution {1}", pair, resolution));
					Console.WriteLine("Getting last 100 candles...");

					for (int i = 6; i < dataArray.Length; i += 6)
					{
						long mtsTemp = Convert.ToInt64(dataArray[i]);
						DateTime time = new DateTime(1970, 1, 1).AddMilliseconds(mtsTemp).AddMinutes(60);

						float open = Convert.ToSingle(dataArray[i + 1].Replace(".", ","));
						float close = Convert.ToSingle(dataArray[i + 2].Replace(".", ","));
						float high = Convert.ToSingle(dataArray[i + 3].Replace(".", ","));
						float low = Convert.ToSingle(dataArray[i + 4].Replace(".", ","));

						Candle c = new Candle(symbol, pair, resolution, mtsTemp, time, open, high, low, close, true);
					}
					Console.WriteLine("Successfully retrieved history");
					Console.WriteLine("Searching for new candles...");
					return true;
				}

				long[] converted = new long[5];

				for (int i = 0; i < converted.Length; i++)
					converted[i] = (long)Convert.ToSingle(dataArray[i + 6].Replace(".", ","));

				long mts = Convert.ToInt64(dataArray[6]);

				if (mts > Candles[pair][Candles[pair].Count - 1].mts)
				{
					DateTime time = new DateTime(1970, 1, 1).AddMilliseconds(mts).AddMinutes(60);

					Candle c = new Candle(symbol, pair, resolution, mts, time, converted[1], converted[3], converted[4], converted[2]);
					return true;
				}

				return false;
			}
			catch (WebException e)
			{
				Console.WriteLine(e.Message);
				Thread.Sleep(2000);
				return GetNewCandle(resolution, pair, symbol);
			}
		}
	}
}
