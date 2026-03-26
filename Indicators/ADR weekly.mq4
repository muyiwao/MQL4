//+------------------------------------------------------------------+
//|                                                   ADR weekly.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property indicator_chart_window

extern int      NumOfWeeks             = 14;
extern string   FontName              = "Verdana";
extern int      FontSize              = 8;
extern color    FontColor             = LightGray;
extern int      Window                = 0;
extern int      Window_Corner          = 0;
extern int      HorizPos1              = 5;
extern int      VertPos1               = 12;

double pnt;
int    dig;
string objname1 = "adr_weekly_info";

//+------------------------------------------------------------------+
int init()  {
//+------------------------------------------------------------------+
  pnt = MarketInfo(Symbol(),MODE_POINT);
  dig = MarketInfo(Symbol(),MODE_DIGITS);
  if (dig == 3 || dig == 5) {
    pnt *= 10;
  }  
  ObjectCreate(objname1,OBJ_LABEL,Window,0,0);

  return(0);
}

//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
  ObjectDelete(objname1);

  return(0);
}

//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
  double W1=0;
  double hi = iHigh(NULL,PERIOD_W1,0);
  double lo = iLow(NULL,PERIOD_W1,0); 
  
  for(int i=1;i<=NumOfWeeks;i++)
      W1    =    W1  +  (iHigh(NULL,PERIOD_W1,i)-iLow(NULL,PERIOD_W1,i));
      
      W1 = W1/NumOfWeeks;
  
    string objtext1 = "AWR: " + DoubleToStr(W1/pnt,1) + " (" + NumOfWeeks + " weeks), Current Week: " + DoubleToStr((hi-lo)/pnt,1);
    ObjectSet(objname1,OBJPROP_CORNER,Window_Corner);
    ObjectSet(objname1,OBJPROP_XDISTANCE,HorizPos1);
    ObjectSet(objname1,OBJPROP_YDISTANCE,VertPos1);
    ObjectSetText(objname1,objtext1,FontSize,FontName,FontColor);
   
   

  return(0);
}

