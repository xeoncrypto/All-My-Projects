//+------------------------------------------------------------------+
//|                                                      Program.mqh |
//|                                     Copyright 2019, Pascal Weber |
//+------------------------------------------------------------------+
#include <EasyAndFastGUI\Controls\WndEvents.mqh>
//+------------------------------------------------------------------+
//| Class for creating an application                                |
//+------------------------------------------------------------------+
class CProgram : public CWndEvents
  {
private:
   //--- Form 1
   CWindow           m_window1;
   //--- Main menu and its context menus
   CMenuBar          m_menubar;
   CContextMenu      m_mb_contextmenu1;
   CContextMenu      m_mb_contextmenu2;
   CContextMenu      m_mb_contextmenu3;
   CContextMenu      m_mb_contextmenu4;
   //--- Edit box table
   CTable            m_table;
   //--- Status Bar
   CStatusBar        m_status_bar;
   //--- Buttons
   CSimpleButton     m_simple_button;
   //---
public:
                     CProgram(void);
                    ~CProgram(void);
   //--- Initialization/deinitialization
   void              OnInitEvent(void);
   void              OnDeinitEvent(const int reason);
   //--- Timer
   void              OnTimerEvent(void);
   //---
protected:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //---
public:
   //--- Create the indicator panel
   bool              CreateIndicatorPanel(void);
   //---
private:
   //--- Form 1
   bool              CreateWindow1(const string text);

   //--- Main menu and its context menus
#define MENUBAR_GAP_X         (1)
#define MENUBAR_GAP_Y         (20)
   //--- Status Bar
#define STATUSBAR1_GAP_X      (1)
#define STATUSBAR1_GAP_Y      (332)
   bool              CreateStatusBar(void);
   //--- Edit box table
#define TABLE1_GAP_X          (1)
#define TABLE1_GAP_Y          (43)
   bool              CreateTable(void);
#define BUTTON_GAP_X            (1)
#define BUTTON_GAP_Y            (21)
   bool              CreateSimpleButton(const string text);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgram::~CProgram(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void CProgram::OnInitEvent(void)
  {
  }
//+------------------------------------------------------------------+
//| Uninitialization                                                 |
//+------------------------------------------------------------------+
void CProgram::OnDeinitEvent(const int reason)
  {
//--- Removing the interface
   CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CProgram::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();
//--- Updating the second item of the status bar every 500 milliseconds
   static int count=0;
   if(count<500)
     {
      count+=TIMER_STEP_MSC;
      return;
     }
//--- Zero the counter
   count=0;
//--- Change the value in the second item of the status bar
   m_status_bar.ValueToItem(1,TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS));
//--- Redraw the chart
   m_chart.Redraw();
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CProgram::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Clicking on the menu item event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CONTEXTMENU_ITEM)
     {
      ::Print(__FUNCTION__," > id: ",id,"; lparam: ",lparam,"; dparam: ",dparam,"; sparam: ",sparam);
     }
//--- Event of pressing on the list view item or table
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
     {
      ::Print(__FUNCTION__," > id: ",id,"; lparam: ",lparam,"; dparam: ",dparam,"; sparam: ",sparam);
     }
//--- Event of entering new value in the edit box
   if(id==CHARTEVENT_CUSTOM+ON_END_EDIT)
     {
      ::Print(__FUNCTION__," > id: ",id,"; lparam: ",lparam,"; dparam: ",dparam,"; sparam: ",sparam);
     }
  }
