// https://forex-station.com/viewtopic.php?p=1295478806#p1295478806 //button code1
// https://forex-station.com/viewtopic.php?p=1295478883#p1295478883 //button code2
// https://forex-station.com/viewtopic.php?p=1295413887#p1295413887 requested #1
// https://forex-station.com/viewtopic.php?p=1295414530#p1295414530 requested #2
#property copyright "www,forex-tsd.com"
#property link      "www,forex-tsd.com"

#property indicator_chart_window

//
//
//
//
//

enum timeFrames
{
   tf_cu,         // Current time frame
   tf_m1,         // 1 minute
   tf_m2,         // 2 minutes
   tf_m3,         // 3 minutes
   tf_m4,         // 4 minutes
   tf_m5,         // 5 minutes
   tf_m6,         // 6 minutes
   tf_m10 =10,    // 10 minutes
   tf_m12 =12,    // 12 minutes
   tf_m15 =15,    // 15 minutes
   tf_m20 =20,    // 20 minutes
   tf_m30 =30,    // 30 minutes
   tf_h1  =60,    // 1 hour
   tf_h2  =120,   // 2 hours
   tf_h3  =180,   // 3 hours
   tf_h4  =240,   // 4 hours
   tf_h6  =360,   // 6 hours
   tf_h8  =480,   // 8 hours
   tf_h12 =720,   // 12 hours
   tf_d1  =1440,  // daily
   tf_w1  =10080, // weekly
   tf_mn  =43200  // monthly
};
extern timeFrames         TimeFrame               = tf_cu;
extern string             btn_text                = "H1";                            // a button name
extern string             UniqueCandlesIdentifier = "H1";
extern string             UniqueButtonID          = "Candles";                       // Unique ID for each button        
extern color              UpCandleColor           = clrDeepSkyBlue;
extern color              DownCandleColor         = clrRed;
extern color              NeutralCandleColor      = clrDimGray;
extern color              TopWickColor            =clrRed;
extern color              BottomWickColor         =clrLime;
extern int                DrawingWidth            = 1;
extern bool               FilledCandles           = FALSE;
extern bool               BoxedWick               = TRUE;
extern int                barsToDraw              = 600;
extern bool               DisplayOHLC             = true;

//Forex-Station button template start41; copy and paste
extern string             button_note1_           = "------------------------------";
extern int                btn_Subwindow           = 0;                               // What window to put the button on.  If <0, the button will use the same sub-window as the indicator.
extern ENUM_BASE_CORNER   btn_corner              = CORNER_LEFT_UPPER;               // button corner on chart for anchoring
extern string             btn_Font                = "Arial";                         // button font name
extern int                btn_FontSize            = 9;                               // button font size               
extern color              btn_text_ON_color       = clrLime;                         // ON color when the button is turned on
extern color              btn_text_OFF_color      = clrRed;                          // OFF color when the button is turned off
extern color              btn_background_color    = clrDimGray;                      // background color of the button
extern color              btn_border_color        = clrBlack;                        // border color the button
extern int                button_x                = 20;                              // x coordinate of the button     
extern int                button_y                = 25;                              // y coordinate of the button     
extern int                btn_Width               = 80;                              // button width
extern int                btn_Height              = 20;                              // button height
extern string             button_note2            = "------------------------------";
//"",btn_Subwindow,btn_corner,btn_text,btn_Font,btn_FontSize,btn_text_ON_color,btn_text_OFF_color,btn_background_color,btn_border_color,button_x,button_y,btn_Width,btn_Height,UniqueButtonID,"",

bool show_data, recalc=false;
string IndicatorObjPrefix, buttonId;
//Forex-Station button template end41; copy and paste
//
//
//
//
//

int timeFrame;
//+------------------------------------------------------------------------------------------------------------------+
//Forex-Station button template start42; copy and paste
int OnInit()
{
   IndicatorDigits(Digits);
   IndicatorObjPrefix = "__" + btn_text + "__";
      
   // The leading "_" gives buttonId a *unique* prefix.  Furthermore, prepending the swin is usually unique unless >2+ of THIS indy are displayed in the SAME sub-window. (But, if >2 used, be sure to shift the buttonId position)
   buttonId = "_" + IndicatorObjPrefix + UniqueButtonID + "_BT_";
   if (ObjectFind(buttonId)<0) 
      createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);

   init2();

   show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
   
   if (show_data) ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color); 
   else ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
