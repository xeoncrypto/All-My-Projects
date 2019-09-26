//+------------------------------------------------------------------+
//|                                                      Drawing.mqh |
//|                                     Copyright 2019, Pascal Weber |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pascal Weber"
#property link      ""
#property version   "1.00"
#property strict

class Drawing
{
public:

   Drawing()
   {
   }
   
   static void DrawRectangle(int startIndex, int endIndex, double low, double high, color clr) {
      
      static int id;
      id++;
      
      ObjectCreate("CP_Rect" + (string)id, OBJ_RECTANGLE, 0, Time[startIndex], low, Time[endIndex], high);
      ObjectSetInteger(0, "CP_Rect" + (string)id, OBJPROP_COLOR, clr);
   }
   
   static void WriteText(int index, color clr, string text) {
      
      static int id;
      id++;
      double verticalOffset= Point * 500;
      
      ObjectCreate("CP_Label" + (string)id, OBJ_TEXT, 0, Time[index], High[index] + verticalOffset);
      ObjectSetText("CP_Label" + (string)id, text, 10, "Times New Roman", clr);
      ObjectSet("CP_Label" + (string)id, OBJPROP_ANGLE, 90);
   }
};