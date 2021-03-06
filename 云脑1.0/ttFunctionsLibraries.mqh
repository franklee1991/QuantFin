#include    "ttOrdersVariables.mqh"          //订单相关结构变量定义文件
#include    "ttEnvironmentVariables.mqh"     //账户商品相关结构变量定义文件
#include    "ttUIFunctions.mqh"              //界面函数库
/*
函    数：获取交易时间窗口系统编码（系统方法需要用)
输出参数：
算法说明：根据传入的交易时间窗口，返回对应的系统编码
*/
int TurnTimeFrame(string timeFrame)
{
   if(timeFrame=="M1"){
      return(PERIOD_M1);
   }else if(timeFrame=="M5"){
      return(PERIOD_M5);
   }else if(timeFrame=="M15"){
      return(PERIOD_M15);
   }else if(timeFrame=="M30"){
      return(PERIOD_M30);
   }else if(timeFrame=="H1"){
      return(PERIOD_H1);
   }else if(timeFrame=="H4"){
      return(PERIOD_H4);
   }else if(timeFrame=="D1"){
      return(PERIOD_D1);
   }else if(timeFrame=="W1"){
      return(PERIOD_W1);
   }else if(timeFrame=="MN1"){
      return(PERIOD_MN1);
   }else{
      return(0);
   }   
} 


/*
函    数：交易延时
输出参数：
算法说明：
*/
void egTradeDelay(int myDelayTime)   //延时(毫秒)                
{
    while (!IsTradeAllowed() || IsTradeContextBusy()) Sleep(myDelayTime);
    RefreshRates();
    return;
}

/*
函    数:时间框架转中文字符
输出参数:
算法说明:
*/
string  egTimeFrameToString(ENUM_TIMEFRAMES     my_TimeFrame      //时间周期
                           )
{
    if (my_TimeFrame==PERIOD_M1)    return("M1");
    if (my_TimeFrame==PERIOD_M5)    return("M5");
    if (my_TimeFrame==PERIOD_M15)   return("M15");
    if (my_TimeFrame==PERIOD_M30)   return("M30");
    if (my_TimeFrame==PERIOD_H1)    return("H1");
    if (my_TimeFrame==PERIOD_H4)    return("H4");
    if (my_TimeFrame==PERIOD_D1)    return("D1");
    if (my_TimeFrame==PERIOD_W1)    return("W1");
    if (my_TimeFrame==PERIOD_MN1)   return("MN1");
    return((string)my_TimeFrame+"分钟");
}

/*
函    数:当前k线订单数量
输出参数:持仓/历史单在当前k线上的数量
算    法:
*/
int egOrdersInShift(TradesOrders        &myTradingOrders[], //持仓单数组
                    string              mySymbol,           //货币对名称
                    ENUM_TIMEFRAMES     myTimeFrame,        //时间框架
                    int                 myGroupType=-1,        //组类型，0-买入组，1-卖出组，-1全部组
                    bool                myHistory=true,          //true-含历史单，false-不含历史单
                    int                 myMagicNum=-1          //订单特征码 -1-全部
                   )
{
    datetime myBarOpenTime=iTime(mySymbol,myTimeFrame,0);    //当前k线开盘时间
    if (myBarOpenTime==0) return(-1);
    int myOrders=0;     //订单数量变量
    int i;            //循环计数器变量
    //统计卖出组
    if (myGroupType==OP_SELL)
    {
        //持仓单
        for (i=0;i<ArraySize(myTradingOrders);i++)
        {
            if (   (myTradingOrders[i].magicnumber==myMagicNum || myMagicNum==-1) //EA订单
                && myTradingOrders[i].symbol==mySymbol //指定货币对
                && myTradingOrders[i].type==OP_SELL //Sell类型
                && myBarOpenTime<=myTradingOrders[i].opentime //在k0
               )
            {
                myOrders++; //订单数量累计
            }
        }
        //历史单
        if (myHistory)
        {
            for (i=0;i<OrdersHistoryTotal();i++)
            {
                if (   OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
                    && (OrderMagicNumber()==myMagicNum || myMagicNum==-1) //EA订单
                    && OrderSymbol()==mySymbol //指定货币对
                    && OrderType()==OP_SELL //Sell类型
                    && myBarOpenTime<=OrderCloseTime() //在k0
                   )
                {
                    myOrders++; //订单数量累计
                }
            }
        }
    }
    //统计买入组
    if (myGroupType==OP_BUY)
    {
        //持仓单
        for (i=0;i<ArraySize(myTradingOrders);i++)
        {
            if (   (myTradingOrders[i].magicnumber==myMagicNum || myMagicNum==-1) //EA订单
                && myTradingOrders[i].symbol==mySymbol //指定货币对
                && myTradingOrders[i].type==OP_BUY //Buy类型
                && myBarOpenTime<=myTradingOrders[i].opentime //在k0
               )
            {
                myOrders++; //订单数量累计
            }
        }
        //历史单
        if (myHistory)
        {
            for (i=0;i<OrdersHistoryTotal();i++)
            {
                if (   OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
                    && (OrderMagicNumber()==myMagicNum || myMagicNum==-1) //EA订单
                    && OrderSymbol()==mySymbol //指定货币对
                    && OrderType()==OP_BUY //Buy类型
                    && myBarOpenTime<=OrderCloseTime() //在k0
                   )
                {
                    myOrders++; //订单数量累计
                }
            }
        }
    }
    if (myGroupType==-1)
    {
        //持仓单
        for (i=0;i<ArraySize(myTradingOrders);i++)
        {
            if (   (myTradingOrders[i].magicnumber==myMagicNum || myMagicNum==-1) //EA订单
                && myTradingOrders[i].symbol==mySymbol //指定货币对
                && myBarOpenTime<=myTradingOrders[i].opentime //在k0
               )
            {
                myOrders++; //订单数量累计
            }
        }
        //历史单
        if (myHistory)
        {
            for (i=0;i<OrdersHistoryTotal();i++)
            {
                if (   OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
                    && (OrderMagicNumber()==myMagicNum || myMagicNum==-1) //EA订单
                    && OrderSymbol()==mySymbol //指定货币对
                    && myBarOpenTime<=OrderCloseTime() //在k0
                   )
                {
                    myOrders++; //订单数量累计
                }
            }
        }
    }
    return(myOrders);
}


