//+------------------------------------------------------------------+
//|                                            OrderManager.mqh      |
//|                                     Copyright 2019, Pascal Weber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict

class OrderManager
{
public:

   OrderManager()
   {
   }

   static int GetTicket(string comment) {
      
      int ticket = -1;
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderComment() == comment && OrderSymbol() == Symbol()) {
            ticket = OrderTicket();
            break;
         }
      }
      
      return ticket;
   }
   
   static bool IsSellPositionOpen() {
      
      bool returnValue = false;
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
            returnValue = true;
            break;
         }
      }
      
      return returnValue;
   }
   
   static bool IsBuyPositionOpen() {
      
      bool returnValue = false;
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
            returnValue = true;
            break;
         }
      }
      
      return returnValue;
   }
   
   static void CloseAllLongPositions() {
   
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
            bool res1 = OrderClose(OrderTicket(), OrderLots(), Bid, 3);
            if(!res1) { Print("OrderClose (CloseAllLongPositions) Error: #", GetLastError()); }
         }
      }
   }
   
   static void CloseAllShortPositions() {
   
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
            bool res1 = OrderClose(OrderTicket(), OrderLots(), Ask, 3);
            if(!res1) { Print("OrderClose (CloseAllShortPositions) Error: #", GetLastError()); }
         }
      }
   }
   
   static double GetEntryPriceOfCurrentLongPosition(bool longPositionOpen) {
      
      double returnValue = 99999;
      
      if (!longPositionOpen) {
         return returnValue;
      }
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
            returnValue = OrderOpenPrice();
            break;
         }
      }
      return returnValue;
   }
   
   static double GetEntryPriceOfCurrentShortPosition(bool shortPositionOpen) {
      
      double returnValue = -1;
      
      if (!shortPositionOpen) {
         return returnValue;
      }
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
            returnValue = OrderOpenPrice();
            break;
         }
      }
      return returnValue;
   }
   
   static void PlaceMarketOrder(int cmd, double volume, string comment, bool useATRForSL) {
      
      double atr = iATR(NULL, 0, 14, 1);
      double price = Bid;
      color clr = clrRed;
      string commentIdentifier = "SELL";
      double slPrice = High[1];
      if (useATRForSL) { slPrice = price + atr; }
      double tp1Price = price - (High[1] - price);
      
      if (cmd == OP_BUY) {
      
         price = Ask;
         clr = clrGreen;
         commentIdentifier = "BUY";
         slPrice = Low[1];
         if (useATRForSL) { slPrice = price - atr; }
         tp1Price = price + (price - Low[1]);
      }
      
      bool shortPosOpen = OrderManager::IsSellPositionOpen();
      bool longPosOpen = OrderManager::IsBuyPositionOpen();
      
      if (cmd == OP_BUY && shortPosOpen) {
         OrderManager::CloseAllShortPositions();
      }
      if (cmd == OP_SELL && longPosOpen) {
         OrderManager::CloseAllLongPositions();
      }
      if (cmd == OP_BUY && longPosOpen && price > GetEntryPriceOfCurrentLongPosition(longPosOpen)) {
         return;
      }
      if (cmd == OP_SELL && shortPosOpen && price < GetEntryPriceOfCurrentShortPosition(shortPosOpen)) {
         return;
      }
      
      // !!! volume is volume/2 because we are placing two order entry so we can have two TP targets !!!
      int ticket1 = OrderSend(Symbol(), cmd, volume / 2, price, 3, 0, 0, "CP_" + commentIdentifier + ": " + comment + "1", 1337, 0, clr);
      
      if (ticket1 <= 0) { Print("OrderSend (PlaceMarketOrder) Error: #", GetLastError()); }
      else {
         bool res1 = OrderModify(ticket1, 0, slPrice, tp1Price, 0);
         if(!res1) { Print("OrderModify (PlaceMarketOrder) Error: #", GetLastError()); }
      }
      
      int ticket2 = OrderSend(Symbol(), cmd, volume / 2, price, 3, 0, 0, "CP_" + commentIdentifier + ": " + comment + "2", 1337, 0, clr);
      
      if (ticket2 <= 0) { Print("OrderSend (PlaceMarketOrder) Error: #", GetLastError()); }
      else {
         bool res2 = OrderModify(ticket2, 0, slPrice, 0, 0);
         if(!res2) { Print("OrderModify (PlaceMarketOrder) Error: #", GetLastError()); }
      }
   }
   
   static void PlaceMarketOrderTPSL(int cmd, double volume, string comment, double slPoints, double tp1Points, double tp2Points) {
      
      double price = Bid;
      color clr = clrRed;
      string commentIdentifier = "SELL";
      double slPrice = price + slPoints * Point();
      double tp1Price = price - tp1Points * Point();
      double tp2Price = price - tp2Points * Point();
      
      if (cmd == OP_BUY) {
      
         price = Ask;
         clr = clrGreen;
         commentIdentifier = "BUY";
         slPrice = price - slPoints * Point();
         tp1Price = price + tp1Points * Point();
         tp2Price = price + tp2Points * Point();
      }
      
      bool shortPosOpen = OrderManager::IsSellPositionOpen();
      bool longPosOpen = OrderManager::IsBuyPositionOpen();
      
      if (cmd == OP_BUY && shortPosOpen) {
         OrderManager::CloseAllShortPositions();
      }
      if (cmd == OP_SELL && longPosOpen) {
         OrderManager::CloseAllLongPositions();
      }
      if (cmd == OP_BUY && longPosOpen) {
         return;
      }
      if (cmd == OP_SELL && shortPosOpen) {
         return;
      }
      
      // !!! volume is volume/2 because we are placing two order entry so we can have two TP targets !!!
      int ticket1 = OrderSend(Symbol(), cmd, volume / 2, price, 3, 0, 0, "CP_" + commentIdentifier + ": " + comment + "1", 1337, 0, clr);
      
      if (ticket1 <= 0) { Print("OrderSend (PlaceMarketOrder) Error: #", GetLastError()); }
      else {
         bool res1 = OrderModify(ticket1, 0, slPrice, tp1Price, 0);
         if(!res1) { Print("OrderModify (PlaceMarketOrder) Error: #", GetLastError()); }
      }
      
      int ticket2 = OrderSend(Symbol(), cmd, volume / 2, price, 3, 0, 0, "CP_" + commentIdentifier + ": " + comment + "2", 1337, 0, clr);
      
      if (ticket2 <= 0) { Print("OrderSend (PlaceMarketOrder) Error: #", GetLastError()); }
      else {
         bool res2 = OrderModify(ticket2, 0, slPrice, tp2Price, 0);
         if(!res2) { Print("OrderModify (PlaceMarketOrder) Error: #", GetLastError()); }
      }
   }
   
   static void UpdateTrailingSL(int ticket, double price) {
   
      bool res2 = OrderModify(ticket, 0, price, 0, 0);
      if(!res2) { Print("OrderModify (UpdateTrailingSL) Error: #", GetLastError()); }
   }
};