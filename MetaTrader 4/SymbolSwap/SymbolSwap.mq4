//+------------------------------------------------------------------+
//|                                                   SymbolSwap.mq4 |
//|                                     Copyright 2019, Pascal Weber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   string symname = Symbol();
   double swapLong = (SymbolInfoDouble(symname, SYMBOL_POINT) / SymbolInfoDouble(symname, SYMBOL_BID)) * 100000 * SymbolInfoDouble(symname, SYMBOL_SWAP_LONG);
   double swapShort = (SymbolInfoDouble(symname, SYMBOL_POINT) / SymbolInfoDouble(symname, SYMBOL_BID)) * 100000 * SymbolInfoDouble(symname, SYMBOL_SWAP_SHORT);
   
   double accLong = 0.0;
   double accShort = 0.0;
   
   if (StringCompare(SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN), "EUR", false) != 0)
   {
      // Wenn in USD und Symbol ist: EUR USD dann /
      // Wenn in USD und Symbol ist: USD EUR dann *
      if (SymbolInfoDouble(SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN) + "EUR", SYMBOL_BID) > 0.0)
      {
         accLong = swapLong * SymbolInfoDouble(SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN) + "EUR", SYMBOL_BID);
         accShort = swapShort * SymbolInfoDouble(SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN) + "EUR", SYMBOL_BID);
      }
      else if (SymbolInfoDouble("EUR" + SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN), SYMBOL_BID) > 0.0)
      {
         accLong = swapLong / SymbolInfoDouble("EUR" + SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN), SYMBOL_BID);
         accShort = swapShort / SymbolInfoDouble("EUR" + SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN), SYMBOL_BID);
      }
      else
      {
         // Fehler: Kein Symbol gefunden weder EURUSD noch USDEUR
         accLong = -99999.0;
         accShort = -99999.0;
      }
   }
   else
   {
      accLong = swapLong;
      accShort = swapShort;
   }
   
   Comment("Swap Long:  " + DoubleToString(accLong, 2) + " EUR \r\nSwap Short: " + DoubleToString(accShort, 2) + " EUR");
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
