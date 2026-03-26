//+------------------------------------------------------------------+
//|                                              precision trend.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers  4
#property indicator_color1   clrMediumSeaGreen
#property indicator_color2   clrCrimson
#property indicator_color3   clrMediumSeaGreen
#property indicator_color4   clrCrimson

#property strict

//
//
//
enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mn1 = PERIOD_MN1,     // Monthly
   tf_n1  = -1,             // First higher time frame
   tf_n2  = -2,             // Second higher time frame
   tf_n3  = -3              // Third higher time frame
};
//
//

extern enTimeFrames    TimeFrame          = tf_cu;
extern int             avgPeriod   = 30;             // Average period
extern double          sensitivity = 3;              // Sensitivity
input int             WickWidth        = 1;                 // Candle wick width
input int             BodyWidth        = 2;                 // If auto width = false then use this
input bool            UseAutoWidth     = true;              // Auto adjust candle body width
extern bool            AlertsOn          = false;          // Turn alerts on?
extern bool            AlertsOnCurrent   = false;          // Alerts on still opened bar?
extern bool            AlertsMessage     = true;           // Alerts should display message?
extern bool            AlertsSound       = false;          // Alerts should play a sound?
extern bool            AlertsNotify      = false;          // Alerts should send a notification?
extern bool            AlertsEmail       = false;          // Alerts should send an email?
extern string          SoundFile         = "alert2.wav";   // Sound file


double xowu[],xowd[],xobu[],xobd[],count[],trend[];
int candlewidth=0;
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,0,avgPeriod,sensitivity,WickWidth,BodyWidth,UseAutoWidth,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsNotify,AlertsEmail,SoundFile,_buff,_ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
if (UseAutoWidth)
   {
      int scale = int(ChartGetInteger(0,CHART_SCALE));
      switch(scale) 
	   {
	      case 0: candlewidth =  1; break;
	      case 1: candlewidth =  1; break;
		   case 2: candlewidth =  2; break;
		   case 3: candlewidth =  3; break;
		   case 4: candlewidth =  6; break;
		   case 5: candlewidth = 14; break;
	   }
	}
	else { candlewidth = BodyWidth; }
	
   IndicatorBuffers(6);
      SetIndexBuffer(0,xowu); SetIndexStyle(0,DRAW_HISTOGRAM,0, WickWidth);
      SetIndexBuffer(1,xowd); SetIndexStyle(1,DRAW_HISTOGRAM,0,WickWidth);
      SetIndexBuffer(2,xobu); SetIndexStyle(2,DRAW_HISTOGRAM,0,candlewidth);
      SetIndexBuffer(3,xobd); SetIndexStyle(3,DRAW_HISTOGRAM,0,candlewidth); 
      SetIndexBuffer(4,trend);
      SetIndexBuffer(5,count); 
     
       
         indicatorFileName = WindowExpertName();
          TimeFrame         = (enTimeFrames)timeFrameValue(TimeFrame);
          
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
 {
 
 
 
  return; }



int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& btime[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] )
{
 if(ChartGetInteger(0,CHART_SCALE) != candlewidth) OnInit(); 
   int counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit=MathMin(rates_total-counted_bars,rates_total-1); count[0] = limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(6,0)*TimeFrame/Period()));
               for (int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  xowu[i] = EMPTY_VALUE;
                  xowd[i] = EMPTY_VALUE;
                  xobu[i] = EMPTY_VALUE;
                  xobd[i] = EMPTY_VALUE;
                  trend[i]    = _mtfCall(4,y);
                     if (trend[i] ==  1) { xowu[i] = High[i]; xowd[i] = Low[i]; xobu[i] = MathMax(Open[i],Close[i]); xobd[i] = MathMin(Open[i],Close[i]); }
                     if (trend[i] == -1) { xowd[i] = High[i]; xowu[i] = Low[i]; xobd[i] = MathMax(Open[i],Close[i]); xobu[i] = MathMin(Open[i],Close[i]); }            
            }
            return(0);
         }            
           

   //
   //
   //
   //
   //
            
   for(int i=limit; i>=0 && !_StopFlag; i--)
   {
                  xowu[i] = EMPTY_VALUE;
                  xowd[i] = EMPTY_VALUE;
                  xobu[i] = EMPTY_VALUE;
                  xobd[i] = EMPTY_VALUE;
      trend[i]    = iPrecisionTrend(high[i],low[i],close[i],avgPeriod,sensitivity,i,rates_total);
                     
                     if (trend[i] ==  1) { xowu[i] = High[i]; xowd[i] = Low[i]; xobu[i] = MathMax(Open[i],Close[i]); xobd[i] = MathMin(Open[i],Close[i]); }
                     if (trend[i] == -1) { xowd[i] = High[i]; xowu[i] = Low[i]; xobd[i] = MathMax(Open[i],Close[i]); xobu[i] = MathMin(Open[i],Close[i]); }       
   }
   manageAlerts();
   return(rates_total);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _ptInstances     1