/*
函    数：刷新环境变量(当前商品)
输出参数：
算法说明：
*/
bool    egRefreshEV(AccountInfo   &myAI,    //账户信息
                    SymbolInfo    &mySI,     //商品信息
                    string mySymbol =NULL
                   )
{       
        myAI.login=AccountInfoInteger(ACCOUNT_LOGIN);
        myAI.trade_mode=(int)AccountInfoInteger(ACCOUNT_TRADE_MODE);
        myAI.leverage=AccountInfoInteger(ACCOUNT_LEVERAGE);
        myAI.limit_orders=AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
        myAI.margin_so_mode=(int)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
        myAI.trade_allowed=AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
        myAI.trade_expert=AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
        
        myAI.balance=AccountInfoDouble(ACCOUNT_BALANCE);
        myAI.credit=AccountInfoDouble(ACCOUNT_CREDIT);
        myAI.profit=AccountInfoDouble(ACCOUNT_PROFIT);
        myAI.equity=AccountInfoDouble(ACCOUNT_EQUITY);
        myAI.margin=AccountInfoDouble(ACCOUNT_MARGIN);
        myAI.margin_free=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
        myAI.margin_level=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
        myAI.margin_so_call=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
        myAI.margin_so_so=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
        
        myAI.name=AccountInfoString(ACCOUNT_NAME);
        myAI.server=AccountInfoString(ACCOUNT_SERVER);
        myAI.currency=AccountInfoString(ACCOUNT_CURRENCY);
        myAI.company=AccountInfoString(ACCOUNT_COMPANY);
        myAI.symbols_total=SymbolsTotal(false);
        egTradingSymbols(myAI.trade_symbols);
        
        //if(mySymbol ==NULL)   {mySymbol =Symbol();}
        mySI.symbol =mySymbol;   
        mySI.select=SymbolInfoInteger(mySymbol,SYMBOL_SELECT);
        mySI.time=(datetime)SymbolInfoInteger(mySymbol,SYMBOL_TIME);
        mySI.digits=(int)SymbolInfoInteger(mySymbol,SYMBOL_DIGITS);
        mySI.spread_float=SymbolInfoInteger(mySymbol,SYMBOL_SPREAD_FLOAT);
        mySI.spread=(int)SymbolInfoInteger(mySymbol,SYMBOL_SPREAD);
        mySI.trade_calc_mode=(int)SymbolInfoInteger(mySymbol,SYMBOL_TRADE_CALC_MODE);
        mySI.trade_mode=(int)SymbolInfoInteger(mySymbol,SYMBOL_TRADE_MODE);
        mySI.start_time=(datetime)SymbolInfoInteger(mySymbol,SYMBOL_START_TIME);
        mySI.expiration_time=(datetime)SymbolInfoInteger(mySymbol,SYMBOL_EXPIRATION_TIME);
        mySI.trade_stop_level=(int)SymbolInfoInteger(mySymbol,SYMBOL_TRADE_STOPS_LEVEL);
        mySI.trade_freeze_level=SymbolInfoInteger(mySymbol,SYMBOL_TRADE_FREEZE_LEVEL);
        mySI.trade_exemode=(int)SymbolInfoInteger(mySymbol,SYMBOL_TRADE_EXEMODE);
        mySI.swap_mode=SymbolInfoInteger(mySymbol,SYMBOL_SWAP_MODE);
        mySI.swap_rollover3days=SymbolInfoInteger(mySymbol,SYMBOL_SWAP_ROLLOVER3DAYS);

        mySI.bid=SymbolInfoDouble(mySymbol,SYMBOL_BID);
        mySI.ask=SymbolInfoDouble(mySymbol,SYMBOL_ASK);
        mySI.mid_price=(SymbolInfoDouble(mySymbol,SYMBOL_BID)+SymbolInfoDouble(mySymbol,SYMBOL_ASK))/2.0;
        mySI.point=SymbolInfoDouble(mySymbol,SYMBOL_POINT);
        mySI.trade_tick_value=SymbolInfoDouble(mySymbol,SYMBOL_TRADE_TICK_VALUE);
        mySI.trade_tick_size=SymbolInfoDouble(mySymbol,SYMBOL_TRADE_TICK_SIZE);
        mySI.trade_contract_size=SymbolInfoDouble(mySymbol,SYMBOL_TRADE_CONTRACT_SIZE);
        mySI.volume_min=SymbolInfoDouble(mySymbol,SYMBOL_VOLUME_MIN);
        mySI.volume_max=SymbolInfoDouble(mySymbol,SYMBOL_VOLUME_MAX);
        mySI.volum_step=SymbolInfoDouble(mySymbol,SYMBOL_VOLUME_STEP);
        mySI.swap_long=SymbolInfoDouble(mySymbol,SYMBOL_SWAP_LONG);
        mySI.swap_short=SymbolInfoDouble(mySymbol,SYMBOL_SWAP_SHORT);
        mySI.margin_initial=SymbolInfoDouble(mySymbol,SYMBOL_MARGIN_INITIAL);
        mySI.margin_maintenance=SymbolInfoDouble(mySymbol,SYMBOL_MARGIN_MAINTENANCE);
        
        mySI.currency_base=SymbolInfoString(mySymbol,SYMBOL_CURRENCY_BASE);
        mySI.currency_profit=SymbolInfoString(mySymbol,SYMBOL_CURRENCY_PROFIT);
        mySI.currency_margin=SymbolInfoString(mySymbol,SYMBOL_CURRENCY_MARGIN);
        mySI.descript=SymbolInfoString(mySymbol,SYMBOL_DESCRIPTION);
        mySI.path=SymbolInfoString(mySymbol,SYMBOL_PATH);
        
        mySI.margin_hedged=MarketInfo(mySymbol,MODE_MARGINHEDGED);
        mySI.margin_required=MarketInfo(mySymbol,MODE_MARGINREQUIRED);
        
        return(true);
}


/*
函    数:持仓商品
输出参数:商品名称数组
算    法:
*/
void egTradingSymbols(string   &mySymbol[]) //商品名称数组
{
    int myNum=0; //持仓商品数量
//--- 有持仓单，统计商品数量
    if (OrdersTotal()>0)
    {
        int i=0,j=0,k; //循环计数器变量
        ArrayResize(mySymbol,1);mySymbol[0]=""; //初始化商品名称数组
        ArrayResize(mySymbol,OrdersTotal()); //重定义商品名称数组尺寸
        string mySymbol_temp[];ArrayResize(mySymbol_temp,OrdersTotal()); //重定义商品名称临时数组尺寸
        //构建商品名称临时数组
        for (i=0;i<OrdersTotal();i++)
        {
            if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            {
                mySymbol_temp[i]=OrderSymbol();
            }
        }
        //去重商品名称数组
        for (i=0;i<OrdersTotal();i++) //按顺序在临时数组取商品名称
        {
            k=0;
            for (j=0;j<OrdersTotal();j++) //累计该商品在临时数组中数量
            {
                if (mySymbol_temp[i]==mySymbol[j]) k++;
                //mySymbol[myNum]=mySymbol_temp[i];
            }
            if (k==0)
            {
                mySymbol[myNum]=mySymbol_temp[i];
                myNum++;
            }
        }
        ArrayResize(mySymbol,myNum); //重定义商品名称数组尺寸
    }
    return;
}


