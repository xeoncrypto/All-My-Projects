//+------------------------------------------------------------------+
//|                                                      QuadEMA.mq4 |
//|                                     Copyright 2019, Pascal Weber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict

#include "OrderManager.mqh"

#include "EngulfingPatterns.mqh"
#include "DojiPatterns.mqh"
#include "HammerPatterns.mqh"

string indicatorPath1 = "PATH TO PIVOT INDOCATOR";

extern double deviationMaxPercentage = 99.9;
extern string IlIlIl = "---------- D1 = 1000, H4 = 300, H1 = ";
extern double bigCandleBody = 300;
extern string lIlIlI = "---------- Entry values";
extern double emaZoneTolerance = 140;
extern bool useFirstEmaAsEntry = true;
extern string IIIIII = "---------- Moving averages";
extern int firstPeriod = 20;
extern int secondPeriod = 50;
extern int thirdPeriod = 100;
extern int fourthPeriod = 200;
extern bool useFourthPeriod = true;
extern string lIIIIl = "---------- Confirmation Signals";
extern bool usePivots = false;
extern bool useMACD = false;
extern bool useOsMA = false;
extern bool useBullishEngulfingPattern = false;
extern bool useBearishEngulfingPattern = false;
extern bool useDragonflyDojiPattern = false;
extern bool useGravestoneDojiPattern = false;
extern bool useStrongHammerPattern = false;
extern bool useWeakerHammerPattern = false;
extern string llllll = "---------- TP / SL with Envelopes";
extern bool useEnvelopes = true;
extern int envelopePeriod = 25;
extern double envelopeDeviation1 = 0.6;
extern double envelopeDeviation2 = 1.0;
extern double envelopeDeviation3 = 1.4;
extern string IlIIlI = "---------- SL with ATR (Overrides the Envelope SL)";
extern bool useAtrAsSL = true;
extern int atrPeriod = 20;
extern double atrMultiplier = 1.4;
extern int takeExtremaOfBarsBack = 3;
extern string IIllII = "---------- TP / SL with fixed Points | Only if useEnvelopes = false";
extern int slPoints = 700;
extern int tpPoints = 1000;
extern string llIIll = "---------- Entry- and Order-Management";
extern double risk = 20.0;
extern double RRRGreaterThan = 1.0;

int OnInit()
{
   emaZoneTolerance = emaZoneTolerance * Point();
   bigCandleBody = bigCandleBody * Point();
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   
}