#define _ptInstancesSize 8
double  _ptWork[][_ptInstances*_ptInstancesSize];
#define __range 0
#define __trend 1
#define __avgr  2
#define __avgd  3
#define __avgu  4
#define __minc  5
#define __maxc  6
#define __close 7
double iPrecisionTrend(double _high, double _low, double _close, int _period, double _sensitivity, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(_ptWork,0)!=bars) ArrayResize(_ptWork,bars); instanceNo*=_ptInstancesSize; int r=bars-i-1;
   
   //
   //
   //
   //
   //

   _ptWork[r][instanceNo+__close] = _close;
   _ptWork[r][instanceNo+__range] = _high-_low;
   _ptWork[r][instanceNo+__avgr]  = _ptWork[r][instanceNo+__range];
   int k=1; for (; k<_period && (r-k)>=0; k++) _ptWork[r][instanceNo+__avgr] += _ptWork[r-k][instanceNo+__range];
                                               _ptWork[r][instanceNo+__avgr] /= k;
                                               _ptWork[r][instanceNo+__avgr] *= _sensitivity;

      //
      //
      //
      //
      //
               
      if (r==0)
      {
         _ptWork[r][instanceNo+__trend] = 0;
         _ptWork[r][instanceNo+__avgd] = _close-_ptWork[r][instanceNo+__avgr];
         _ptWork[r][instanceNo+__avgu] = _close+_ptWork[r][instanceNo+__avgr];
         _ptWork[r][instanceNo+__minc] = _close;
         _ptWork[r][instanceNo+__maxc] = _close;
      }
      else
      {
         _ptWork[r][instanceNo+__trend] = _ptWork[r-1][instanceNo+__trend];
         _ptWork[r][instanceNo+__avgd]  = _ptWork[r-1][instanceNo+__avgd];
         _ptWork[r][instanceNo+__avgu]  = _ptWork[r-1][instanceNo+__avgu];
         _ptWork[r][instanceNo+__minc]  = _ptWork[r-1][instanceNo+__minc];
         _ptWork[r][instanceNo+__maxc]  = _ptWork[r-1][instanceNo+__maxc];
         
         //
         //
         //
         //
         //
         
         switch((int)_ptWork[r-1][instanceNo+__trend])
         {
            case 0 :
                  if (_close>_ptWork[r-1][instanceNo+__avgu])
                  {
                     _ptWork[r][instanceNo+__minc]  = _close;
                     _ptWork[r][instanceNo+__avgd]  = _close-_ptWork[r][instanceNo+__avgr];
                     _ptWork[r][instanceNo+__trend] =  1;
                  }
                  if (_close<_ptWork[r-1][instanceNo+__avgd])
                  {
                     _ptWork[r][instanceNo+__maxc]  = _close;
                     _ptWork[r][instanceNo+__avgu]  = _close+_ptWork[r][instanceNo+__avgr];
                     _ptWork[r][instanceNo+__trend] = -1;
                  }
                  break;
           case 1 :
                  _ptWork[r][instanceNo+__avgd] = _ptWork[r-1][instanceNo+__minc] - _ptWork[r][instanceNo+__avgr];
                     if (_close>_ptWork[r-1][instanceNo+__minc]) _ptWork[r][instanceNo+__minc] = _close;
                     if (_close<_ptWork[r-1][instanceNo+__avgd])
                     {
                        _ptWork[r][instanceNo+__maxc] = _close;
                        _ptWork[r][instanceNo+__avgu] = _close+_ptWork[r][instanceNo+__avgr];
                        _ptWork[r][instanceNo+__trend] = -1;
                     }
                  break;                  
            case -1 :
                  _ptWork[r][instanceNo+__avgu] = _ptWork[r-1][instanceNo+__maxc] + _ptWork[r][instanceNo+__avgr];
                     if (_close<_ptWork[r-1][instanceNo+__maxc]) _ptWork[r][instanceNo+__maxc] = _close;
                     if (_close>_ptWork[r-1][instanceNo+__avgu])
                     {
                        _ptWork[r][instanceNo+__minc]  = _close;
                        _ptWork[r][instanceNo+__avgd]  = _close-_ptWork[r][instanceNo+__avgr];
                        _ptWork[r][instanceNo+__trend] = 1;
                     }
         }
      }            
   return(_ptWork[r][instanceNo+__trend]);
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : MathAbs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)MathMin(i+add,size-1)]);
}

void manageAlerts()
{
   if (AlertsOn)
   {
      int whichBar = (AlertsOnCurrent) ? 0 : 1;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
      }         
   }
}   

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message = timeFrameToString(_Period)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" precision trend changed to : "+doWhat;
          if (AlertsMessage) Alert(message);
          if (AlertsNotify)  SendNotification(message);
          if (AlertsEmail)   SendMail(_Symbol+" precision trend ",message);
          if (AlertsSound)   PlaySound(SoundFile);
   }
}