/*
函    数：按要求刷新、填充持仓单数组
输出参数：持仓单数量 
算法说明：
*/
int egRefreshTO(TradesOrders    &myTO[],    //持仓单数组
                string          mySymbol="*",   //指定商品，"*"表示所有持仓单
                int             myMagicNum=-1,  //程序识别码, -1表示所有持仓单
                int             Mtype=-1,//交易类型
                string          Mcomm="*"//*  注释为空
               )
{
    int i=0,j=0,k=0; //循环计数器变量
    //重新界定订单数组
    ArrayResize(myTO,OrdersTotal()); 
    //刷新原始数组
    for (i=0;i<OrdersTotal();i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))  
        {
            if(mySymbol==OrderSymbol() || mySymbol=="*" )  //所有商品
            {
               if(myMagicNum==OrderMagicNumber() || myMagicNum==-1) //所有订单
               {
                  if(OrderType()==Mtype  || Mtype==-1)  //所有的类型
                  {
                     if(StringFind(OrderComment(),Mcomm,0)!=-1 || Mcomm=="*")  //注释为空
                     {
                        if(OrderCloseTime() >0) continue;
                        myTO[j].ticket=NULL;
                        myTO[j].opentime=NULL;
                        myTO[j].type=NULL;
                        myTO[j].lots=NULL;
                        myTO[j].symbol=NULL;
                        myTO[j].openprice=NULL;
                        myTO[j].stoploss=NULL;
                        myTO[j].takeprofit=NULL;
                        myTO[j].commission=NULL;
                        myTO[j].swap=NULL;
                        myTO[j].profit=NULL;
                        myTO[j].comment=NULL;
                        myTO[j].magicnumber=NULL;
                        
                        myTO[j].ticket=OrderTicket();                                       //订单号
                        myTO[j].opentime=OrderOpenTime();                                   //开仓时间
                        myTO[j].type=OrderType();                                           //订单类型
                        myTO[j].lots=OrderLots();                                           //开仓量
                        myTO[j].symbol=OrderSymbol();                                       //商品名称
                        //myTO[j].openprice=NormalizeDouble(OrderOpenPrice(),MarketInfo(mySymbol,MODE_DIGITS)); 
                        myTO[j].openprice=OrderOpenPrice();
                        //Alert("kaicangjia: "+myTO[j].openprice);        //建仓价
                        //myTO[j].stoploss=NormalizeDouble(OrderStopLoss(),MarketInfo(mySymbol,MODE_DIGITS));
                        myTO[j].stoploss=OrderStopLoss();           //止损价
                        ///myTO[j].takeprofit=NormalizeDouble(OrderTakeProfit(),MarketInfo(mySymbol,MODE_DIGITS));
                        myTO[j].takeprofit=OrderTakeProfit();       //止盈价
                        myTO[j].commission=OrderCommission();                               //佣金
                        myTO[j].swap=OrderSwap();                                           //利息
                        myTO[j].profit=OrderProfit();                                       //利润
                        myTO[j].comment=OrderComment();                                     //注释
                        myTO[j].magicnumber=OrderMagicNumber();                             //程序识别码
                        
                        //在历史记录中查找掉期记录并累计，订单注释栏有from*****字样，*****为扣除掉期的订单号，订单类型为6。
                        for (k=0;k<OrdersHistoryTotal();k++)
                        {
                            if (   OrderSelect(k,SELECT_BY_POS,MODE_HISTORY) //选择历史单
                                && myTO[j].type==6
                                && StringFind(OrderComment(),(string)myTO[j].ticket,0)>=0 //有扣除掉期记录
                               )
                            {
                                myTO[j].swap+=OrderSwap(); //累计掉期
                            }
                        }
                        j++;
                     }
                  }
               }
            }
         }
      }//for
            
       if (j>0) 
       {
           ArrayResize(myTO,j); //重新界定数组边界
       }
       else //没有持仓单，所有项目NULL
       {
           ArrayResize(myTO,1);
           myTO[j].ticket=NULL;
           myTO[j].symbol=NULL;
           myTO[j].type=NULL;
           myTO[j].lots=NULL;
           myTO[j].opentime=NULL;
           myTO[j].openprice=NULL;
           myTO[j].stoploss=NULL;
           myTO[j].takeprofit=NULL;
           myTO[j].profit=NULL;
           myTO[j].commission=NULL;
           myTO[j].swap=NULL;
           myTO[j].comment=NULL;
           myTO[j].magicnumber=NULL;
           myTO[j].flag=NULL;
       }
       return(j);
}


