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

class HammerPatterns
{
public:

   HammerPatterns()
   {
   }
   
   //+------------------------------------------------------------------+
   //|------------------------------------------------------------------|
   //|                            SECTION                               |
   //|                         STRONG HAMMER                            |
   //|------------------------------------------------------------------|
   //+------------------------------------------------------------------+
   
   static void HandleStrongHammerEntry(bool useATRForStrongHammer, double BIGCANDLEBODY) {
      
      if (CheckPatternStrongHammer(BIGCANDLEBODY)) {
         OrderManager::PlaceMarketOrder(OP_BUY, 0.04, "Strong Hammer", useATRForStrongHammer);
      }
   }
   
   static bool CheckPatternStrongHammer(double BIGCANDLEBODY) {
      
      if (Open[1] > Close[1]) {
         return false;
      }
      
      double currentBody = MathAbs(Open[1] - Close[1]);
      double bodyMinSize = BIGCANDLEBODY / 10;
      double bodyMaxSize = BIGCANDLEBODY * 2/3;
      double lowerShadowMinSize = currentBody * 2;
      double upperShadowMaxSize = BIGCANDLEBODY * 10/100;
      double lowestPrice = Open[1];
      double highestPrice = Close[1];
      
      if ((currentBody <= bodyMaxSize)                   &&
         (currentBody > bodyMinSize)                     &&
         (High[1] < highestPrice + upperShadowMaxSize)   &&
         (Low[1] < lowestPrice - lowerShadowMinSize))
      {
         Drawing::DrawRectangle(0, 2, Low[iLowest(NULL, 0, MODE_LOW, 2, 1)], High[iHighest(NULL, 0, MODE_HIGH, 2, 1)], clrYellow);
         Drawing::WriteText(4, clrYellow, "Str_Hamm");
         return true;
      }
      return false;
   }
   
   static void HandleStrongHammerTrailingSL(double BIGCANDLEBODY) {
      
      int ticket = OrderManager::GetTicket("CP_BUY: Strong Hammer2");
      
      if (ticket != -1) {
      
         bool res1 = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         double price = OrderOpenPrice();
         double slPrice = OrderStopLoss();
         
         if (OrderManager::GetTicket("CP_BUY: Strong Hammer1") == -1 && price > slPrice) {
            OrderManager::UpdateTrailingSL(ticket, price);
         }
         
         if (OrderManager::GetTicket("CP_BUY: Strong Hammer1") == -1 && price <= slPrice && Ask > slPrice + BIGCANDLEBODY) {
            OrderManager::UpdateTrailingSL(ticket, slPrice + BIGCANDLEBODY / 2);
         }
      }
   }
   
   //+------------------------------------------------------------------+
   //|------------------------------------------------------------------|
   //|                            SECTION                               |
   //|                         WEAKER HAMMER                            |
   //|------------------------------------------------------------------|
   //+------------------------------------------------------------------+
   
   static void HandleWeakerHammerEntry(bool useATRForWeakerHammer, double BIGCANDLEBODY) {
      
      if (CheckPatternWeakerHammer(BIGCANDLEBODY)) {
         OrderManager::PlaceMarketOrder(OP_BUY, 0.04, "Weaker Hammer", useATRForWeakerHammer);
      }
   }
   
   static bool CheckPatternWeakerHammer(double BIGCANDLEBODY) {
      
      if (Open[1] < Close[1]) {
         return false;
      }
      
      double currentBody = MathAbs(Open[1] - Close[1]);
      double bodyMinSize = BIGCANDLEBODY / 10;
      double bodyMaxSize = BIGCANDLEBODY * 2/3;
      double lowerShadowMinSize = currentBody * 2;
      double upperShadowMaxSize = BIGCANDLEBODY * 10/100;
      double lowestPrice = Close[1];
      double highestPrice = Open[1];
      
      if ((currentBody <= bodyMaxSize)                   &&
         (currentBody > bodyMinSize)                     &&
         (High[1] < highestPrice + upperShadowMaxSize)   &&
         (Low[1] < lowestPrice - lowerShadowMinSize))
      {
         Drawing::DrawRectangle(0, 2, Low[iLowest(NULL, 0, MODE_LOW, 2, 1)], High[iHighest(NULL, 0, MODE_HIGH, 2, 1)], clrYellow);
         Drawing::WriteText(4, clrYellow, "Weak_Hamm");
         return true;
      }
      return false;
   }
   
   static void HandleWeakerHammerTrailingSL(double BIGCANDLEBODY) {
      
      int ticket = OrderManager::GetTicket("CP_BUY: Weaker Hammer2");
      
      if (ticket != -1) {
      
         bool res1 = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
         double price = OrderOpenPrice();
         double slPrice = OrderStopLoss();
         
         if (OrderManager::GetTicket("CP_BUY: Weaker Hammer1") == -1 && price > slPrice) {
            OrderManager::UpdateTrailingSL(ticket, price);
         }
         
         if (OrderManager::GetTicket("CP_BUY: Weaker Hammer1") == -1 && price <= slPrice && Ask > slPrice + BIGCANDLEBODY) {
            OrderManager::UpdateTrailingSL(ticket, slPrice + BIGCANDLEBODY / 2);
         }
      }
   }
};