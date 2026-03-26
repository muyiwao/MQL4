//+------------------------------------------------------------------+
//|                     Trendline Price Alert (Refactored)           |
//|                  Works with any trendline drawn on chart         |
//+------------------------------------------------------------------+
#property indicator_chart_window
extern double Distance   = 20;     // Alert sensitivity in points
extern bool   MsgAlerts  = false;   // Popup alerts
extern bool   eMailAlerts= false;   // Email alerts
extern bool   Push       = true;   // Push notifications
extern bool   ChangeColour = false;// Change trendline color after hit

extern color  ColorOfHitsLevel = Yellow;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int init() {
   Comment("");
   if(Digits == 3 || Digits == 5) Distance *= 10;
   return(0);
}
//+------------------------------------------------------------------+
int deinit() { Comment(""); return(0); }
//+------------------------------------------------------------------+
//| Main function                                                    |
//+------------------------------------------------------------------+
int start() {
   string objName;
   for(int i = ObjectsTotal()-1; i >= 0; i--) {
      objName = ObjectName(i);

      // Process only trendline-type objects
      int type = ObjectType(objName);
      //if(type != OBJ_TREND && type != OBJ_TRENDBYANGLE 
      //   && type != OBJ_CHANNEL && type != OBJ_STDDEVCHANNEL 
      //   && type != OBJ_REGRESSION) continue;
      if(type != OBJ_TRENDBYANGLE) continue;

      // Skip already triggered lines
      if(StringFind(ObjectDescription(objName), " READY", 0) >= 0) continue;

      // Get the price value of the trendline at current candle (shift=0)
      double CurrValue = ObjectGetValueByShift(objName, 0);

      // If market price is near the trendline
      if(MathAbs(Bid - CurrValue) <= Distance * Point) {
         
         string msg = Symbol() + " " + PerToStr(Period()) +
                      " Price " + DoubleToStr(Bid, Digits) +
                      " touched trendline: " + objName;

         if(MsgAlerts)   Alert(msg);
         if(eMailAlerts) SendMail(Symbol()+" Alert", msg);
         if(Push)        SendNotification(msg);

         // Mark as used
         string temptxt = ObjectDescription(objName);
         ObjectSetText(objName, temptxt + " READY", 10);
         if(ChangeColour) ObjectSet(objName, OBJPROP_COLOR, ColorOfHitsLevel);
      }
   }
   return(0);
}
//+------------------------------------------------------------------+
//| Convert Period to String                                         |
//+------------------------------------------------------------------+
string PerToStr(int p) {
   switch(p) {
      case PERIOD_M1 : return "M1";
      case PERIOD_M5 : return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1 : return "H1";
      case PERIOD_H4 : return "H4";
      case PERIOD_D1 : return "D1";
      case PERIOD_W1 : return "W1";
      case PERIOD_MN1: return "MN1";
      default        : return "Undefined";
   }
}