/*
函    数:刷新持仓单统计信息
输出参数:false-未统计，true-已统计
算    法:统计myTO数组，给myTS赋值。其中最大盈利、最大亏损、最大保证金占用不重新计算
*/
bool egRefreshTS(TradesOrders       &myTO[],    //持仓单数组
                 TradesStatistical  &myTS,      //统计结果
                 AccountInfo        &myAI,      //账户信息
                 //SymbolInfo         &mySI,       //商品信息
                 string             mySymbol="*",
                 string             myComments=NULL
                )
{
    double  myBuyValue =0,mySellValue =0;
//--- 初始化myTS,其中最大盈利、最大亏损、最大保证金占用不重新计算
    myTS.symbol=mySymbol;
    myTS.buy_orders=NULL;
    myTS.buylimit_orders=NULL;
    myTS.buystop_orders=NULL;
    myTS.buy_grp_lots=NULL;
    myTS.buy_grp_profit=NULL;
    myTS.buy_grp_avg=NULL;
    myTS.buy_grp_margin=NULL;
    myTS.sell_orders=NULL;
    myTS.selllimit_orders=NULL;
    myTS.sellstop_orders=NULL;
    myTS.sell_grp_lots=NULL;
    myTS.sell_grp_profit=NULL;
    myTS.sell_grp_avg=NULL;
    myTS.sell_grp_margin=NULL;
    myTS.all_profit=NULL;
    myTS.all_holding_orders=NULL;
    myTS.all_stoplimit_orders=NULL;
    myTS.max_floating_profit =NULL;
    myTS.profit_orderType =NULL;
    
    if (ArraySize(myTO)==0) return(false); //订单数组为空，不计算
//--- 统计分组信息
    for (int cont=0;cont<ArraySize(myTO);cont++)
    {
        if (myTO[cont].ticket>0 && myTO[cont].type==OP_BUY)
        {
            myTS.buy_orders++;  //Buy单数量总计
            myTS.buy_grp_lots=myTS.buy_grp_lots+myTO[cont].lots; //Buy组成交持仓单建仓量总计
            myTS.buy_grp_profit=myTS.buy_grp_profit+myTO[cont].profit+myTO[cont].swap+myTO[cont].commission;   //Buy组成交持仓单利润总计
            myBuyValue =myBuyValue+myTO[cont].openprice*myTO[cont].lots;   //Buy组总价值
        }
        if (myTO[cont].ticket>0 && myTO[cont].type==OP_BUYLIMIT)
        {
            myTS.buylimit_orders++;  //BuyLimit单数量总计
        }
        if (myTO[cont].ticket>0 && myTO[cont].type==OP_BUYSTOP)
        {
            myTS.buystop_orders++;  //BuyStop单数量总计
        }
        
        if (myTO[cont].ticket>0 && myTO[cont].type==OP_SELL)
        {
            myTS.sell_orders++;  //Sell单数量总计
            myTS.sell_grp_lots = myTS.sell_grp_lots+myTO[cont].lots; //Sell组成交持仓单建仓量总计
            myTS.sell_grp_profit = myTS.sell_grp_profit + myTO[cont].profit + myTO[cont].swap + myTO[cont].commission;   //Sell组成交持仓单利润总计
            mySellValue = mySellValue + myTO[cont].openprice * myTO[cont].lots;   //Sell组总价值
        }
        if (myTO[cont].ticket>0 && myTO[cont].type==OP_SELLLIMIT)
        {
            myTS.selllimit_orders++;  //SellLimit单数量总计
        }
        if (myTO[cont].ticket>0 && myTO[cont].type==OP_SELLSTOP)
        {
            myTS.sellstop_orders++;  //SellStop单数量总计
        }
    }
//--- 统计汇总信息
    //持仓单总数
    myTS.all_holding_orders = myTS.buy_orders + myTS.sell_orders;
    //挂单总数
    myTS.all_stoplimit_orders = myTS.buystop_orders +myTS.sellstop_orders +myTS.buylimit_orders +myTS.selllimit_orders;
    //订单总数
    myTS.all_orders = myTS.all_holding_orders + myTS.all_stoplimit_orders;
    //当前浮动盈亏
    myTS.all_profit = myTS.buy_grp_profit + myTS.sell_grp_profit;
    //净值风险值
    if (myAI.equity>0)
    {
        myTS.buy_grp_risk=myTS.buy_grp_profit/myAI.equity;
        myTS.sell_grp_risk=myTS.sell_grp_profit/myAI.equity;
    }
    //余额风险值
    if (myAI.balance>0)
    {
        myTS.buy_grp_ACrisk  = myTS.buy_grp_profit/myAI.balance;
        myTS.sell_grp_ACrisk = myTS.sell_grp_profit/myAI.balance;
    }
    //组均价 最低价 最高价 及对应单号
    if (myTS.buy_orders >0) {
      myTS.buy_grp_avg = myBuyValue / myTS.buy_grp_lots;
      int i1 = egOrderPos(myTO,egOrderLocationSearch(myTO,mySymbol,1,0,-1,-1));
      myTS.buy_grp_minPrice = myTO[i1].openprice;
      myTS.buy_grp_minPriceTicket = myTO[i1].ticket;
    }
    if (myTS.sell_orders >0) {
      myTS.sell_grp_avg = mySellValue / myTS.sell_grp_lots; 
      int i2 = egOrderPos(myTO,egOrderLocationSearch(myTO,mySymbol,1,1,-1,1));  
      myTS.sell_grp_maxPrice = myTO[i2].openprice;
      myTS.sell_grp_maxPriceTicket = myTO[i2].ticket;

    }
    
    //保证金占用
    if(mySymbol =="*")  myTS.symbol =NULL;
    myTS.buy_grp_margin=myTS.buy_grp_lots * MarketInfo(myTS.symbol,MODE_MARGINREQUIRED);;
    myTS.sell_grp_margin=myTS.sell_grp_lots * MarketInfo(myTS.symbol,MODE_MARGINREQUIRED);;
    //余额增量  本轮净利
    int i=0;    //循环计数器变量
    datetime    myBaseTime =0; //基准时间变量
    //有持仓单，开始计算
    myTS.account_increment=0;
    myTS.current_profit=0;
    if (myTS.buy_orders+myTS.sell_orders>0)
    {
        //获取最早持仓单建仓时间
        if (egOrderLocationSearch(myTO,mySymbol,0,9,-1,-1)<=0) myTS.account_increment=0;
        if (egOrderLocationSearch(myTO,mySymbol,0,9,-1,-1)>0) myBaseTime =myTO[egOrderPos(myTO,egOrderLocationSearch(myTO,mySymbol,0,9,-1,-1))].opentime;
        
        //查找历史订单中本轮交易最早单建仓时间
        for (i=0;i<OrdersHistoryTotal();i++)
        {
            if (   OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
                && OrderSymbol()==mySymbol
                && (OrderType()==OP_BUY || OrderType()==OP_SELL)
                && OrderOpenTime()<myBaseTime && OrderCloseTime()>myBaseTime
               )
            {
                myBaseTime=OrderOpenTime();
            }
        }
        //统计从本轮开始历史单实现的余额增量,本轮净利
        for (i=0;i<OrdersHistoryTotal();i++)
        {
            if (   OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
                && (OrderType()==OP_BUY || OrderType()==OP_SELL)
                && OrderCloseTime()>myBaseTime
               )
            {
                myTS.account_increment=myTS.account_increment+OrderProfit()+OrderCommission()+OrderSwap();
                if (OrderSymbol()==mySymbol)
                {
                    myTS.current_profit=myTS.current_profit+OrderProfit()+OrderCommission()+OrderSwap();
                }
            }
        }
        
    }
    /*
    //计算当前持仓的最大浮动盈利
    if (myTS.buy_orders+myTS.sell_orders>0)
    {        
        string maxPft =ObjectGetString(0,"lb_pft-"+mySymbol+"-"+myComments,OBJPROP_TEXT);
        double maxPftDb =StrToDouble(maxPft);
                
        if(myTS.all_profit >0 && myTS.all_profit > maxPftDb)   {
           myTS.max_floating_profit = NormalizeDouble(myTS.all_profit,2);
           maxPftDb = myTS.all_profit;
           bool bRes = egLableOut(1,DoubleToStr(maxPftDb,2),"lb_pft-"+mySymbol+"-"+myComments,10,255);           
        }
        else {myTS.max_floating_profit =maxPftDb;}
    }
    */    
    return(true);
}


