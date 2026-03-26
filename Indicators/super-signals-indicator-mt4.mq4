//+------------------------------------------------------------------+
//|                                                super-signals.mq4 |
//|                Copyright © 2006, Nick Bilak, beluck[AT]gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Nick Bilak"
#property link      "http://www.forex-tsd.com/"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_color2 Lime
#property indicator_width2 2

extern int SignalGap = 4;

int dist=24;
double b1[];
double b2[];

int OnInit()
  {
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexArrow(1,233);
   SetIndexArrow(0,234);
   SetIndexBuffer(0,b1);
   SetIndexBuffer(1,b2);
   return(INIT_SUCCEEDED);
  }

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]) 
  {
   int i,limit,hhb,llb;
   if(prev_calculated<0) { return(rates_total); }
   limit=rates_total-1-MathMax(dist,prev_calculated);
   for (i=limit; i>=0; i--)
     {
      hhb = iHighest(NULL,0,MODE_HIGH,dist,i-dist/2);
      llb = iLowest(NULL,0,MODE_LOW,dist,i-dist/2);

      if (i==hhb) { b1[i]=High[hhb]+SignalGap*Point; }
      if (i==llb) { b2[i]=Low[llb] -SignalGap*Point; } 
     }
   return(rates_total);
  }