//+------------------------------------------------------------------+
//| Create indicator panel                                           |
//+------------------------------------------------------------------+
bool CProgram::CreateIndicatorPanel(void)
  {
//--- Creating form 1 for controls
   if(!CreateWindow1("Swap Display"))
      return(false);
//--- Creating the status bar
   if(!CreateStatusBar())
      return(false);
//--- Edit box table
   if(!CreateTable())
      return(false);
   if(!CreateSimpleButton("Swap rates for 1 standard lot per day"))
      return(false);
//--- Redrawing the chart
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates form 1 for controls                                      |
//+------------------------------------------------------------------+
bool CProgram::CreateWindow1(const string caption_text)
  {
//--- Add the window pointer to the window array
   CWndContainer::AddWindow(m_window1);
//--- Coordinates
   int x=(m_window1.X()>0) ? m_window1.X() : 1;
   int y=(m_window1.Y()>0) ? m_window1.Y() : 20;
//--- Properties
   m_window1.XSize(502);
   m_window1.YSize(358);
   m_window1.Movable(true);
   m_window1.UseRollButton();
//--- Creating the form
   if(!m_window1.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//---
   return(true);
  }

//+------------------------------------------------------------------+
//| Creates the status bar                                           |
//+------------------------------------------------------------------+
bool CProgram::CreateStatusBar(void)
  {
#define STATUS_LABELS_TOTAL 2
//--- Store the window pointer
   m_status_bar.WindowPointer(m_window1);
//--- Coordinates
   int x=m_window1.X()+STATUSBAR1_GAP_X;
   int y=m_window1.Y()+STATUSBAR1_GAP_Y;
//--- Width
   int width[]={0,110};
//--- Set properties before creation
   m_status_bar.YSize(24);
   m_status_bar.AutoXResizeMode(true);
   m_status_bar.AutoXResizeRightOffset(1);
//--- Specify the number of parts and set their properties
   for(int i=0; i<STATUS_LABELS_TOTAL; i++)
      m_status_bar.AddItem(width[i]);
//--- Create control
   if(!m_status_bar.CreateStatusBar(m_chart_id,m_subwin,x,y))
      return(false);
//--- Set text in the first item of the status bar
   m_status_bar.ValueToItem(0,"For Help, press F1");
//--- Add the element pointer to the base
   CWndContainer::AddToElementsArray(0,m_status_bar);
   return(true);
}


bool CProgram::CreateSimpleButton(string button_text)
{
//--- Pass the panel object
   m_simple_button.WindowPointer(m_window1);
//--- Coordinates
   int x=m_window1.X()+BUTTON_GAP_X;
   int y=m_window1.Y()+BUTTON_GAP_Y;
//--- Set properties before creation
   m_simple_button.TwoState(false);
   m_simple_button.ButtonXSize(500);
//--- Creating a button
   if(!m_simple_button.CreateSimpleButton(m_chart_id,m_subwin,button_text,x,y))
      return(false);
//--- Add the element pointer to the base
   CWndContainer::AddToElementsArray(0,m_simple_button);
   return(true);
}


bool CProgram::CreateTable(void)
{
   string accCurrency = AccountInfoString(ACCOUNT_CURRENCY);
   
   int total = SymbolsTotal(true);
   double raw[200][8];
   ArrayResize(raw, total, 0);
   
   for (int h = 0; h < ArrayRange(raw,0); h++)
   {
      raw[h][6] = MarketInfo(SymbolName(h, true), MODE_SWAPLONG);    // Swap Long
      raw[h][7] = MarketInfo(SymbolName(h, true), MODE_SWAPSHORT);   // Swap Short
      raw[h][2] = h;                                                 // Symbol ID
      raw[h][3] = 0;                                                 // Long and Short are swapped?; 0 = N; 1 = Y
      raw[h][4] = 0;                                                 // Reserved for Swap Long in margin currency
      raw[h][5] = 0;                                                 // Reserved for Swap Short in margin currency
      raw[h][0] = 0;                                                 // Reserved for Swap Long in account currency
      raw[h][1] = 0;                                                 // Reserved for Swap Short in account currency
   }
   
   for (int g = 0; g < ArrayRange(raw,0); g++)
   {
      // Swap = (One Point / Exchange rate) * 100.000 * swap in points
      string symnam = SymbolName((int)raw[g][2], true);
      raw[g][4] = (SymbolInfoDouble(symnam, SYMBOL_POINT) / SymbolInfoDouble(symnam, SYMBOL_BID)) * 100000 * SymbolInfoDouble(symnam, SYMBOL_SWAP_LONG);
      raw[g][5] = (SymbolInfoDouble(symnam, SYMBOL_POINT) / SymbolInfoDouble(symnam, SYMBOL_BID)) * 100000 * SymbolInfoDouble(symnam, SYMBOL_SWAP_SHORT);
   }
   
   for (int i = 0; i < total; i++)
   {
      string symname = SymbolName((int)raw[i][2], true);
      
      if (StringCompare(SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN), accCurrency, false) != 0)
      {
         double accLong = 0.0;
         double accShort = 0.0;
      
         // If in USD and Symbol is: EUR USD then divide
         // If in USD and Symbol is: USD EUR then multiply
         if (SymbolInfoDouble(SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN) + accCurrency, SYMBOL_BID) > 0.0)
         {
            accLong = raw[i][4] * SymbolInfoDouble(SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN) + accCurrency, SYMBOL_BID);
            accShort = raw[i][5] * SymbolInfoDouble(SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN) + accCurrency, SYMBOL_BID);
         }
         else if (SymbolInfoDouble(accCurrency + SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN), SYMBOL_BID) > 0.0)
         {
            accLong = raw[i][4] / SymbolInfoDouble(accCurrency + SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN), SYMBOL_BID);
            accShort = raw[i][5] / SymbolInfoDouble(accCurrency + SymbolInfoString(symname, SYMBOL_CURRENCY_MARGIN), SYMBOL_BID);
         }
         else
         {
            // Error: Did not find any Symbol to convert (wether USDEUR nor EURUSD)
            accLong = -99999.0;
            accShort = -99999.0;
         }
         
         raw[i][0] = accLong;
         raw[i][1] = accShort;
      }
      else
      {
         raw[i][0] = raw[i][4];
         raw[i][1] = raw[i][5];
      }
   }
   
   // -----------------------------------------------------------
   // Sort
   // -----------------------------------------------------------
   
   for (int j = 0; j < ArrayRange(raw,0); j++)
   {
      if (raw[j][0] == NULL)
         raw[j][0] = -10000;
      if (raw[j][1] == NULL)
         raw[j][1] = -10000;
            
      if (raw[j][0] < raw[j][1])
      {
         double temp1 = raw[j][0];
         raw[j][0] = raw[j][1];
         raw[j][1] = temp1;
         raw[j][3] = 1;
      }
   }
   
   ArraySort(raw, WHOLE_ARRAY, 0, MODE_DESCEND);
   
   for (int k = 0; k < ArrayRange(raw,0); k++)
   {
      if (raw[k][3] == 1)
      {
         double temp2 = raw[k][0];
         raw[k][0] = raw[k][1];
         raw[k][1] = temp2;
         raw[k][3] = 0;
      }
   }
  