/*
函    数：持仓单定位搜索
输出参数：订单号，-1表示无订单
算法说明：冒泡
针对指定的订单数组执行按组合条件定位搜索。
*/
int egOrderLocationSearch(TradesOrders   &myTO[],        //持仓单数组
                          string         mySymbol,       //商品名称，Symbol()为当前图表商品名，"*"为所有商品
                          int            mySeekMode,     //排序类型 0-按建仓时间,1-按建仓价,2-按盈利,3-按亏损
                          int            myOrderType,    //订单类型 0-Buy,1-Sell,2-BuyLimit,3-SellLimit,4-BuyStop,5-SellStop,9-所有
                          int            myMagicNum,     //程序识别码，-1-所有订单
                          int            mySerialNumber  //排序1为最大，2为次大，以此类推，-1为最小，-2为次小，以此类推
                         )
{
    int cont=0,i=0;  //循环计数器变量
    //没有持仓单，不执行
    if (OrdersTotal()<=0) return(-1); 
    egOrdersArraySort(myTO,mySymbol,mySeekMode);
    switch (mySeekMode)
    {
        case 0: //持仓单数组的建仓时间按降序排列
        {
            //按3、4、5条件筛选
            if (mySerialNumber>0) //从大到小
            {
                i=1;
                for (cont=0;cont<ArraySize(myTO);cont++)
                {
                    if (   (mySymbol=="*" || mySymbol==myTO[cont].symbol) //商品名称
                        && (myOrderType==9 || myOrderType==myTO[cont].type) //订单类型
                        && (myMagicNum==-1 || myMagicNum==myTO[cont].magicnumber) //程序识别码
                       )
                    {
                        if (mySerialNumber==i) return(myTO[cont].ticket); //符合顺序的订单
                        i++; 
                    }
                }
            }
            if (mySerialNumber<0) //从小到大
            {
                i=-1;
                for (cont=ArraySize(myTO)-1;cont>=0;cont--)
                {
                    if (   (mySymbol=="*" || mySymbol==myTO[cont].symbol) //商品名称
                        && (myOrderType==9 || myOrderType==myTO[cont].type) //订单类型
                        && (myMagicNum==-1 || myMagicNum==myTO[cont].magicnumber) //程序识别码
                       )
                    {
                        if (mySerialNumber==i) return(myTO[cont].ticket); //符合顺序的订单
                        i--; 
                    }
                }
            }
            break;
        }
        case 1: //持仓单数组的建价按降序排列
        {
            //按3、4、5条件筛选
            if (mySerialNumber>0) //从大到小
            {
                i=1;
                for (cont=0;cont<ArraySize(myTO);cont++)
                {
                    if (   (mySymbol=="*" || mySymbol==myTO[cont].symbol) //商品名称
                        && (myOrderType==9 || myOrderType==myTO[cont].type) //订单类型
                        && (myMagicNum==-1 || myMagicNum==myTO[cont].magicnumber) //程序识别码
                       )
                    {
                        if (mySerialNumber==i) return(myTO[cont].ticket); //符合顺序的订单
                        i++; 
                    }
                }
            }
            if (mySerialNumber<0) //从小到大
            {
                i=-1;
                for (cont=ArraySize(myTO)-1;cont>=0;cont--)
                {
                    if (   (mySymbol=="*" || mySymbol==myTO[cont].symbol) //商品名称
                        && (myOrderType==9 || myOrderType==myTO[cont].type) //订单类型
                        && (myMagicNum==-1 || myMagicNum==myTO[cont].magicnumber) //程序识别码
                       )
                    {
                        if (mySerialNumber==i) return(myTO[cont].ticket); //符合顺序的订单
                        i--; 
                    }
                }
            }
            break;
        }
        case 2: //持仓单数组的利润按降序排列  浮动盈利
        {
            //按3、4、5条件筛选
            if (mySerialNumber>0) //从大到小
            {
                i=1;
                for (cont=0;cont<ArraySize(myTO);cont++)
                {
                    if (   (mySymbol=="*" || mySymbol==myTO[cont].symbol) //商品名称
                        && (myOrderType==9 || myOrderType==myTO[cont].type) //订单类型
                        && (myMagicNum==-1 || myMagicNum==myTO[cont].magicnumber) //程序识别码
                        && myTO[cont].profit>0 //浮盈
                       )
                    {
                        if (mySerialNumber==i) return(myTO[cont].ticket); //符合顺序的订单
                        i++; 
                    }
                }
            }
            if (mySerialNumber<0) //从小到大
            {
                i=-1;
                for (cont=ArraySize(myTO)-1;cont>=0;cont--)
                {
                    if (   (mySymbol=="*" || mySymbol==myTO[cont].symbol) //商品名称
                        && (myOrderType==9 || myOrderType==myTO[cont].type) //订单类型
                        && (myMagicNum==-1 || myMagicNum==myTO[cont].magicnumber) //程序识别码
                        && myTO[cont].profit>0 //浮盈
                       )
                    {
                        if (mySerialNumber==i) return(myTO[cont].ticket); //符合顺序的订单
                        i--; 
                    }
                }
            }
            break;
        }
        case 3: //持仓单数组的利润按降序排列  浮动亏损
        {
            //按3、4、5条件筛选
            if (mySerialNumber>0) //从大到小
            {
                i=1;
                for (cont=ArraySize(myTO)-1;cont>=0;cont--)
                {
                    if (   (mySymbol=="*" || mySymbol==myTO[cont].symbol) //商品名称
                        && (myOrderType==9 || myOrderType==myTO[cont].type) //订单类型
                        && (myMagicNum==-1 || myMagicNum==myTO[cont].magicnumber) //程序识别码
                        && myTO[cont].profit<0 //浮亏
                       )
                    {
                        if (mySerialNumber==i) return(myTO[cont].ticket); //符合顺序的订单
                        i++; 
                    }
                }
            }
            if (mySerialNumber<0) //从小到大
            {
                i=-1;
                for (cont=0;cont<ArraySize(myTO);cont++)
                {
                    if (   (mySymbol=="*" || mySymbol==myTO[cont].symbol) //商品名称
                        && (myOrderType==9 || myOrderType==myTO[cont].type) //订单类型
                        && (myMagicNum==-1 || myMagicNum==myTO[cont].magicnumber) //程序识别码
                        && myTO[cont].profit<0 //浮亏
                       )
                    {
                        if (mySerialNumber==i) return(myTO[cont].ticket); //符合顺序的订单
                        i--; 
                    }
                }
            }
            break;
        }
    }
    return(-1);
}


/*
函    数：持仓单定位
输出参数：持仓单在myTO数组中的位置,-1表示找不到订单
算法说明：
*/
int egOrderPos(TradesOrders     &myTO[],    //持仓单数组
               int              myTicket    //订单号
              )
{
    if (myTicket<=0 || ArraySize(myTO)==0) return(-1);
    for (int cont=0;cont<ArraySize(myTO);cont++)
    {
        if (myTO[cont].ticket==myTicket) return(cont);
    }
    return(-1);
}


