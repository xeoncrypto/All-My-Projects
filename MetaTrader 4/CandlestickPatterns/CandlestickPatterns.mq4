//+------------------------------------------------+
//|                                                |
//|           CandlestickPatternsEA.mq4            |
//|          Copyright 2019, Pascal Weber          |
//|                                                |
//+------------------------------------------------+

#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict

#include "EngulfingPatterns.mqh"
#include "DojiPatterns.mqh"
#include "HammerPatterns.mqh"

double BIG_CANDLE_BODY_H1;
double BIG_CANDLE_BODY_H4;
double BIG_CANDLE_BODY_D1;
int CALCULATE_MAX_BARS_BACK;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   BIG_CANDLE_BODY_H1 = 200 * Point();
   BIG_CANDLE_BODY_H4 = 300 * Point();
   BIG_CANDLE_BODY_D1 = 900 * Point();
   CALCULATE_MAX_BARS_BACK = 1000;
   
   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "CP_", 0, OBJ_RECTANGLE);
   ObjectsDeleteAll(0, "CP_", 0, OBJ_TEXT);
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if (!IsNewBar())
      return;
   
   EngulfingPatterns::CheckPatternBearishEngulfing(1, 2, BIG_CANDLE_BODY_H4);
   EngulfingPatterns::CheckPatternBullishEngulfing(1, 2, BIG_CANDLE_BODY_H4);
   DojiPatterns:: CheckPatternGravestoneDoji(BIG_CANDLE_BODY_H4);
   DojiPatterns::CheckPatternDragonflyDoji(BIG_CANDLE_BODY_H4);
   HammerPatterns::CheckPatternStrongHammer(BIG_CANDLE_BODY_H4);
   HammerPatterns::CheckPatternWeakerHammer(BIG_CANDLE_BODY_H4);
}

bool IsNewBar() {

   static datetime lastbar;
   datetime curbar = Time[0];
   
   if(lastbar!=curbar) {
      lastbar=curbar;
      return (true);
   }
   else { return(false); }
}