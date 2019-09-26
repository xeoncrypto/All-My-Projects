//+------------------------------------------------------------------+
//|                                            EngulfingPatterns.mqh |
//|                                     Copyright 2019, Pascal Weber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict

#include "Drawing.mqh"

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
   /*
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
   }*/
   
   static bool CheckPatternBullishEngulfing(double BIGCANDLEBODY, int prev, int cur) {
   
      double prevBody = MathAbs(Open[prev] - Close[prev]);
      double currentBody = MathAbs(Open[cur] - Close[cur]);
      
      if((Open[prev] > Close[prev])          &&  // previous candle is bearish
         (Open[cur] < Close[cur])    &&  // current candle is bullish
         (currentBody > prevBody + 3 * Point())          &&  // current candle engulfes previous candle
         (Open[cur] <= Close[prev])      &&  // open price of the bullish candle is lower than close price of the bearish
         (Close[cur] > Open[prev])       &&  // current close is higher than previous open
         (currentBody < BIGCANDLEBODY)                   &&  // Current candleBody should not be much bigger than the definition for a BIG_CANDLE_BODY
         (prevBody > 50 * Point())                       &&  // Previos body needs to have some height, otherwise its just a doji
         (prevBody / currentBody < 0.6))                     // Current candle needs to be bigger than previous candle
      {
         return(true);
      }
      return(false);
   }
   
   static bool CheckPatternBullishEngulfingAndDraw(double BIGCANDLEBODY) {
   
      double prevBody = MathAbs(Open[2] - Close[2]);
      double currentBody = MathAbs(Open[1] - Close[1]);
      
      if((Open[2] > Close[2])          &&  // previous candle is bearish
         (Open[1] < Close[1])    &&  // current candle is bullish
         (currentBody > prevBody + 3 * Point())          &&  // current candle engulfes previous candle
         (Open[1] <= Close[2])      &&  // open price of the bullish candle is lower than close price of the bearish
         (Close[1] > Open[2])       &&  // current close is higher than previous open
         (currentBody < BIGCANDLEBODY)                   &&  // Current candleBody should not be much bigger than the definition for a BIG_CANDLE_BODY
         (prevBody > 50 * Point())                       &&  // Previos body needs to have some height, otherwise its just a doji
         (prevBody / currentBody < 0.6))                     // Current candle needs to be bigger than previous candle
      {
         Drawing::DrawRectangle(1, 2, Low[iLowest(NULL, 0, MODE_LOW, 2, 1)], High[iHighest(NULL, 0, MODE_HIGH, 2, 1)], clrOrange);
         Drawing::WriteText(2, clrGold, "Bull_En");
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
   /*
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
   */
   static bool CheckPatternBearishEngulfing(double BIGCANDLEBODY, int prev, int cur) {
   
      double prevBody = MathAbs(Open[prev] - Close[prev]);
      double currentBody = MathAbs(Open[cur] - Close[cur]);
      
      if((Open[prev] < Close[prev])          &&  // previous candle is bullish
         (Open[cur] > Close[cur])    &&  // current candle is bearish
         (currentBody > prevBody + 3 * Point())          &&  // current candle engulfes previous candle
         (Open[cur] >= Close[prev])      &&  // open price of the bearish candle is higher than close price of the bullish
         (Close[cur] < Open[prev])       &&  // current close is smaller than previous open
         (currentBody < BIGCANDLEBODY)                   &&  // Current candleBody should not be much bigger than the definition for a BIG_CANDLE_BODY
         (prevBody > 50 * Point())                       &&  // Previos body needs to have some height, otherwise its just a doji
         (prevBody / currentBody < 0.6))                     // Current candle needs to be bigger than previous candle
      {
         return(true);
      }
      return(false);
   }
   
   static bool CheckPatternBearishEngulfingAndDraw(double BIGCANDLEBODY) {
   
      double prevBody = MathAbs(Open[2] - Close[2]);
      double currentBody = MathAbs(Open[1] - Close[1]);
      
      if((Open[2] < Close[2])          &&  // previous candle is bullish
         (Open[1] > Close[1])    &&  // current candle is bearish
         (currentBody > prevBody + 3 * Point())          &&  // current candle engulfes previous candle
         (Open[1] >= Close[2])      &&  // open price of the bearish candle is higher than close price of the bullish
         (Close[1] < Open[2])       &&  // current close is smaller than previous open
         (currentBody < BIGCANDLEBODY)                   &&  // Current candleBody should not be much bigger than the definition for a BIG_CANDLE_BODY
         (prevBody > 50 * Point())                       &&  // Previos body needs to have some height, otherwise its just a doji
         (prevBody / currentBody < 0.6))                     // Current candle needs to be bigger than previous candle
      {
         Drawing::DrawRectangle(1, 2, Low[iLowest(NULL, 0, MODE_LOW, 2, 1)], High[iHighest(NULL, 0, MODE_HIGH, 2, 1)], clrOrange);
         Drawing::WriteText(2, clrMaroon, "Bear_En");
         return(true);
      }
      return(false);
   }
};