/*
函    数：持仓单单数组按类型排序
输出参数：
算法说明：冒泡
针对指定的订单数组执行按组合条件降序排序。
*/
void egOrdersArraySort(TradesOrders     &myTO[],    //持仓单数组
                       string           mySymbol,   //商品名称，Symbol()为当前图表商品名，"*"为所有商品
                       int              mySeekMode  //排序类型 0-按建仓时间,1-按建仓价,2、3-按利润
                     )
{
    int myArrayRange=ArraySize(myTO);   //数组边界变量
    int i,j;                            //循环计数器变量
    TradesOrders mySwapArray[1];        //交换数组变量
    switch (mySeekMode)
    {
        case 0: //按建仓时间，结果是降序
        {
            for (i=0;i<myArrayRange;i++)
            {
                for (j=myArrayRange-1;j>i;j--)
                {
                    if (myTO[j].opentime>myTO[j-1].opentime)
                    {
                        mySwapArray[0].ticket     =myTO[j-1].ticket;
                        mySwapArray[0].opentime   =myTO[j-1].opentime;
                        mySwapArray[0].type       =myTO[j-1].type;
                        mySwapArray[0].lots       =myTO[j-1].lots;
                        mySwapArray[0].symbol     =myTO[j-1].symbol;
                        mySwapArray[0].openprice  =myTO[j-1].openprice;
                        mySwapArray[0].stoploss   =myTO[j-1].stoploss;
                        mySwapArray[0].takeprofit =myTO[j-1].takeprofit;
                        mySwapArray[0].commission =myTO[j-1].commission;
                        mySwapArray[0].swap       =myTO[j-1].swap;
                        mySwapArray[0].profit     =myTO[j-1].profit;
                        mySwapArray[0].comment    =myTO[j-1].comment;
                        mySwapArray[0].magicnumber=myTO[j-1].magicnumber;
                        
                        myTO[j-1].ticket     =myTO[j].ticket;
                        myTO[j-1].opentime   =myTO[j].opentime;
                        myTO[j-1].type       =myTO[j].type;
                        myTO[j-1].lots       =myTO[j].lots;
                        myTO[j-1].symbol     =myTO[j].symbol;
                        myTO[j-1].openprice  =myTO[j].openprice;
                        myTO[j-1].stoploss   =myTO[j].stoploss;
                        myTO[j-1].takeprofit =myTO[j].takeprofit;
                        myTO[j-1].commission =myTO[j].commission;
                        myTO[j-1].swap       =myTO[j].swap;
                        myTO[j-1].profit     =myTO[j].profit;
                        myTO[j-1].comment    =myTO[j].comment;
                        myTO[j-1].magicnumber=myTO[j].magicnumber;
                        
                        myTO[j].ticket     =mySwapArray[0].ticket;
                        myTO[j].opentime   =mySwapArray[0].opentime;
                        myTO[j].type       =mySwapArray[0].type;
                        myTO[j].lots       =mySwapArray[0].lots;
                        myTO[j].symbol     =mySwapArray[0].symbol;
                        myTO[j].openprice  =mySwapArray[0].openprice;
                        myTO[j].stoploss   =mySwapArray[0].stoploss;
                        myTO[j].takeprofit =mySwapArray[0].takeprofit;
                        myTO[j].commission =mySwapArray[0].commission;
                        myTO[j].swap       =mySwapArray[0].swap;
                        myTO[j].profit     =mySwapArray[0].profit;
                        myTO[j].comment    =mySwapArray[0].comment;
                        myTO[j].magicnumber=mySwapArray[0].magicnumber;
                    }
                }
            }
            break;
        }
        case 1: //按建仓价，结果是降序
        {
            for (i=0;i<myArrayRange;i++)
            {
                for (j=myArrayRange-1;j>i;j--)
                {
                    if (myTO[j].openprice>myTO[j-1].openprice)
                    {
                        mySwapArray[0].ticket     =myTO[j-1].ticket;
                        mySwapArray[0].opentime   =myTO[j-1].opentime;
                        mySwapArray[0].type       =myTO[j-1].type;
                        mySwapArray[0].lots       =myTO[j-1].lots;
                        mySwapArray[0].symbol     =myTO[j-1].symbol;
                        mySwapArray[0].openprice  =myTO[j-1].openprice;
                        mySwapArray[0].stoploss   =myTO[j-1].stoploss;
                        mySwapArray[0].takeprofit =myTO[j-1].takeprofit;
                        mySwapArray[0].commission =myTO[j-1].commission;
                        mySwapArray[0].swap       =myTO[j-1].swap;
                        mySwapArray[0].profit     =myTO[j-1].profit;
                        mySwapArray[0].comment    =myTO[j-1].comment;
                        mySwapArray[0].magicnumber=myTO[j-1].magicnumber;
                        
                        myTO[j-1].ticket     =myTO[j].ticket;
                        myTO[j-1].opentime   =myTO[j].opentime;
                        myTO[j-1].type       =myTO[j].type;
                        myTO[j-1].lots       =myTO[j].lots;
                        myTO[j-1].symbol     =myTO[j].symbol;
                        myTO[j-1].openprice  =myTO[j].openprice;
                        myTO[j-1].stoploss   =myTO[j].stoploss;
                        myTO[j-1].takeprofit =myTO[j].takeprofit;
                        myTO[j-1].commission =myTO[j].commission;
                        myTO[j-1].swap       =myTO[j].swap;
                        myTO[j-1].profit     =myTO[j].profit;
                        myTO[j-1].comment    =myTO[j].comment;
                        myTO[j-1].magicnumber=myTO[j].magicnumber;
                        
                        myTO[j].ticket     =mySwapArray[0].ticket;
                        myTO[j].opentime   =mySwapArray[0].opentime;
                        myTO[j].type       =mySwapArray[0].type;
                        myTO[j].lots       =mySwapArray[0].lots;
                        myTO[j].symbol     =mySwapArray[0].symbol;
                        myTO[j].openprice  =mySwapArray[0].openprice;
                        myTO[j].stoploss   =mySwapArray[0].stoploss;
                        myTO[j].takeprofit =mySwapArray[0].takeprofit;
                        myTO[j].commission =mySwapArray[0].commission;
                        myTO[j].swap       =mySwapArray[0].swap;
                        myTO[j].profit     =mySwapArray[0].profit;
                        myTO[j].comment    =mySwapArray[0].comment;
                        myTO[j].magicnumber=mySwapArray[0].magicnumber;
                    }
                }
            }
            break;
        }
        case 2: //按浮动利润，结果是降序
        {
            for (i=0;i<myArrayRange;i++)
            {
                for (j=myArrayRange-1;j>i;j--)
                {
                    if (myTO[j].profit>myTO[j-1].profit)
                    {
                        mySwapArray[0].ticket     =myTO[j-1].ticket;
                        mySwapArray[0].opentime   =myTO[j-1].opentime;
                        mySwapArray[0].type       =myTO[j-1].type;
                        mySwapArray[0].lots       =myTO[j-1].lots;
                        mySwapArray[0].symbol     =myTO[j-1].symbol;
                        mySwapArray[0].openprice  =myTO[j-1].openprice;
                        mySwapArray[0].stoploss   =myTO[j-1].stoploss;
                        mySwapArray[0].takeprofit =myTO[j-1].takeprofit;
                        mySwapArray[0].commission =myTO[j-1].commission;
                        mySwapArray[0].swap       =myTO[j-1].swap;
                        mySwapArray[0].profit     =myTO[j-1].profit;
                        mySwapArray[0].comment    =myTO[j-1].comment;
                        mySwapArray[0].magicnumber=myTO[j-1].magicnumber;
                        
                        myTO[j-1].ticket     =myTO[j].ticket;
                        myTO[j-1].opentime   =myTO[j].opentime;
                        myTO[j-1].type       =myTO[j].type;
                        myTO[j-1].lots       =myTO[j].lots;
                        myTO[j-1].symbol     =myTO[j].symbol;
                        myTO[j-1].openprice  =myTO[j].openprice;
                        myTO[j-1].stoploss   =myTO[j].stoploss;
                        myTO[j-1].takeprofit =myTO[j].takeprofit;
                        myTO[j-1].commission =myTO[j].commission;
                        myTO[j-1].swap       =myTO[j].swap;
                        myTO[j-1].profit     =myTO[j].profit;
                        myTO[j-1].comment    =myTO[j].comment;
                        myTO[j-1].magicnumber=myTO[j].magicnumber;
                        
                        myTO[j].ticket     =mySwapArray[0].ticket;
                        myTO[j].opentime   =mySwapArray[0].opentime;
                        myTO[j].type       =mySwapArray[0].type;
                        myTO[j].lots       =mySwapArray[0].lots;
                        myTO[j].symbol     =mySwapArray[0].symbol;
                        myTO[j].openprice  =mySwapArray[0].openprice;
                        myTO[j].stoploss   =mySwapArray[0].stoploss;
                        myTO[j].takeprofit =mySwapArray[0].takeprofit;
                        myTO[j].commission =mySwapArray[0].commission;
                        myTO[j].swap       =mySwapArray[0].swap;
                        myTO[j].profit     =mySwapArray[0].profit;
                        myTO[j].comment    =mySwapArray[0].comment;
                        myTO[j].magicnumber=mySwapArray[0].magicnumber;
                    }
                }
            }
            break;
        }
        case 3: //按浮动利润，结果是降序
        {
            for (i=0;i<myArrayRange;i++)
            {
                for (j=myArrayRange-1;j>i;j--)
                {
                    if (myTO[j].profit>myTO[j-1].profit)
                    {
                        mySwapArray[0].ticket     =myTO[j-1].ticket;
                        mySwapArray[0].opentime   =myTO[j-1].opentime;
                        mySwapArray[0].type       =myTO[j-1].type;
                        mySwapArray[0].lots       =myTO[j-1].lots;
                        mySwapArray[0].symbol     =myTO[j-1].symbol;
                        mySwapArray[0].openprice  =myTO[j-1].openprice;
                        mySwapArray[0].stoploss   =myTO[j-1].stoploss;
                        mySwapArray[0].takeprofit =myTO[j-1].takeprofit;
                        mySwapArray[0].commission =myTO[j-1].commission;
                        mySwapArray[0].swap       =myTO[j-1].swap;
                        mySwapArray[0].profit     =myTO[j-1].profit;
                        mySwapArray[0].comment    =myTO[j-1].comment;
                        mySwapArray[0].magicnumber=myTO[j-1].magicnumber;
                        
                        myTO[j-1].ticket     =myTO[j].ticket;
                        myTO[j-1].opentime   =myTO[j].opentime;
                        myTO[j-1].type       =myTO[j].type;
                        myTO[j-1].lots       =myTO[j].lots;
                        myTO[j-1].symbol     =myTO[j].symbol;
                        myTO[j-1].openprice  =myTO[j].openprice;
                        myTO[j-1].stoploss   =myTO[j].stoploss;
                        myTO[j-1].takeprofit =myTO[j].takeprofit;
                        myTO[j-1].commission =myTO[j].commission;
                        myTO[j-1].swap       =myTO[j].swap;
                        myTO[j-1].profit     =myTO[j].profit;
                        myTO[j-1].comment    =myTO[j].comment;
                        myTO[j-1].magicnumber=myTO[j].magicnumber;
                        
                        myTO[j].ticket     =mySwapArray[0].ticket;
                        myTO[j].opentime   =mySwapArray[0].opentime;
                        myTO[j].type       =mySwapArray[0].type;
                        myTO[j].lots       =mySwapArray[0].lots;
                        myTO[j].symbol     =mySwapArray[0].symbol;
                        myTO[j].openprice  =mySwapArray[0].openprice;
                        myTO[j].stoploss   =mySwapArray[0].stoploss;
                        myTO[j].takeprofit =mySwapArray[0].takeprofit;
                        myTO[j].commission =mySwapArray[0].commission;
                        myTO[j].swap       =mySwapArray[0].swap;
                        myTO[j].profit     =mySwapArray[0].profit;
                        myTO[j].comment    =mySwapArray[0].comment;
                        myTO[j].magicnumber=mySwapArray[0].magicnumber;
                    }
                }
            }
            break;
        }
    } 
    return;
}

