//+------------------------------------------------------------------+
//| Indicator: PriceTouchAlert.mq4                                   |
//| Purpose: Alert when price touches or crosses chart objects       |
//| Author: Muyiwa                                                   |
//+------------------------------------------------------------------+
#property indicator_chart_window

// User Configurable Inputs
//input bool EnableSoundAlert = false;
input bool EnablePushAlert  = true;
input int  CheckInterval    = 1;  // Check every N seconds
input int  AlertCooldown    = 10; // Cooldown period in seconds between alerts for the same object

datetime lastCheckTime = 0;

// Arrays to store object names and their corresponding last alert times
string objectNames[];
datetime lastAlertTimes[];

//+------------------------------------------------------------------+
//| On Init                                                          |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("PriceTouchAlert Initialized.");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| On Tick                                                          |
//+------------------------------------------------------------------+
void start()
{
   if(TimeCurrent() - lastCheckTime < CheckInterval)
      return;
   //ObjectsDeleteAll();
   lastCheckTime = TimeCurrent();

   CheckAllObjects(EnablePushAlert);
   DrawLastSixH4Candles(PERIOD_W1, 1, 65280, 17623); 
   DrawLastSixH4Candles(PERIOD_D1, 1, 6605108, 6595327); 
   DrawLastSixH4Candles(PERIOD_H4, 1, 65280, 9868799); 
}

