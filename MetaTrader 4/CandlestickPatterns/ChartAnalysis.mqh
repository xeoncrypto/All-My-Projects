//+------------------------------------------------------------------+
//|                                                ChartAnalysis.mqh |
//|                                     Copyright 2019, Pascal Weber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict

#include "Drawing.mqh"

class ChartAnalysis
{
public:

   ChartAnalysis()
   {
   }
   
   //+------------------------------------------------------------------+
   //| How often was it Support/Resistance in the past.                 |
   //| For "maxBarsBack" candles back shifted "shift" amount of candles |
   //| Returns 0 if there is no previous Support or Resistance found    |
   //+------------------------------------------------------------------+
   static int GetSRCount(double lowestPriceLevel, double highestPriceLevel, int shift, int maxBarsBack) {
      
      int counter = 0;
      
      for (int i = shift + 3; i <= shift + maxBarsBack; i++) {
         
         double lowerPrice = Open[i];
         double higherPrice = Open[i];
         
         if (Close[i] < lowerPrice) { lowerPrice = Close[i]; }
         if (Close[i] > higherPrice) { higherPrice = Close[i]; }
         
         if((lowerPrice < highestPriceLevel && lowerPrice > lowestPriceLevel)   ||
            (higherPrice < highestPriceLevel && higherPrice > lowestPriceLevel) ||
            (Low[i] < highestPriceLevel && Low[i] > lowestPriceLevel)           ||
            (High[i] < highestPriceLevel && High[i] > lowestPriceLevel)) {
            
            // Downtrend and breakthrough S/R
            if((Close[i] < Open[i])             &&
               (Close[i+1] > Close[i])          &&
               (Close[i-1] < lowestPriceLevel)) {
               continue;
            }
            
            // Uptrend and breakthrough S/R
            if((Close[i] > Open[i])             &&
               (Close[i+1] < Close[i])          &&
               (Close[i-1] > highestPriceLevel)) {
               continue;
            }
            
            counter++;
            //DrawRectangle(i, i+1, lowestPriceLevel, highestPriceLevel, clrRed);
         }
      }
      Drawing::WriteText(shift + 1, clrYellow, "SR: " + (string)counter);
      
      return counter;
   }
};