/*
函    数:指定开仓量、利润转点数
输出参数:点数
算    法:
*/
int egLotsProfitToPoint(string    mySymbol,        //货币对名称
                        double    mySpecifyLots,   //指定开仓量
                        double    mySpecifyProfit  //指定利润
                       )
{
    //点数=指定利润/(指定建仓量*单点价值)
    if (mySpecifyLots!=0 && MarketInfo(mySymbol,MODE_TICKVALUE)!=0) return((int)(mySpecifyProfit/(mySpecifyLots*MarketInfo(mySymbol,MODE_TICKVALUE))));
    return(0);
}


/*
函    数:建仓、加仓
输出参数:单号
算    法:建仓、加仓
BuyLimit挂单价<=Ask-StopLevel      BuyStop挂单价>=Ask+StopLevel 
SellLimit挂单价>=Bid+StopLevel	    SellStop挂单价<=Bid-StopLevel
*/
long ttOrderCreat(CreatOrdersInfo &myCOI)
{
//建仓量不合规 不执行
    if (myCOI.lots<=0) return(-1);
    long ticket =0;
//正常建仓
    myCOI.lots=egLotsFormat(myCOI.symbol,myCOI.lots);
    if (   myCOI.type==OP_BUY) {
      ticket =OrderSend(myCOI.symbol,OP_BUY,myCOI.lots,MarketInfo(myCOI.symbol,MODE_ASK),0,myCOI.slPrice,myCOI.tpPrice,myCOI.comment,myCOI.magicnumber,0);
      return(ticket);
    }
    if (   myCOI.type==OP_BUYLIMIT
        && myCOI.openprice <= MarketInfo(myCOI.symbol,MODE_ASK) -MarketInfo(myCOI.symbol,MODE_STOPLEVEL) * MarketInfo(myCOI.symbol,MODE_POINT)
       )
    {
        ticket =OrderSend(myCOI.symbol,OP_BUYLIMIT,myCOI.lots,myCOI.openprice,0,myCOI.slPrice,myCOI.tpPrice,myCOI.comment,myCOI.magicnumber,0);
        return(ticket);
    }
    if (   myCOI.type==OP_BUYSTOP
        && myCOI.openprice >= MarketInfo(myCOI.symbol,MODE_ASK) +MarketInfo(myCOI.symbol,MODE_STOPLEVEL) * MarketInfo(myCOI.symbol,MODE_POINT)
       )
    {
        ticket =OrderSend(myCOI.symbol,OP_BUYSTOP,myCOI.lots,myCOI.openprice,0,myCOI.slPrice,myCOI.tpPrice,myCOI.comment,myCOI.magicnumber,0);
        return(ticket);
    }
    if ( myCOI.type==OP_SELL)
    {   
        ticket =OrderSend(myCOI.symbol,OP_SELL,myCOI.lots,MarketInfo(myCOI.symbol,MODE_BID),0,myCOI.slPrice,myCOI.tpPrice,myCOI.comment,myCOI.magicnumber,0);
        return(ticket);
    }
    if (   myCOI.type==OP_SELLLIMIT
        && myCOI.openprice >= MarketInfo(myCOI.symbol,MODE_BID) +MarketInfo(myCOI.symbol,MODE_STOPLEVEL) *MarketInfo(myCOI.symbol,MODE_POINT)
       )
    {
        ticket =OrderSend(myCOI.symbol,OP_SELLLIMIT,myCOI.lots,myCOI.openprice,0,myCOI.slPrice,myCOI.tpPrice,myCOI.comment,myCOI.magicnumber,0);
        return(ticket);
    }
    if (   myCOI.type==OP_SELLSTOP
        && myCOI.openprice <= MarketInfo(myCOI.symbol,MODE_BID) -MarketInfo(myCOI.symbol,MODE_STOPLEVEL) *MarketInfo(myCOI.symbol,MODE_POINT)
       )
    {
        ticket =OrderSend(myCOI.symbol,OP_SELLSTOP,myCOI.lots,myCOI.openprice,0,myCOI.slPrice,myCOI.tpPrice,myCOI.comment,myCOI.magicnumber,0);
        return(ticket);
    }
    return(ticket);
}


