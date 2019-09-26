//|                                                 DojiPatterns.mqh |
//|                                     Copyright 2019, Pascal Weber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict

#include "OrderManager.mqh"
#include "Drawing.mqh"

class DojiPatterns
{
public:

   DojiPatterns()
   {
   }
   
   //+------------------------------------------------------------------+
   //|------------------------------------------------------------------|
   //|                            SECTION                               |
   //|                        GRAVESTONE DOJI                           |
   //|------------------------------------------------------------------|
   //+------------------------------------------------------------------+
   
   static void HandleGravestoneDojiEntry(bool useATRForGraveDoji, double BIGCANDLEBODY) {
      
      if (CheckPatternGravestoneDoji(BIGCANDLEBODY)) {
         OrderManager::PlaceMarketOrder(OP_SELL, 0.04, "Gravestone Doji", useATRForGraveDoji);
      }
   }
   
   static bool CheckPatternGravestoneDoji(double BIGCANDLEBODY) {
      
      double currentBody = MathAbs(Open[1] - Close[1]);
      double bodyMaxSize = BIGCANDLEBODY / 10;
      double upperShadowMinSize = BIGCANDLEBODY * 2/3;
      double lowerShadowMaxSize = BIGCANDLEBODY * 12/100;
      
      double lowestPrice = Open[1];
      if (Close[1] < lowestPrice) { lowestPrice = Close[1]; }
      double highestPrice = Open[1];
      if (Close[1] > highestPrice) { highestPrice = Close[1]; }
      
      if ((currentBody <= bodyMaxSize)                   &&
         (Low[1] > lowestPrice - lowerShadowMaxSize)     &&
         (High[1] > highestPrice + upperShadowMinSize))
      {
         Drawing::DrawRectangle(0, 2, Low[iLowest(NULL, 0, MODE_LOW, 2, 1)], High[iHighest(NULL, 0, MODE_HIGH, 2, 1)], clrYellow);
         Drawing::WriteText(4, clrYellow, "Grave_Doji");
         return true;
      }
      return false;
   }
   
   static void HandleGravestoneDojiTrailingSL(double BIGCANDLEBODY) {
      
      int ticket = OrderManager::GetTicket("CP_SELL: Gravestone Doji2");
      
      if (ticket != -1) {
      
         bool res1 = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         double price = OrderOpenPrice();
         double slPrice = OrderStopLoss();
         
         if (OrderManager::GetTicket("CP_SELL: Gravestone Doji1") == -1 && price < slPrice) {
            OrderManager::UpdateTrailingSL(ticket, price);
         }
         
         if (OrderManager::GetTicket("CP_SELL: Gravestone Doji1") == -1 && price >= slPrice && Bid < slPrice - BIGCANDLEBODY) {
            OrderManager::UpdateTrailingSL(ticket, slPrice - BIGCANDLEBODY / 2);
         }
      }
   }
   
   //+------------------------------------------------------------------+
   //|------------------------------------------------------------------|
   //|                            SECTION                               |
   //|                        DRAGONFLY DOJI                            |
   //|------------------------------------------------------------------|
   //+------------------------------------------------------------------+
   
   static void HandleDragonflyDojiEntry(bool useATRForDragonDoji, double BIGCANDLEBODY) {
      
      if (CheckPatternDragonflyDoji(BIGCANDLEBODY)) {
         OrderManager::PlaceMarketOrder(OP_BUY, 0.04, "Dragonfly Doji", useATRForDragonDoji);
      }
   }
   
   static bool CheckPatternDragonflyDoji(double BIGCANDLEBODY) {
      
      double currentBody = MathAbs(Open[1] - Close[1]);
      double bodyMaxSize = BIGCANDLEBODY / 10;
      double lowerShadowMinSize = BIGCANDLEBODY * 2/3;
      double upperShadowMaxSize = BIGCANDLEBODY * 12/100;
      
      double lowestPrice = Open[1];
      if (Close[1] < lowestPrice) { lowestPrice = Close[1]; }
      double highestPrice = Open[1];
      if (Close[1] > highestPrice) { highestPrice = Close[1]; }
      
      if ((currentBody <= bodyMaxSize)                   &&
         (High[1] < highestPrice + upperShadowMaxSize)   &&
         (Low[1] < lowestPrice - lowerShadowMinSize))
      {
         Drawing::DrawRectangle(0, 2, Low[iLowest(NULL, 0, MODE_LOW, 2, 1)], High[iHighest(NULL, 0, MODE_HIGH, 2, 1)], clrYellow);
         Drawing::WriteText(4, clrYellow, "Drag_Doji");
         return true;
      }
      return false;
   }
   
   static void HandleDragonflyDojiTrailingSL(double BIGCANDLEBODY) {
      
      int ticket = OrderManager::GetTicket("CP_BUY: Dragonfly Doji2");
      
      if (ticket != -1) {
      
         bool res1 = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         double price = OrderOpenPrice();
         double slPrice = OrderStopLoss();
         
         if (OrderManager::GetTicket("CP_BUY: Dragonfly Doji1") == -1 && price > slPrice) {
            OrderManager::UpdateTrailingSL(ticket, price);
         }
         
         if (OrderManager::GetTicket("CP_BUY: Dragonfly Doji1") == -1 && price <= slPrice && Ask > slPrice + BIGCANDLEBODY) {
            OrderManager::UpdateTrailingSL(ticket, slPrice + BIGCANDLEBODY / 2);
         }
      }
   }
};