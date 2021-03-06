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
   
   static int CountOpenSellPositions() {
      
      int returnValue = 0;
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
            returnValue++;
         }
      }
      
      return returnValue;
   }
   
   static int CountOpenBuyPositions() {
      
      int returnValue = 0;
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         
         bool res = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
         
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
            returnValue++;
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
   
   static bool PlaceMarketOrderFixedPriceSLTP(int cmd, double volume, string comment, double slPrice, double tp1Price) {
      
      double minPointsProfit = 30 * Point();
      
      bool shortPosOpen = OrderManager::IsSellPositionOpen();
      bool longPosOpen = OrderManager::IsBuyPositionOpen();
      
      if (cmd == OP_BUY && shortPosOpen) {
         OrderManager::CloseAllShortPositions();
      }
      if (cmd == OP_SELL && longPosOpen) {
         OrderManager::CloseAllLongPositions();
      }
      if (cmd == OP_BUY && longPosOpen) {
         return false;
      }
      if (cmd == OP_SELL && shortPosOpen) {
         return false;
      }
      
      double price = Bid;
      color clr = clrRed;
      string commentIdentifier = "SELL";
      
      if (cmd == OP_SELL) {
      
         price = Bid;
         clr = clrRed;
         commentIdentifier = "SELL";
         
         if (slPrice <= price + minPointsProfit) {
            Print("Sell error: SL < entry price");
            return false;
         }
         if (tp1Price >= price - minPointsProfit) {
            Print("Sell error: TP > entry price");
            return false;
         }
      }
      else if (cmd == OP_BUY) {
      
         price = Ask;
         clr = clrGreen;
         commentIdentifier = "BUY";
         
         if (slPrice >= price - minPointsProfit) {
            Print("Buy error: SL > entry price");
            return false;
         }
         if (tp1Price <= price + minPointsProfit) {
            Print("Buy error: TP < entry price");
            return false;
         }
      }
      else {
         return false;
      }
      
      slPrice = NormalizeDouble(slPrice, Digits());
      tp1Price = NormalizeDouble(tp1Price, Digits());
      
      int ticket1 = OrderSend(Symbol(), cmd, volume, price, 3, 0, 0, "CP_" + commentIdentifier + ": " + comment, 1337, 0, clr);
      
      if (ticket1 <= 0) { Print("OrderSend (PlaceMarketOrder) Error: #", GetLastError()); }
      else {
         bool res1 = OrderModify(ticket1, 0, slPrice, tp1Price, 0);
         if(!res1) { Print("OrderModify (PlaceMarketOrder) Error: #", GetLastError());}
      }
      
      return true;
   }
   
   static void UpdateTrailingSL(int ticket, double price) {
      
      bool res1 = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
      
      bool res2 = OrderModify(ticket, 0, NormalizeDouble(price, Digits()), OrderTakeProfit(), 0);
      if(!res2) { Print("OrderModify (UpdateTrailingSL) Error: #", GetLastError()); }
   }
   
   static double CalcLots(double Risk)
   {
      double tmpLot = 0, MinLot = 0, MaxLot = 0;
      MinLot = MarketInfo(Symbol(),MODE_MINLOT);
      MaxLot = MarketInfo(Symbol(),MODE_MAXLOT);
      tmpLot = NormalizeDouble(AccountBalance()*Risk/100000,2);
         
      if(tmpLot < MinLot)
      {
         Print("LotSize is Smaller than the broker allowed minimum Lot!");
         return(MinLot);
      } 
      if(tmpLot > MaxLot)
      {
         Print ("LotSize is Greater than the broker allowed maximum Lot!");
         return(MaxLot);
      } 
      return(tmpLot);
   }  
};