/*
函    数:建仓量整形
输出参数:符合平台规定格式的开仓量。-1表示整形失败
算    法:调整不规范的开仓量数据，按照四舍五入原则及平台开仓量格式规范数据
*/
double egLotsFormat(string   mySymbol,   //货币对名称
                    double   myLots      //需要整形的开仓量
                   )
{
    if (MarketInfo(mySymbol, MODE_MINLOT)!=0) return(MathRound(myLots/MarketInfo(mySymbol,MODE_MINLOT))*MarketInfo(mySymbol,MODE_MINLOT));
    return(-1);
}

/*
函    数:由价距和盈亏金额计算所需手数
输出参数:
算    法:
*/
double 由价距和盈亏金额计算所需手数(string symbol_in, double profit_in, double priceDs_in)
{
   double myLots =0;
   double myTickValue  = 0;
   double myPoint =0;
   
   SymbolInfoDouble(symbol_in,SYMBOL_TRADE_TICK_VALUE,myTickValue);
   SymbolInfoDouble(symbol_in,SYMBOL_POINT,myPoint);

   if(myPoint >0)   {
      int pointDs = (int)(priceDs_in/myPoint);
      if(pointDs * myTickValue !=0)   {
         myLots = (profit_in/pointDs)/myTickValue;
         return(egLotsFormat(symbol_in,myLots));
      }
   }
   return(myLots);
}


/*
函    数:数组平仓
输出参数:false-平仓失败,true-平仓成功
算    法:
*/
bool egArrayClose(int    &myCloseArray[],   //平仓数组
                  const int myTradingDelay=500 //延时
                 )
{
    int cont=0,i=0;  //循环计数器变量
    
    for (cont=0;cont<ArraySize(myCloseArray);cont++)
    {
        if (myCloseArray[cont]>0 && OrderSelect(myCloseArray[cont],SELECT_BY_TICKET,MODE_TRADES))
        {
            
            egTradeDelay(myTradingDelay);
            //买入成交持仓单市价平仓
            if (OrderType()==OP_BUY && OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),0))
            {
                myCloseArray[cont]=-1;
                i++; //平仓单计数
            }
            //卖出成交持仓单市价平仓
            if (OrderType()==OP_SELL && OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),0))
            {
                myCloseArray[cont]=-1;
                i++; //平仓单计数
            }
            //撤销挂单
            if (   (OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP)
                && OrderDelete(OrderTicket())
               )
            {
                myCloseArray[cont]=-1;
                i++; //平仓单计数
            }
        }
    }
    if (i==0) //平仓失败
    {
        ArrayInitialize(myCloseArray,-1); //初始化平仓数组
        return(false);
    }
    return(true);
}
/*
函    数：刷新历史单数组
输出参数：历史单数量 
算法说明：
*/
int egRefreshHO(HistoryOrders   &myHO[],    //历史单数组
                string          mySymbol,   //指定商品，"*"表示所有持仓单
                int             myMagicNum  //程序识别码, -1表示所有持仓单
               )
{
    int i=0,j=0;                    //循环计数器变量
    //重新界定订单数组
    ArrayResize(myHO,OrdersHistoryTotal()); 
    //刷新原始数组
    for (i=0;i<OrdersHistoryTotal();i++)
    {
        if (   OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) //选中历史单
            && (   mySymbol==OrderSymbol() //指定商品
                || mySymbol=="*" //所有商品
               )
            && (   myMagicNum==OrderMagicNumber() //指定程序订单
                || myMagicNum==-1 //所有订单
               )
           )
        {
            myHO[j].ticket=NULL;
            myHO[j].symbol=NULL;
            myHO[j].type=NULL;
            myHO[j].lots=NULL;
            myHO[j].opentime=NULL;
            myHO[j].openprice=NULL;
            myHO[j].closetime=NULL;
            myHO[j].closeprice=NULL;
            myHO[j].stoploss=NULL;
            myHO[j].takeprofit=NULL;
            myHO[j].profit=NULL;
            myHO[j].commission=NULL;
            myHO[j].swap=NULL;
            myHO[j].comment=NULL;
            myHO[j].magicnumber=NULL;
            
            myHO[j].ticket=OrderTicket();                                       //订单号
            myHO[j].symbol=OrderSymbol();                                       //商品名称
            myHO[j].type=OrderType();                                           //订单类型
            myHO[j].lots=OrderLots();                                           //开仓量
            myHO[j].opentime=OrderOpenTime();                                   //开仓时间
            myHO[j].openprice=NormalizeDouble(OrderOpenPrice(),Digits);         //建仓价
            myHO[j].closetime=OrderCloseTime();                                 //平仓时间
            myHO[j].closeprice=NormalizeDouble(OrderClosePrice(),Digits);       //平仓价
            myHO[j].stoploss=NormalizeDouble(OrderStopLoss(),Digits);           //止损价
            myHO[j].takeprofit=NormalizeDouble(OrderTakeProfit(),Digits);       //止盈价
            myHO[j].profit=OrderProfit();                                       //利润
            myHO[j].commission=OrderCommission();                               //佣金
            myHO[j].swap=OrderSwap();                                           //利息
            myHO[j].comment=OrderComment();                                     //注释
            myHO[j].magicnumber=OrderMagicNumber();                             //程序识别码
            j++;
        }
    }
    if (j>0) 
    {
        ArrayResize(myHO,j); //重新界定数组边界
    }
    else //没有持仓单，所有项目NULL
    {
        ArrayResize(myHO,1);
        myHO[j].ticket=NULL;
        myHO[j].symbol=NULL;
        myHO[j].type=NULL;
        myHO[j].lots=NULL;
        myHO[j].opentime=NULL;
        myHO[j].openprice=NULL;
        myHO[j].closetime=NULL;
        myHO[j].closeprice=NULL;
        myHO[j].stoploss=NULL;
        myHO[j].takeprofit=NULL;
        myHO[j].profit=NULL;
        myHO[j].commission=NULL;
        myHO[j].swap=NULL;
        myHO[j].comment=NULL;
        myHO[j].magicnumber=NULL;
    }
    return(j);
}