//+------------------------------------------------------------------+
//| Check all Chart Objects                                          |
//+------------------------------------------------------------------+
void CheckAllObjects(bool alertsOn)
{
   int totalObjects = ObjectsTotal(0, 0, -1);

   for(int i = 0; i < totalObjects; i++)
   {
      string objName = ObjectName(0, i);
      int objType = (int)ObjectType(objName);
      
      if(StringFind(objName, "_") == -1){ // Does not have the character ("_")
         switch(objType)
         {
            case OBJ_RECTANGLE:    CheckRectangle(objName, alertsOn);    break;
            case OBJ_CHANNEL:      CheckChannel(objName, alertsOn);      break;
            case OBJ_HLINE:        CheckHLine(objName, alertsOn);        break;
            case OBJ_TREND:        CheckTrendLine(objName, alertsOn);    break;
            case OBJ_VLINE:        CheckVLine(objName, alertsOn);        break;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check Rectangle                                                  |
//+------------------------------------------------------------------+
// Check for Rectangle Breakout Alert based on Close Price
void CheckRectangle(string name, bool alertsOn)
{
   double priceHigh = ObjectGetDouble(0, name, OBJPROP_PRICE1);
   double priceLow  = ObjectGetDouble(0, name, OBJPROP_PRICE2);

   double high = MathMax(priceHigh, priceLow);  // Upper boundary of Rectangle
   double low  = MathMin(priceHigh, priceLow);  // Lower boundary of Rectangle
   
   string arrowName = "SignalArrow";
   string direction = GetArrowDirection(arrowName);

   if(Close[0] < high && Close[1] > high && direction=="UP")
   {
      TriggerAlert(name, Symbol() + " - Price CLOSED ABOVE Rectangle: " + name, alertsOn);
   }
   else if(Close[0] > low && Close[1] < low && direction=="DOWN")
   {
      TriggerAlert(name, Symbol() + " - Price CLOSED BELOW Rectangle: " + name, alertsOn);
   }
}


//+------------------------------------------------------------------+
//| Check Channel                                                    |
//+------------------------------------------------------------------+
// Check for Channel Breakout Alert based on Close Price
void CheckChannel(string name, bool alertsOn)
{
   double price1 = ObjectGetDouble(0, name, OBJPROP_PRICE1);
   double price2 = ObjectGetDouble(0, name, OBJPROP_PRICE2);

   double high = MathMax(price1, price2);  // Upper boundary of the channel
   double low  = MathMin(price1, price2);  // Lower boundary of the channel
   
   string arrowName = "SignalArrow";
   string direction = GetArrowDirection(arrowName);

   if(Close[0] < high && Close[1] > high && direction=="UP")
   {
      TriggerAlert(name, Symbol() + " - Price CLOSED ABOVE Channel: " + name, alertsOn);
   }
   else if(Close[0] > low && Close[1] < low && direction=="DOWN")
   {
      TriggerAlert(name, Symbol() + " - Price CLOSED BELOW Channel: " + name, alertsOn);
   }
}


//+------------------------------------------------------------------+
//| Check Horizontal Line                                            |
//+------------------------------------------------------------------+
// Check for Horizontal Line Break Alert based on Close Price
void CheckHLine(string name, bool alertsOn)
{
   double price = ObjectGetDouble(0, name, OBJPROP_PRICE1);
   
   string arrowName = "SignalArrow";
   string direction = GetArrowDirection(arrowName);

   if(Close[0] < price && Close[1] > price && direction=="UP")  // Price closed above the horizontal line
   {
      TriggerAlert(name, Symbol() + " - Price closed ABOVE Horizontal Line: " + name, alertsOn);
   }
   else if(Close[0] > price && Close[1] < price && direction=="DOWN")  // Price closed below the horizontal line
   {
      TriggerAlert(name, Symbol() + " - Price closed BELOW Horizontal Line: " + name, alertsOn);
   }
}


//+------------------------------------------------------------------+
//| Check Trend Line                                                 |
//+------------------------------------------------------------------+
// Check for Trendline Break Alert based on Close Price
void CheckTrendLine(string name, bool alertsOn)
{
   double price = ObjectGetValueByTime(0, name, Time[1]);  // Use Time[1] for closed candle
   
   string arrowName = "SignalArrow";
   string direction = GetArrowDirection(arrowName);

   if(Close[0] < price && Close[1] > price && direction=="UP")  // Price closed above the trendline
   {
      TriggerAlert(name, Symbol() + " - Price closed ABOVE Trend Line: " + name, alertsOn);
   }
   else if(Close[0] > price && Close[1] < price && direction=="DOWN")  // Price closed below the trendline
   {
      TriggerAlert(name, Symbol() + " - Price closed BELOW Trend Line: " + name, alertsOn);
   }
}


//+------------------------------------------------------------------+
//| Check Vertical Line                                              |
//+------------------------------------------------------------------+
// Check for Vertical Line Alert when candle closes exactly at line time
void CheckVLine(string name, bool alertsOn)
{
   datetime lineTime = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME1);
   
   //string arrowName = "SignalArrow";
   //string direction = GetArrowDirection(arrowName);

   // Check if the previous candle closed exactly at the Vertical Line time
   if(Time[1] == lineTime)
   {
      TriggerAlert(name, Symbol() + " - Candle CLOSED at Vertical Line: " + name, alertsOn);
   }
}


//+------------------------------------------------------------------+
//| Trigger Alert                                                    |
//+------------------------------------------------------------------+
void TriggerAlert(string objName, string message, bool alertOn)
{
   // Search for the object in the array
   int index = ArraySearch(objectNames, objName);

   if(index == -1)  // If the object is not found in the array, add it
   {
      ArrayResize(objectNames, ArraySize(objectNames) + 1);
      ArrayResize(lastAlertTimes, ArraySize(lastAlertTimes) + 1);

      objectNames[ArraySize(objectNames) - 1] = objName;
      lastAlertTimes[ArraySize(lastAlertTimes) - 1] = 0; // Initial last alert time set to 0
      index = ArraySize(objectNames) - 1;  // Set index to the last position
   }

   // Check if enough time has passed for the alert (cooldown period)
   if(TimeCurrent() - lastAlertTimes[index] >= AlertCooldown)
   {
      // Update the last alert time for this object
      lastAlertTimes[index] = TimeCurrent();

      Print(message);

      //if(EnableSoundAlert){
      //   Alert(message);}

      if(alertOn){
         SendNotification(message);}
   }
   else
   {
      Print("Alert skipped for: ", objName, " (Cooldown active)");
   }
}

//+------------------------------------------------------------------+
//| Function to search for a string in an array and return its index |
//+------------------------------------------------------------------+
int ArraySearch(string &arr[], string value)
{
   for(int i = 0; i < ArraySize(arr); i++)
   {
      if(arr[i] == value)
         return i;
   }
   return -1;
}


//+------------------------------------------------------------------+
// Returns:
// "UP"    - If it's an up arrow
// "DOWN"  - If it's a down arrow
// "UNKNOWN" - If not an arrow or type can't be determined
//+------------------------------------------------------------------+
string GetArrowDirection(string arrowName)
{
   if(ObjectFind(0, arrowName) < 0)
   {
      Print("Arrow not found: ", arrowName);
      return "UNKNOWN";
   }

   int arrowCode = (int)ObjectGetInteger(0, arrowName, OBJPROP_ARROWCODE);

   // Common arrow codes
   if(arrowCode == 233 || arrowCode == 225 || arrowCode == 241)
      return "UP";

   if(arrowCode == 234 || arrowCode == 226 || arrowCode == 242)
      return "DOWN";

   // Could add more specific checks based on your arrow style
   return "UNKNOWN";
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Draws the last 6 H4 candles as rectangles on all timeframes     |
//+------------------------------------------------------------------+
void DrawLastSixH4Candles(ENUM_TIMEFRAMES timeframe = PERIOD_H4, int totalCandles = 6, int upColor = clrPaleGreen, int downColor = clrLightPink)
{
    //if (symbol == NULL) symbol = Symbol();

    //int totalCandles = 6;
    
    string timeframeLabel = "";
    if(timeframe == PERIOD_D1){timeframeLabel = "D1";}
    if(timeframe == PERIOD_H4){timeframeLabel = "H4";}

    for (int i = 0; i < totalCandles; i++)
    {
        datetime openTime  = iTime(Symbol(), timeframe, i);
        datetime closeTime = iTime(Symbol(), timeframe, i + 1);

        double openPrice   = iOpen(Symbol(), timeframe, i);
        double closePrice  = iClose(Symbol(), timeframe, i);
        double highPrice   = iHigh(Symbol(), timeframe, i);
        double lowPrice    = iLow(Symbol(), timeframe, i);
        

        double top    = MathMax(openPrice, closePrice);
        double bottom = MathMin(openPrice, closePrice);

        color boxColor;
        if (closePrice > openPrice)
            boxColor = upColor;
        else if (closePrice < openPrice)
            boxColor = downColor;
        else
            boxColor = clrLightGray;

        string objName = "H4CandleBox_" + timeframeLabel + "_" + IntegerToString(i);

        // Delete old rectangle if exists
        ObjectDelete(0, objName);

        // Create rectangle for each H4 candle
        if (!ObjectCreate(0, objName, OBJ_RECTANGLE, 0, openTime, top, closeTime, bottom))
        {
            Print("Failed to create rectangle: ", objName);
            continue;
        }

        ObjectSetInteger(0, objName, OBJPROP_COLOR, boxColor);
        ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
        ObjectSetInteger(0, objName, OBJPROP_BACK, true);           // Behind candles
        ObjectSetInteger(0, objName, OBJPROP_TIMEFRAMES, 0);        // Show on all timeframes
    }
}

