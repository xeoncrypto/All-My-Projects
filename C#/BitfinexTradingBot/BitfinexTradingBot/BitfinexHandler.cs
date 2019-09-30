using System;
using WebSocketSharp;
using Newtonsoft.Json;
using RestSharp;
using System.Security.Cryptography;
using System.Text;
using System.Net;
using System.Collections.Generic;
using BitfinexTradingBot.JsonBase;
using BitfinexTradingBot.Strategies;
using System.Threading;

namespace BitfinexTradingBot
{
	class BitfinexHandler
	{
		private static readonly string apiKey = "YOUR API KEY";
		private static readonly string apiSecret = "YOUR API SECRET";

		private static string ApiBfxKey = "X-BFX-APIKEY";
		private static string ApiBfxPayload = "X-BFX-PAYLOAD";
		private static string ApiBfxSig = "X-BFX-SIGNATURE";

		private static string BalanceRequestUrl = "/v1/balances";
		private static string NewOrderRequestUrl = "/v1/order/new";

		private static readonly string BaseBitfinexUrl = "https://api.bitfinex.com";

		private static readonly string DefaultOrderType = "exchange market"; //Either “market” / “limit” / “stop” / “trailing-stop” / “fill-or-kill” / “exchange market” / “exchange limit” / “exchange stop” / “exchange trailing-stop” / “exchange fill-or-kill”. (type starting by “exchange ” are exchange orders, others are margin trading orders)

		internal static void Buy(string pair, float closePrice, float qty)
		{
			if (pair.StartsWith("t"))
				pair = pair.Substring(1).ToLower();

			float amount = BBBullMarket.BuyQty / closePrice;
			Random r = new Random();

			BitfinexNewOrderResponse resp = SendSimpleLimitBuy(pair, amount.ToString().Replace(",", "."), r.NextDouble().ToString().Replace(",", "."));

			Console.WriteLine("Bought " + resp.OriginalAmount + " " + resp.Symbol + " for " + resp.Price);
			RetrieveBalances();
		}

		internal static void Sell(string pair)
		{
			if (pair.StartsWith("t"))
				pair = pair.Substring(1).ToLower();

			float qty = Exchange.Portfolio[pair.Substring(0, 3).ToUpper()];
			Random r = new Random();

			BitfinexNewOrderResponse resp = SendSimpleLimitSell(pair, qty.ToString().Replace(",", "."), r.NextDouble().ToString().Replace(",", "."));

			Console.WriteLine("Sold " + resp.OriginalAmount + " " + resp.Symbol + " for " + resp.Price);
			RetrieveBalances();
		}

		public static BitfinexNewOrderResponse SendOrder(BitfinexNewOrderPost newOrder)
		{
			IRestResponse response = null;
			try
			{
				newOrder.Request = NewOrderRequestUrl;
				newOrder.Nonce = GetNonce();

				var client = GetRestClient(NewOrderRequestUrl);
				response = GetRestResponse(client, newOrder);

				var newOrderResponseObj = JsonConvert.DeserializeObject<BitfinexNewOrderResponse>(response.Content);

				return newOrderResponseObj;
			}
			catch (Exception ex)
			{
				var outer = new Exception(response.Content, ex);
				Console.WriteLine(outer);
				return null;
			}
		}

		public static BitfinexNewOrderResponse SendOrder(string symbol, string amount, string price, string exchange, string side, string type, bool isHidden)
		{
			var newOrder = new BitfinexNewOrderPost()
			{
				Symbol = symbol,
				Amount = amount,
				Price = price,
				Exchange = exchange,
				Side = side,
				Type = type//,
				//IsHidden = isHidden.ToString()
			};
			return SendOrder(newOrder);
		}

		public static BitfinexNewOrderResponse SendSimpleLimit(string symbol, string amount, string price, string side, bool isHidden = false)
		{
			return SendOrder(symbol, amount, price, "bitfinex", side, DefaultOrderType, isHidden);
		}

		public static BitfinexNewOrderResponse SendSimpleLimitBuy(string symbol, string amount, string price, bool isHidden = false)
		{
			return SendOrder(symbol, amount, price, "bitfinex", "buy", DefaultOrderType, isHidden);
		}

		public static BitfinexNewOrderResponse SendSimpleLimitSell(string symbol, string amount, string price, bool isHidden = false)
		{
			return SendOrder(symbol, amount, price, "bitfinex", "sell", DefaultOrderType, isHidden);
		}

		public static IList<BitfinexBalanceResponse> RetrieveBalances()
		{
			try
			{
				BitfinexPostBase post = new BitfinexPostBase
				{
					Request = BalanceRequestUrl,
					Nonce = GetNonce()
				};

				RestClient client = GetRestClient(BalanceRequestUrl);
				IRestResponse response = GetRestResponse(client, post);

				IList<BitfinexBalanceResponse> balancesObj = JsonConvert.DeserializeObject<IList<BitfinexBalanceResponse>>(response.Content);

				foreach (var b in balancesObj)
				{
					if (b.Type != "exchange")
						continue;

					Exchange.Portfolio[b.Currency.ToUpper()] = (float)b.Available;
				}

				return balancesObj;
			}
            catch (Exception ex)
            {
				Console.WriteLine(ex);
				Thread.Sleep(2000);
				return RetrieveBalances();
            }
		}

		private static RestClient GetRestClient(string requestUrl)
		{
			RestClient client = new RestClient { BaseUrl = new Uri(BaseBitfinexUrl + requestUrl) };
			return client;
		}

		private static RestRequest GetRestRequest(object obj)
		{
			var jsonObj = JsonConvert.SerializeObject(obj);
			var payload = Convert.ToBase64String(Encoding.UTF8.GetBytes(jsonObj));
			var request = new RestRequest { Method = Method.POST };
			request.AddHeader(ApiBfxKey, apiKey);
			request.AddHeader(ApiBfxPayload, payload);
			request.AddHeader(ApiBfxSig, GetHexHashSignature(payload));
			return request;
		}

		private static IRestResponse GetRestResponse(RestClient client, object obj)
		{
			IRestResponse response = client.Execute(GetRestRequest(obj));
			CheckToLogError(response);
			return response;
		}

		private static void CheckToLogError(IRestResponse response)
		{
			switch (response.StatusCode)
			{
				case HttpStatusCode.OK:
					break;
				case HttpStatusCode.BadRequest:
					var errorMsgObj = JsonConvert.DeserializeObject<ErrorResponse>(response.Content);
					Console.WriteLine("BitfinexApi.CheckToLogError(): " + errorMsgObj.Message);
					break;
				default:
					Console.WriteLine("BitfinexApi.CheckToLogError(): " + response.StatusCode + " - " + response.Content);
					break;
			}
		}

		private static string GetNonce()
		{
			return DateTime.UtcNow.Ticks.ToString();
		}

		private static string GetHexHashSignature(string payload)
		{
			HMACSHA384 hmac = new HMACSHA384(Encoding.UTF8.GetBytes(apiSecret));
			byte[] hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(payload));
			return BitConverter.ToString(hash).Replace("-", "").ToLower();
		}
	}
}
