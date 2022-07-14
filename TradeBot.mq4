
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      ""
#property version   "1.00"
#property strict

extern int     BiggestCandleRange = 6;

extern bool    RoomToTheLeft     = true;

extern int     RoomToTheLeftCandles = 10;

extern double  RoomThreshold     = 5.0;

extern int     EntryPips = 40;

extern int     TakeProfitPips = 300;

extern double  LotsPerTrade = 1;

extern int     Slippage = 4;

extern int     ExpirationTime = 3600;

datetime CurrentBarTime;

int OnInit()
{

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

   
}

void OnTick()
{

   if( Time[0] > CurrentBarTime )
   
   {
   //A new bar is created
   CurrentBarTime = Time[0];
   
   //1. Is it an engulfing candle (Higher high and lower low)
   if( High[1] > High[2] && Low[1] < Low[2])
   {
      // Alert("There is an engulfing candle at", CurrentBarTime);
    // Step2. Check if the range is larger than the last X candles
         int HighestRangeCandle = GetHighestPreviousRangeCandle(BiggestCandleRange);
         
         if( HighestRangeCandle == 1)
         {
            //Alert("The previous candle is the biggest one over the last" + IntegerToString(BiggestCandleRange) + "candles");

            bool isBull = false;
            if( Open[1] < Close[1] )
               isBull = true;
                           
            if(RoomToTheLeft == true )
            {

            bool IsRoomToTheLeft = IsThereRoomToTheLeft ( isBull );
            if( IsRoomToTheLeft == false )
            {
               return;
            }
               Alert("The previous candle is the biggest engulfing, and has room to the left");
            }
            
            if( isBull == true )
            {
               //Create a BUY Order
               
               double EntryPoint = High[1] + EntryPips*Point(); //40*0.00001
               double StopLoss =  Open[1];
               double TakeProfit = EntryPoint + TakeProfitPips*Point(); 
               
               int ticket = OrderSend(Symbol(),OP_BUYSTOP,LotsPerTrade,EntryPoint,Slippage,StopLoss,TakeProfit,"This is an automated Bullish Big Shadow Trade",false,CurTime()+ExpirationTime);
               if( ticket == false)
               
               {
                  Alert("Something went wrong with creating the BUY order:", GetLastError());
               }
            }
            else{
               //Create a SELL Order
               double EntryPoint = Low[1] - EntryPips*Point(); //40*0.00001
               double StopLoss =  Open[1];
               double TakeProfit = EntryPoint - TakeProfitPips*Point(); 
               
               int ticket = OrderSend(Symbol(),OP_SELLSTOP,LotsPerTrade,EntryPoint,Slippage,StopLoss,TakeProfit,"This is an automated Bearish Big Shadow Trade",false,CurTime()+ExpirationTime);
               if( ticket == false)
               
               {
                  Alert("Something went wrong with creating the SELL order:", GetLastError());
               }
            }
            
         }
   
      }
   }
}

bool IsThereRoomToTheLeft (bool isBull)
{
   double Range = High[1] - Low[1];
   
   if(isBull == false)
   
   {
      //Is a Bearish Candle - Look at the Highs of the previous candles
      int HighestIndex = iHighest(NULL,0,MODE_HIGH,RoomToTheLeftCandles,2);
      double HighestValue = High[HighestIndex];
      
      if(HighestValue <  High[1] )
      {
         //There is room to the left, But How much?
         double RoomAvailable      = High[1] - HighestValue;
         double HowMuchRoomIsThere = (RoomAvailable/Range)*100;
         
         if(HowMuchRoomIsThere > RoomThreshold )
         {
            return true;
         }else{
            return false;
         }
      }else{
         return false;
      }
   }
   else{
      //Is a Bullish Candle - Look at the Lows of the previous candles
      int LowestIndex = iLowest(NULL,0,MODE_LOW,RoomToTheLeftCandles,2);
      double LowestValue = Low[LowestIndex];
      
      if(LowestValue >  Low[1] )
      {
         //There is room to the left, But How much?
         double RoomAvailable      = LowestValue - Low[1];
         double HowMuchRoomIsThere = (RoomAvailable/Range)*100;
         
         if(HowMuchRoomIsThere > RoomThreshold )
         {
            return true;
         }else{
            return false;
         }
      }else{
         return false;
      }
   }
   
}

int GetHighestPreviousRangeCandle(int bars)

{
   double Output[100] = {};
   
   for( int counter = 1; counter <= bars; counter++)
   {
      Output [counter] = High[counter] - Low[counter];
   }
   int HighestIdInOutput = ArrayMaximum(Output);
   
   return HighestIdInOutput;
}