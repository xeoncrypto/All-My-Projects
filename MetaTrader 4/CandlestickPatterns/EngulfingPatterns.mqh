//+------------------------------------------------------------------+
//|                                            EngulfingPatterns.mqh |
//|                                     Copyright 2019, Pascal Weber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict

#include "OrderManager.mqh"
#include "ChartAnalysis.mqh"

class EngulfingPatterns
{
public:

   EngulfingPatterns()
   {
   }
   
   //+------------------------------------------------------------------+
   //|------------------------------------------------------------------|
   //|                            SECTION                               |
   //|                        BULLISH ENGULFING                         |
   //|------------------------------------------------------------------|
   //+------------------------------------------------------------------+
   
   static void HandleBullishEngulfingTrailingSL(double BIGCANDLEBODY) {
      
      int ticket = OrderManager::GetTicket("CP_BUY: Bullish Engulfing2");
      
      if (ticket != -1) {
      
         bool res1 = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         double price = OrderOpenPrice();
         double slPrice = OrderStopLoss();
         
         if (OrderManager::GetTicket("CP_BUY: Bullish Engulfing1") == -1 && price > slPrice) {
            OrderManager::UpdateTrailingSL(ticket, price);
         }
         
         if (OrderManager::GetTicket("CP_BUY: Bullish Engulfing1") == -1 && price <= slPrice && Ask > slPrice + BIGCANDLEBODY) {
            OrderManager::UpdateTrailingSL(ticket, slPrice + BIGCANDLEBODY / 2);
         }
      }
   }
   
   static void HandleBullishEngulfingEntry(bool useATRForBullishEngulf, double BIGCANDLEBODY) {
      
      if (CheckPatternBullishEngulfing(1, 2, BIGCANDLEBODY)) {
      
         double lowestPriceLevel = Low[1];
         double highestPriceLevel = Open[1];
         
         if (Low[2] < lowestPriceLevel) { lowestPriceLevel = Low[2]; }
         if (Close[2] > highestPriceLevel) { highestPriceLevel = Close[2]; }
         
         int srCount = ChartAnalysis::GetSRCount(lowestPriceLevel - 3 * Point(), highestPriceLevel + 3 * Point(), 1, 100);
         
         if (srCount >= 3) {
            OrderManager::PlaceMarketOrder(OP_BUY, 0.04, "Bullish Engulfing", useATRForBullishEngulf);
         }
      }
   }
   
   static bool CheckPatternBullishEngulfing(int currentCandle, int prevCandle, double BIGCANDLEBODY) {
   
      double prevBody = MathAbs(Open[prevCandle] - Close[prevCandle]);
      double currentBody = MathAbs(Open[currentCandle] - Close[currentCandle]);
      
      if((Open[prevCandle] > Close[prevCandle])          &&  // previous candle is bearish
         (Open[currentCandle] < Close[currentCandle])    &&  // current candle is bullish
         (currentBody > prevBody + 3 * Point())          &&  // current candle engulfes previous candle
         (Open[currentCandle] <= Close[prevCandle])      &&  // open price of the bullish candle is lower than close price of the bearish
         (Close[currentCandle] > Open[prevCandle])       &&  // current close is higher than previous open
         (currentBody < BIGCANDLEBODY)                 &&  // Current candleBody should not be much bigger than the definition for a BIG_CANDLE_BODY
         (prevBody > 50 * Point())) {                        // Previos body needs to have some height, otherwise its just a doji
         
         Drawing::DrawRectangle(currentCandle, prevCandle, Low[iLowest(NULL, 0, MODE_LOW, 2, currentCandle)], High[iHighest(NULL, 0, MODE_HIGH, 2, currentCandle)], clrBlue);
         Drawing::WriteText(prevCandle + 2, clrYellow, "Bull_En");
         return(true);
      }
      return(false);
   }
   
   //+------------------------------------------------------------------+
   //|------------------------------------------------------------------|
   //|                            SECTION                               |
   //|                        BEARISH ENGULFING                         |
   //|------------------------------------------------------------------|
   //+------------------------------------------------------------------+
   
   static void HandleBearishEngulfingTrailingSL(double BIGCANDLEBODY) {
      
      int ticket = OrderManager::GetTicket("CP_SELL: Bearish Engulfing2");
      
      if (ticket != -1) {
      
         bool res1 = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         double price = OrderOpenPrice();
         double slPrice = OrderStopLoss();
         
         if (OrderManager::GetTicket("CP_SELL: Bearish Engulfing1") == -1 && price < slPrice) {
            OrderManager::UpdateTrailingSL(ticket, price);
         }
         
         if (OrderManager::GetTicket("CP_SELL: Bearish Engulfing1") == -1 && price >= slPrice && Bid < slPrice - BIGCANDLEBODY) {
            OrderManager::UpdateTrailingSL(ticket, slPrice - BIGCANDLEBODY / 2);
         }
      }
   }
   
   static void HandleBearishEngulfingEntry(bool useATRForBearishEngulf, double BIGCANDLEBODY) {
      
      if (CheckPatternBearishEngulfing(1, 2, BIGCANDLEBODY)) {
      
         double lowestPriceLevel = Low[1];
         double highestPriceLevel = Open[1];
         
         if (Low[2] < lowestPriceLevel) { lowestPriceLevel = Low[2]; }
         if (Close[2] > highestPriceLevel) { highestPriceLevel = Close[2]; }
         
         int srCount = ChartAnalysis::GetSRCount(lowestPriceLevel - 3 * Point(), highestPriceLevel + 3 * Point(), 1, 100);
         
         if (srCount >= 3) {
            OrderManager::PlaceMarketOrder(OP_SELL, 0.04, "Bearish Engulfing", useATRForBearishEngulf);
         }
      }
   }
   
   static bool CheckPatternBearishEngulfing(int currentCandle, int prevCandle, double BIGCANDLEBODY) {
   
      double prevBody = MathAbs(Open[prevCandle] - Close[prevCandle]);
      double currentBody = MathAbs(Open[currentCandle] - Close[currentCandle]);
      
      if((Open[prevCandle] < Close[prevCandle])          &&  // previous candle is bullish
         (Open[currentCandle] > Close[currentCandle])    &&  // current candle is bearish
         (currentBody > prevBody + 3 * Point())          &&  // current candle engulfes previous candle
         (Open[currentCandle] >= Close[prevCandle])      &&  // open price of the bearish candle is higher than close price of the bullish
         (Close[currentCandle] < Open[prevCandle])       &&  // current close is smaller than previous open
         (currentBody < BIGCANDLEBODY)                 &&  // Current candleBody should not be much bigger than the definition for a BIG_CANDLE_BODY
         (prevBody > 50 * Point())) {                        // Previos body needs to have some height, otherwise its just a doji
         
         Drawing::DrawRectangle(currentCandle, prevCandle, Low[iLowest(NULL, 0, MODE_LOW, 2, currentCandle)], High[iHighest(NULL, 0, MODE_HIGH, 2, currentCandle)], clrBlue);
         Drawing::WriteText(prevCandle + 2, clrYellow, "Bear_En");
         return(true);
      }
      return(false);
   }
};