void createButton(string buttonID,string buttonText,int width2,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (0,buttonID);
      ObjectCreate    (0,buttonID,OBJ_BUTTON,btn_Subwindow,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width2);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (0,buttonID,OBJPROP_FONT,font);
      ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      // Upon creation, set the initial state to "true" which is "on", so one will see the indicator by default
      ObjectSetInteger(0, buttonId, OBJPROP_STATE, true);
}
//+------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason) 
{
   // This 'ObjectsDeleteAll' is only needed when any objects *besides* the button are created, but this indicator does not, hence, not needed.
   //ObjectsDeleteAll(0, IndicatorObjPrefix);

   // If just changing a TF', the button need not be deleted, therefore the 'OBJPROP_STATE' is also preserved.
   if(reason != REASON_CHARTCHANGE) ObjectDelete(buttonId);
   deinit2();
}
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // If another indy on the same chart has enabled events for create/delete/mouse-move, just skip this events up front because they aren't
   //    needed, AND in the worst case, this indy might cause MT4 to hang!!  Skipping the events seems to help, along with other (major) changes to the code below.
   if(id==CHARTEVENT_OBJECT_CREATE || id==CHARTEVENT_OBJECT_DELETE) return; // This appears to make this indy compatible with other programs that enabled CHART_EVENT_OBJECT_CREATE and/or CHART_EVENT_OBJECT_DELETE
   if(id==CHARTEVENT_MOUSE_MOVE    || id==CHARTEVENT_MOUSE_WHEEL)   return; // If this, or another program, enabled mouse-events, these are not needed below, so skip it unless actually needed. 

   if (id==CHARTEVENT_OBJECT_CLICK && sparam == buttonId)
   {
      show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
      
      if (show_data)
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color); 
         init2();
         // Is it a problem to call 'start()' ??  Possibly it makes no difference, but now calling "mystart()" instead of "start()"; and "start()" simply runs "mystart()", so should be same as before.
         recalc=true;
         mystart();
      }
      else
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
         deinit2();
      }
   }
}
//Forex-Station button template end42; copy and paste
//+------------------------------------------------------------------------------------------------------------------+
int init2()
{
   timeFrame = MathMax(TimeFrame,_Period);
         if (MathFloor(timeFrame/Period())*Period() != timeFrame) timeFrame = Period();
   return(0);
}
//+------------------------------------------------------------------------------------------------------------------+
int deinit2() { deleteCandles(); Comment(""); return(0); }
//+------------------------------------------------------------------------------------------------------------------+
void deleteCandles()
{
   int searchLength = StringLen(UniqueCandlesIdentifier);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string name = ObjectName(i);
         if (StringSubstr(name,0,searchLength) == UniqueCandlesIdentifier)  ObjectDelete(name);
   }
}
//+------------------------------------------------------------------------------------------------------------------+
int start() {return(mystart()); }
//+------------------------------------------------------------------------------------------------------------------+
int mystart()
  {
   if (show_data)
      {
   static int oldBars = 0;
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;

        if(recalc) 
        {
           // If a button goes from off-to-on, everything must be recalculated.  The 'recalc' variable is used as a trigger to do this.
           counted_bars = 0;
           recalc=false;
        }

           limit=MathMin(Bars-counted_bars,Bars-1);
           if (oldBars!=Bars)
           {
               deleteCandles();
                  oldBars = Bars;
                  limit   = Bars-1;
           }               

   //
   //
   //
   //
   //
   
   int barsToDisplay = barsToDraw; if (barsToDisplay<=0) barsToDisplay=Bars;
   for (i=limit; i>= 0; i--)
   {
      datetime startingTime;
      int      barsPassed;
      int      startOfThisBar;

         while (true)
         {
            if (timeFrame<60)
            {
               startingTime   = StrToTime(TimeToStr(Time[i],TIME_DATE)+toHour(TimeHour(Time[i])));
               barsPassed     = MathFloor((Time[i]-startingTime)/(timeFrame*60));
               startOfThisBar = iBarShift(NULL,0,startingTime+barsPassed*timeFrame*60);
               break;
            }
            if (timeFrame<1440)
            {
               startingTime   = StrToTime(TimeToStr(Time[i],TIME_DATE)+" 00:00");
               barsPassed     = MathFloor((Time[i]-startingTime)/(timeFrame*60));
               startOfThisBar = iBarShift(NULL,0,startingTime+barsPassed*timeFrame*60);
               break;
            }
            startingTime   = iTime(NULL,timeFrame,iBarShift(NULL,timeFrame,Time[i])); if (timeFrame==tf_w1) startingTime+=1440*60;
            startOfThisBar = iBarShift(NULL,0,startingTime);
            break;
         }         

         //
         //
         //
         //
         //
         
            datetime startTime  = Time[startOfThisBar];
            datetime endTime    = startTime+(timeFrame-1)*60;
            double   openPrice  = Open[startOfThisBar];
            double   closePrice = Close[startOfThisBar];
            double   highPrice  = High[startOfThisBar];
            double   lowPrice   = Low[startOfThisBar];
         
            for (int k=1; Time[startOfThisBar-k]>0 && Time[startOfThisBar-k]<=endTime; k++)
               {
                  closePrice = Close[startOfThisBar-k];
                  highPrice  = MathMax(highPrice,High[startOfThisBar-k]);
                  lowPrice   = MathMin(lowPrice,Low[startOfThisBar-k]);
               }

         //
         //
         //
         //
         //
         
         if (i<barsToDisplay) drawCandle(startTime,endTime,openPrice,closePrice,highPrice,lowPrice);
   }

   //
   //
   //
   //
   //
   
   if (DisplayOHLC) Comment("Current "+Symbol()+" "+timeFrameToString(timeFrame)+" candle : ",DoubleToStr(openPrice,Digits),",",DoubleToStr(highPrice,Digits),",",DoubleToStr(lowPrice,Digits),",",DoubleToStr(closePrice,Digits));
      } //if (show_data)  
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string toHour(int hour)
{
   if (hour<10)
         return(" 0"+hour+":00");
   else  return(" " +hour+":00");
}

//
//
//
//
//


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void drawCandle(datetime startTime, datetime endTime, double openPrice, double closePrice, double highPrice, double lowPrice)
{
   color candleColor = NeutralCandleColor;
   
      if (closePrice>openPrice) candleColor = UpCandleColor;
      if (closePrice<openPrice) candleColor = DownCandleColor;

   //
   //
   //
   //
   //
         
      string name = UniqueCandlesIdentifier+":"+startTime;
      if (ObjectFind(name)==-1)
          ObjectCreate(name,OBJ_RECTANGLE,0,startTime,openPrice,endTime,closePrice);
             ObjectSet(name,OBJPROP_PRICE1,openPrice);
             ObjectSet(name,OBJPROP_PRICE2,closePrice);
             ObjectSet(name,OBJPROP_TIME1 ,startTime);
             ObjectSet(name,OBJPROP_TIME2 ,endTime);
             ObjectSet(name,OBJPROP_COLOR ,candleColor);
             ObjectSet(name,OBJPROP_STYLE ,STYLE_DASHDOTDOT);
             ObjectSet(name,OBJPROP_BACK  ,FilledCandles);
             ObjectSet(name,OBJPROP_WIDTH ,DrawingWidth);
             
      //
      //
      //
      //
      //
                   
      datetime wickTime = startTime+(endTime-startTime)/2;
      double   upPrice  = MathMax(closePrice,openPrice);
      double   dnPrice  = MathMin(closePrice,openPrice);
      
      if (BoxedWick)
      {
         string   wname = name+":+";
         if (ObjectFind(wname)==-1)
             ObjectCreate(wname,OBJ_RECTANGLE,0,startTime,highPrice,endTime,lowPrice);
                ObjectSet(wname,OBJPROP_PRICE1,highPrice);
                ObjectSet(wname,OBJPROP_PRICE2,lowPrice);
                ObjectSet(wname,OBJPROP_TIME1 ,startTime);
                ObjectSet(wname,OBJPROP_TIME2 ,endTime);
                ObjectSet(wname,OBJPROP_COLOR ,candleColor);
                ObjectSet(wname,OBJPROP_STYLE ,STYLE_DOT);
                ObjectSet(wname,OBJPROP_BACK  ,false);
                ObjectSet(wname,OBJPROP_WIDTH ,DrawingWidth);
      }
      else
      {
         wname = name+":+";
         if (ObjectFind(wname)==-1)
             ObjectCreate(wname,OBJ_TREND,0,wickTime,highPrice,wickTime,upPrice);
                ObjectSet(wname,OBJPROP_PRICE1,highPrice);
                ObjectSet(wname,OBJPROP_PRICE2,upPrice);
                ObjectSet(wname,OBJPROP_TIME1 ,wickTime);
                ObjectSet(wname,OBJPROP_TIME2 ,wickTime);
                ObjectSet(wname,OBJPROP_COLOR ,TopWickColor);
                ObjectSet(wname,OBJPROP_STYLE ,STYLE_SOLID);
                ObjectSet(wname,OBJPROP_RAY   ,false);
                ObjectSet(wname,OBJPROP_WIDTH ,DrawingWidth);

         wname = name+":-";
         if (ObjectFind(wname)==-1)
             ObjectCreate(wname,OBJ_TREND,0,wickTime,dnPrice,wickTime,lowPrice);
                ObjectSet(wname,OBJPROP_PRICE1,dnPrice);
                ObjectSet(wname,OBJPROP_PRICE2,lowPrice);
                ObjectSet(wname,OBJPROP_TIME1 ,wickTime);
                ObjectSet(wname,OBJPROP_TIME2 ,wickTime);
                ObjectSet(wname,OBJPROP_COLOR ,BottomWickColor);
                ObjectSet(wname,OBJPROP_STYLE ,STYLE_SOLID);
                ObjectSet(wname,OBJPROP_RAY   ,false);
                ObjectSet(wname,OBJPROP_WIDTH ,DrawingWidth);
      }                
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M2","M3","M4","M5","M6","M10","M12","M15","M20","M30","H1","H2","H3","H4","H6","H8","H12","D1","W1","MN"};
int    iTfTable[] = {1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}