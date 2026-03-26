#property strict

extern double RiskPercent = 1.0;   // % risk per trade
extern int    StopLossPips = 12;
extern int    TakeProfitPips = 12;
extern int    MaxSpread = 15;
extern int    Slippage = 5;

extern int LondonStart = 8;
extern int LondonEnd   = 12;
extern int NYStart     = 13;
extern int NYEnd       = 17;

string Name_EA = "SCA_SAFE";

double pip;

//--------------------------------------------------
int OnInit()
{
   pip = (Digits == 3 || Digits == 5) ? Point * 10 : Point;
   return(INIT_SUCCEEDED);
}
//--------------------------------------------------
void OnTick()
{
   if(Bars < 100) return;
   if(OrdersTotal() > 0) return;
   if(!IsSession()) return;
   if(CurrentSpread() > MaxSpread) return;

   double price = Close[0];
   double ma50  = iMA(NULL, PERIOD_M5, 50, 0, MODE_SMA, PRICE_CLOSE, 0);

   if(price < ma50) OpenSell();
   if(price > ma50) OpenBuy();
}
//--------------------------------------------------
void OpenBuy()
{
   double sl = Ask - StopLossPips * pip;
   double tp = Ask + TakeProfitPips * pip;
   double lot = CalcLot(StopLossPips);

   OrderSend(Symbol(), OP_BUY, lot, Ask, Slippage,
             NormalizeDouble(sl,Digits),
             NormalizeDouble(tp,Digits),
             Name_EA, 0, 0, clrBlue);
}
//--------------------------------------------------
void OpenSell()
{
   double sl = Bid + StopLossPips * pip;
   double tp = Bid - TakeProfitPips * pip;
   double lot = CalcLot(StopLossPips);

   OrderSend(Symbol(), OP_SELL, lot, Bid, Slippage,
             NormalizeDouble(sl,Digits),
             NormalizeDouble(tp,Digits),
             Name_EA, 0, 0, clrRed);
}
//--------------------------------------------------
double CalcLot(double stopPips)
{
   double riskMoney = AccountBalance() * RiskPercent / 100.0;
   double pipValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double lot = riskMoney / (stopPips * pipValue);

   return NormalizeDouble(MathMax(0.01, lot), 2);
}
//--------------------------------------------------
bool IsSession()
{
   int h = TimeHour(TimeCurrent());
   return ((h >= LondonStart && h < LondonEnd) ||
           (h >= NYStart && h < NYEnd));
}
//--------------------------------------------------
int CurrentSpread()
{
   return (int)((Ask - Bid) / pip);
}