void OnTick()
{
   if (!IsNewBar())
      return;
   
   EngulfingPatterns::CheckPatternBullishEngulfingAndDraw(bigCandleBody);
   EngulfingPatterns::CheckPatternBearishEngulfingAndDraw(bigCandleBody);
   DojiPatterns::CheckPatternDragonflyDojiAndDraw(bigCandleBody);
   DojiPatterns::CheckPatternGravestoneDojiAndDraw(bigCandleBody);
   HammerPatterns::CheckPatternStrongHammerAndDraw(bigCandleBody);
   HammerPatterns::CheckPatternWeakerHammerAndDraw(bigCandleBody);
   
   double ema20 = iMA(Symbol(), Period(), firstPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   double ema50 = iMA(Symbol(), Period(), secondPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   double ema100 = iMA(Symbol(), Period(), thirdPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   double ema200 = iMA(Symbol(), Period(), fourthPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   
   double upperEnv = iEnvelopes(Symbol(), PERIOD_CURRENT, envelopePeriod, MODE_EMA, 0, PRICE_CLOSE, envelopeDeviation1, MODE_UPPER, 1);
   double lowerEnv = iEnvelopes(Symbol(), PERIOD_CURRENT, envelopePeriod, MODE_EMA, 0, PRICE_CLOSE, envelopeDeviation1, MODE_LOWER, 1);
   
   double upperEnv2 = iEnvelopes(Symbol(), PERIOD_CURRENT, envelopePeriod, MODE_EMA, 0, PRICE_CLOSE, envelopeDeviation2, MODE_UPPER, 1);
   double lowerEnv2 = iEnvelopes(Symbol(), PERIOD_CURRENT, envelopePeriod, MODE_EMA, 0, PRICE_CLOSE, envelopeDeviation2, MODE_LOWER, 1);
   
   double upperEnv3 = iEnvelopes(Symbol(), PERIOD_CURRENT, envelopePeriod, MODE_EMA, 0, PRICE_CLOSE, envelopeDeviation3, MODE_UPPER, 1);
   double lowerEnv3 = iEnvelopes(Symbol(), PERIOD_CURRENT, envelopePeriod, MODE_EMA, 0, PRICE_CLOSE, envelopeDeviation3, MODE_LOWER, 1);
   
   double macd = iMACD(Symbol(), PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE, MODE_MAIN, 1);
   double osma = iOsMA(Symbol(), PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE, 1);
   
   double atr = iATR(Symbol(), PERIOD_CURRENT, atrPeriod, 1);
   
   double pp = 0.0;
   
   if (usePivots)
   {
      pp = iCustom(Symbol(), PERIOD_CURRENT, indicatorPath1, 0.0, false, true, false, 1, 0);
      DrawDot(0, pp, clrRed);
   }
   
   // -----------------------------------------------------------
   // BUY CONDITION
   // -----------------------------------------------------------
   
   // EMAs aligned (like a fan)
   if ((useFourthPeriod && ema20 > ema50 && ema50 > ema100 && ema100 > ema200) ||
       (!useFourthPeriod && ema20 > ema50 && ema50 > ema100))
   {
      // Entry condition
      if (((useFirstEmaAsEntry && Close[2] < ema20 + emaZoneTolerance && Close[2] > ema20 - emaZoneTolerance && Close[1] > ema20)    ||
          (Close[2] < ema50 + emaZoneTolerance && Close[2] > ema50 - emaZoneTolerance && Close[1] > ema50))    &&
          (Close[1] > ema200 && Close[2] > ema200))
      {
         // Check that EMAs are not too close to each other
         if (((ema50/ema20) * 100 < deviationMaxPercentage && (ema100/ema50) * 100 < deviationMaxPercentage))
         {
            // Bearish candle and last candle is not too big
            if (Close[2] < Open[2] && MathAbs(Close[1] - Open[1]) < bigCandleBody)
            {
               double slPrice = Ask - slPoints*Point();
               double tp1Price = Ask + tpPoints*Point();
               
               if (slPrice < ema200) { slPrice = ema200; }
               
               if (useEnvelopes)
               {
                  slPrice = Ask - (upperEnv - Ask);
                  tp1Price = upperEnv;
                  
                  if (Ask > upperEnv - emaZoneTolerance)
                  {
                     slPrice = Ask - (upperEnv2 - Ask);
                     tp1Price = upperEnv2;
                  }
                  else if (Ask > upperEnv2 - emaZoneTolerance)
                  {
                     slPrice = Ask - (upperEnv3 - Ask);
                     tp1Price = upperEnv3;
                  }
                  
                  if (useAtrAsSL)
                  {
                     slPrice = Low[iLowest(Symbol(), PERIOD_CURRENT, MODE_LOW, takeExtremaOfBarsBack, 1)] - atrMultiplier*atr;
                  }
               }
               
               slPrice = NormalizeDouble(slPrice, Digits());
               tp1Price = NormalizeDouble(tp1Price, Digits());
               
               double rrr = (tp1Price - Ask) / (Ask - slPrice);
               rrr = NormalizeDouble(rrr, Digits());
               
               if (rrr < RRRGreaterThan) { return; }
               
               // Pivot Point stuff (uses external indicator) and Entry price > pivot point
               if ((usePivots && pp != 0.0 && pp != 2147483647.0 && Ask > pp) || !usePivots)
               {
                  if ((useMACD && macd < 0) || !useMACD)
                  {
                     if ((useOsMA && osma > 0) || !useOsMA)
                     {
                        if (((useBullishEngulfingPattern && (EngulfingPatterns::CheckPatternBullishEngulfing(bigCandleBody, 2, 1) || EngulfingPatterns::CheckPatternBullishEngulfing(bigCandleBody, 3, 2))) || !useBullishEngulfingPattern)   ||
                            ((useDragonflyDojiPattern    && (DojiPatterns::CheckPatternDragonflyDoji(bigCandleBody, 1)            || DojiPatterns::CheckPatternDragonflyDoji(bigCandleBody, 2)))            || !useDragonflyDojiPattern)      ||
                            ((useStrongHammerPattern     && (HammerPatterns::CheckPatternStrongHammer(bigCandleBody, 1)           || HammerPatterns::CheckPatternStrongHammer(bigCandleBody, 2)))           || !useStrongHammerPattern)       ||
                            ((useWeakerHammerPattern     && (HammerPatterns::CheckPatternWeakerHammer(bigCandleBody, 1)           || HammerPatterns::CheckPatternWeakerHammer(bigCandleBody, 2)))           || !useWeakerHammerPattern))
                        {
                           OrderManager::PlaceMarketOrderFixedPriceSLTP(OP_BUY, OrderManager::CalcLots(risk), "QuadEMA", slPrice, tp1Price);
                        }
                     }
                  }
               }
            }
         }
      }
   }
   
   // -----------------------------------------------------------
   // SELL CONDITION
   // -----------------------------------------------------------
   
   // EMAs aligned (like a fan)
   if ((useFourthPeriod && ema20 < ema50 && ema50 < ema100 && ema100 < ema200) ||
       (!useFourthPeriod && ema20 < ema50 && ema50 < ema100))
   {
      // Entry condition
      if (((useFirstEmaAsEntry && Close[2] < ema20 + emaZoneTolerance && Close[2] > ema20 - emaZoneTolerance && Close[1] < ema20)    ||
          (Close[2] < ema50 + emaZoneTolerance && Close[2] > ema50 - emaZoneTolerance && Close[1] < ema50))    &&
          (Close[1] < ema200 && Close[2] < ema200))
      {
         if (((ema20/ema50) * 100 < deviationMaxPercentage && (ema50/ema100) * 100 < deviationMaxPercentage))
         {
            // Bullish candle and last candle is not too big
            if (Close[2] > Open[2] && MathAbs(Close[1] - Open[1]) < bigCandleBody)
            {
               double slPrice = Bid + slPoints*Point();
               double tp1Price = Bid - tpPoints*Point();
               
               if (slPrice > ema200) { slPrice = ema200; }
               
               if (useEnvelopes)
               {
                  slPrice = Bid + (Bid - lowerEnv);
                  tp1Price = lowerEnv;
                  
                  if (Bid < lowerEnv + emaZoneTolerance)
                  {
                     slPrice = Bid + (Bid - lowerEnv2);
                     tp1Price = lowerEnv2;
                  }
                  else if (Bid < lowerEnv2 + emaZoneTolerance)
                  {
                     slPrice = Bid + (Bid - lowerEnv3);
                     tp1Price = lowerEnv3;
                  }
                  
                  if (useAtrAsSL)
                  {
                     slPrice = High[iHighest(Symbol(), PERIOD_CURRENT, MODE_HIGH, takeExtremaOfBarsBack, 1)] + atrMultiplier*atr;
                  }
               }
               
               slPrice = NormalizeDouble(slPrice, Digits());
               tp1Price = NormalizeDouble(tp1Price, Digits());
               
               double rrr = (Bid - tp1Price) / (slPrice - Bid);
               rrr = NormalizeDouble(rrr, Digits());
               
               if (rrr < RRRGreaterThan) { return; }
               
               // Pivot Point stuff (uses external indicator) and Entry price < pivot point
               if ((usePivots && pp != 0.0 && pp != 2147483647.0 && Bid < pp) || !usePivots)
               {
                  if ((useMACD && macd > 0) || !useMACD)
                  {
                     if ((useOsMA && osma < 0) || !useOsMA)
                     {
                        if (((useBearishEngulfingPattern && (EngulfingPatterns::CheckPatternBearishEngulfing(bigCandleBody, 2, 1) || EngulfingPatterns::CheckPatternBearishEngulfing(bigCandleBody, 3, 2))) || !useBearishEngulfingPattern)   ||
                            ((useGravestoneDojiPattern   && (DojiPatterns::CheckPatternGravestoneDoji(bigCandleBody, 1)           || DojiPatterns::CheckPatternGravestoneDoji(bigCandleBody, 2)))           || !useGravestoneDojiPattern))
                        {
                           OrderManager::PlaceMarketOrderFixedPriceSLTP(OP_SELL, OrderManager::CalcLots(risk), "QuadEMA", slPrice, tp1Price);
                        }
                     }
                  }
               }
            }
         }
      }
   }
   
   DrawDot(1, ema20, clrLightCyan);
   DrawDot(1, ema50, clrAqua);
   DrawDot(1, ema100, clrDeepSkyBlue);
   DrawDot(1, ema200, clrBlue);
}

bool IsNewBar()
{
   static datetime lastbar;
   datetime curbar = Time[0];
   
   if(lastbar!=curbar) {
      lastbar=curbar;
      return (true);
   }
   else { return(false); }
}

void DrawDot(int index, double value, color clr)
{
   static int id;
   id++;
   
   ObjectCreate("CP_Dot" + (string)id, OBJ_ELLIPSE, 0, Time[index], value, Time[index], value);
   ObjectSetInteger(0, "CP_Dot" + (string)id, OBJPROP_COLOR, clr);
}