#define COLUMNS1_TOTAL (5)
#define ROWS1_TOTAL    (total+1)

   m_table.WindowPointer(m_window1);
   
   int x=m_window1.X()+TABLE1_GAP_X;
   int y=m_window1.Y()+TABLE1_GAP_Y;
   
   int visible_columns_total =5;
   int visible_rows_total    =15;
   
   m_table.XSize(500);
   m_table.RowYSize(20);
   m_table.FixFirstRow(true);
   m_table.FixFirstColumn(true);
   m_table.LightsHover(true);
   m_table.SelectableRow(true);
   m_table.TextAlign(ALIGN_CENTER);
   m_table.HeadersColor(C'255,244,213');
   m_table.HeadersTextColor(clrBlack);
   m_table.CellColorHover(clrGold);
   m_table.TableSize(COLUMNS1_TOTAL,ROWS1_TOTAL);
   m_table.VisibleTableSize(visible_columns_total,visible_rows_total);
   
   if(!m_table.CreateTable(m_chart_id,m_subwin,x,y))
      return(false);
   
   m_table.SetValue(0,0," ");
   m_table.SetValue(1,0,"Long [Points]");
   m_table.SetValue(2,0,"Short [Points]");
   m_table.SetValue(3,0,"Long [Acc. Cur.]");
   m_table.SetValue(4,0,"Short [Acc. Cur.]");
   
   for(int r=1; r<ROWS1_TOTAL; r++)
   {
      m_table.SetValue(0,r,SymbolName((int)raw[r-1][2], true));
      m_table.TextAlign(0,r,ALIGN_RIGHT);
   }
   
   for(int r=1; r<ROWS1_TOTAL; r++)
   {
      string symnamn = SymbolName((int)raw[r-1][2], true);
      
      m_table.SetValue(1,r,DoubleToString(MarketInfo(symnamn, MODE_SWAPLONG), 2));
      m_table.TextColor(1,r,(1%2==0)? clrRed : clrRoyalBlue);
      m_table.CellColor(1,r,(r%2==0)? clrWhiteSmoke : clrWhite);
      
      m_table.SetValue(2,r,DoubleToString(MarketInfo(symnamn, MODE_SWAPSHORT), 2));
      m_table.TextColor(2,r,(2%2==0)? clrRed : clrRoyalBlue);
      m_table.CellColor(2,r,(r%2==0)? clrWhiteSmoke : clrWhite);
      
      m_table.SetValue(3,r,DoubleToString(raw[r-1][0], 2) + " " + accCurrency);
      m_table.TextColor(3,r,(3%2==0)? clrRed : clrRoyalBlue);
      m_table.CellColor(3,r,(r%2==0)? clrWhiteSmoke : clrWhite);
      
      m_table.SetValue(4,r,DoubleToString(raw[r-1][1], 2) + " " + accCurrency);
      m_table.TextColor(4,r,(4%2==0)? clrRed : clrRoyalBlue);
      m_table.CellColor(4,r,(r%2==0)? clrWhiteSmoke : clrWhite);
   }
//--- Update the table to display changes
   m_table.UpdateTable();
//--- Add the object to the common array of object groups
   CWndContainer::AddToElementsArray(0,m_table);
   return(true);
  }
//+------------------------------------------------------------------+
