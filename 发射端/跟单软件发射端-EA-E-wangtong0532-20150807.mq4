//+------------------------------------------------------------------+
//|ProjectName |
//|Copyright 2012, CompanyName |
//| http://www.companyname.net |
//+------------------------------------------------------------------+
#include "MQLMySQL.mqh"
#property copyright "云脑发射1.0" 
#import "kernel32.dll"
int CopyFileW(string a0,string a1,int a2);
bool CreateDirectoryW(string a0,int a1);
#import
string 中转文件名="";
string FILES文件夹路径="";
string FILES文件夹路径2;
string 中转路径="";
string 中转路径2="";
input string 间隔符="*";
int X=20;
int Y=20;
int Y间隔=15;
color 标签颜色=Yellow;
int 标签字体大小=10;
ENUM_BASE_CORNER 固定角=0;
int tot = 0;
//+------------------------------------------------------------------+
//| 数据库所用变量                                                   |
//+------------------------------------------------------------------+
string Host          = "47.97.148.3";  //rm-bp1j586223j82v556zo.mysql.rds.aliyuncs.com
string User          = "liyongquan";
string Password      = ""; 
string Database      = "develop";
string table         = "tradeplan";
string Socket        = "";
int    Port          = 3306;
int    ClientFlag    = CLIENT_MULTI_STATEMENTS;
int    DB; // database identifier
TradesOrders TradSch[];
//+------------------------------------------------------------------+
//| 数据库连接函数                                                   |
//+------------------------------------------------------------------+
bool real_connect()
{
   Print (MySqlVersion());
   Print ("Host: ",Host, ", User: ", User, ", Database: ",Database);
   Print ("Connecting...");
   
   DB = MySqlConnect(Host, User, Password, Database, Port, Socket, ClientFlag);
   
   if (DB == -1) { Print ("Connection failed!Error: "+MySqlErrorDescription); return(false);} else { Print ("Connected!DBID#",DB);}
   
   return(true);
}

//+------------------------------------------------------------------+
//||
//+------------------------------------------------------------------+
int OnInit()
  {

    EventSetTimer(10);
   if(IsDllsAllowed()==false)
   Alert("请允许调用动态链接库");
   OnTick();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//||
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   for(int i=ObjectsTotal();i>=0;i--)
     {
      if(StringFind(ObjectName(i),"标签",0)==0)
        {
         ObjectDelete(ObjectName(i));
         i=ObjectsTotal();
        }
     }
  }
//+------------------------------------------------------------------+
//||
//+------------------------------------------------------------------+
void OnTick()
  {
  
   if(IsDllsAllowed()==false)
      return;

   if(中转路径=="")
     {
      CreateDirectoryW("C:\\云脑中转路径",0);
      中转路径2="C:\\云脑中转路径";
     }
   else
      中转路径2=中转路径;
      
      string 内容[100];
      内容[0]="----------智汇量化跟单软件发射端------------";
      内容[1]="--------------已开启跟单发射端--------------";

      for(int ixx=0;ixx<=1;ixx++)
         固定位置标签("标签"+(string)ixx,内容[ixx],X,Y+Y间隔*ixx,标签颜色,标签字体大小,固定角);

      中转文件名=DoubleToStr(AccountNumber(),0);
      
      RefreshRates();
      int handle;
      handle=FileOpen(中转文件名+".csv",FILE_CSV|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ,间隔符);
      int total = 0;
      if(handle>0)
        {
         for(int i=OrdersTotal();i>=0;i--)
            if(OrderSelect(i,SELECT_BY_POS))
              {
               tot=OrderTicket();
               total+=tot;
               FileWrite(handle,OrderTicket(),OrderSymbol(),OrderType(),OrderLots(),OrderStopLoss(),
                         OrderTakeProfit(),OrderComment(),OrderMagicNumber(),
                         OrderOpenTime()-TimeCurrent()+TimeLocal(),OrderOpenPrice(),MarketInfo(OrderSymbol(),MODE_TICKVALUE));       
              }
             
         FileClose(handle);
        }
        if(和()!=total){
            更新持仓数据();
            同步信息();
            持仓(total);
        }
      if(OrdersHistoryTotal()>取数()){ 
      int count = OrdersHistoryTotal()-取数();
      历史();
      更新历史数据(count);
      }  
      if(FILES文件夹路径!="")
         FILES文件夹路径2=FILES文件夹路径;
      else
         FILES文件夹路径2=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files";

      int t=CopyFileW(FILES文件夹路径2+"\\"+中转文件名+".csv",中转路径2+"\\"+中转文件名+".csv",0);

      t=CopyFileW(FILES文件夹路径2+"\\"+中转文件名+"2.csv",中转路径2+"\\"+中转文件名+"2.csv",0);
      

      if(!(!IsStopped() && IsExpertEnabled() && IsTesting()==false && IsOptimization()==false))
         return;
      Sleep(300);
     
   return;
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   double equity = AccountEquity();
   int Account = 接收端账号();
   //Alert("Account:",Account);
   if(Account!=-1){
      净值传入(equity,Account);
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   OnTick();
  }
//+------------------------------------------------------------------+
void 固定位置标签(string 名称,string 内容,int XX,int YX,color C,int 字体大小,int 固定角内)
  {
   if(内容==(string)EMPTY)
      return;
   if(ObjectFind(名称)==-1)
     {
      ObjectDelete(名称);
      ObjectCreate(名称,OBJ_LABEL,0,0,0);
     }
   ObjectSet(名称,OBJPROP_XDISTANCE,XX);
   ObjectSet(名称,OBJPROP_YDISTANCE,YX);
   ObjectSetText(名称,内容,字体大小,"宋体",C);
   ObjectSet(名称,OBJPROP_CORNER,固定角内);
   ObjectSetInteger(0,名称,OBJPROP_ANCHOR,ANCHOR_LEFT);
  }

void 同步信息()
{  
   int count = OrdersHistoryTotal()-取数();
   for(int i=((OrdersHistoryTotal()-1)-count);i<OrdersHistoryTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
        int tk = OrderTicket();
        删除已平仓信息(tk);
        }
      }
}
void 更新持仓数据()
{
   中转文件名=DoubleToStr(AccountNumber(),0);
   int handle;
   handle=FileOpen(中转文件名+".csv",FILE_CSV|FILE_READ|FILE_SHARE_WRITE|FILE_SHARE_READ,间隔符);
   if(handle>0){
      for(int i=0;i<OrdersTotal();i++){
        int tk = FileReadString(handle);
        string sy = FileReadString(handle);
        string ty = FileReadString(handle);
        string lot = FileReadString(handle);
        string sl = FileReadString(handle);
        string tp = FileReadString(handle);
        string c = FileReadString(handle);
        string m = FileReadString(handle);
        string ot = FileReadString(handle);
        string op = FileReadString(handle);
        string d = FileReadString(handle);
        string info = StringConcatenate(tk,"*",sy,"*",ty,"*",lot,"*",sl,"*",tp,"*",c,"*",m,"*",ot,"*",op,"*",d);
        if(StringFind(info,"*",0)>1){
        向数据库插入持仓信息(AccountNumber(),info,tk);
        }else{
         continue;
        }
      }
   }
    FileClose(handle);

}

void 更新历史数据(int count)
{
  for(int i=((OrdersHistoryTotal()-1)-count);i<OrdersHistoryTotal();i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
        string tk = OrderTicket();
        string sy = OrderSymbol();
        string ty = OrderType();
        string lot = OrderLots();
        string sl = OrderStopLoss();
        string tp =OrderTakeProfit();
        string c = OrderComment();
        string m = OrderMagicNumber();
        string ot = OrderOpenTime()-TimeCurrent()+TimeLocal();
        string op = OrderOpenPrice();
        string info = StringConcatenate(tk,"*",sy,"*",ty,"*",lot,"*",sl,"*",tp,"*",c,"*",m,"*",ot,"*",op); 
        向数据库插入历史信息(AccountNumber(),info,tk);
      }
  }
}
//+------------------------------------------------------------------+
//| 插入持仓信息                                                     |
//+------------------------------------------------------------------+
void 向数据库插入持仓信息(int account,string info,string ticket)  
{
   string Query;
   if(real_connect()==false){printf("插入账户信息时连接数据库错误！");}
   // Inserting data 1 row
   Query = StringConcatenate("INSERT INTO tradeorderinfo (account,info,ticket) SELECT ",account,",'",info,"','",ticket,"' FROM DUAL WHERE NOT EXISTS(SELECT ticket FROM tradeorderinfo WHERE ticket = '",ticket,"')");
   if (MySqlExecute(DB, Query)) {
      Print ("Succeeded: ", Query);
   }
   else {
      Print ("Error: ", MySqlErrorDescription);
      Print ("Query: ", Query);
   }
   MySqlDisconnect(DB);
   Print ("Disconnected. Script done!");
}

//+------------------------------------------------------------------+
//| 插入历史信息                                                     |
//+------------------------------------------------------------------+
void 向数据库插入历史信息(int account,string info,string ticket)  
{

   string Query;
   if(real_connect()==false){printf("插入账户信息时连接数据库错误！");}
   // Inserting data 1 row
   Query = StringConcatenate("INSERT INTO hisorderinfo (account,info,ticket) SELECT ",account,",'",info,"','",ticket,"' FROM DUAL WHERE NOT EXISTS(SELECT ticket FROM hisorderinfo WHERE ticket = '",ticket,"')");
   if (MySqlExecute(DB, Query)) {
      Print ("Succeeded: ", Query);
   }
   else {
      Print ("Error: ", MySqlErrorDescription);
      Print ("Query: ", Query);
   }
    MySqlDisconnect(DB);
   Print ("Disconnected. Script done!");
}
//+------------------------------------------------------------------+
//| 删除持仓信息                                                     |
bool 删除已平仓信息(int ticket)  
{
   string Query;
   if(real_connect()==false){printf("删除账户信息时连接数据库错误！");}
   // Inserting data 1 row
   Query = StringConcatenate("DELETE FROM tradeorderinfo WHERE ticket = ",ticket," ");
   if (MySqlExecute(DB, Query)) {
      Print ("Succeeded: ", Query);
   }
   else {
      Print ("Error: ", MySqlErrorDescription);
      Print ("Query: ", Query);
   }
   MySqlDisconnect(DB);
   Print ("Disconnected. Script done!");
   return(true);
}
void 历史()
{  
   if(IsDllsAllowed()==false)
      return;

   if(中转路径=="")
     {
      CreateDirectoryW("C:\\云脑中转路径",0);
      中转路径2="C:\\云脑中转路径";
     }
   else
      中转路径2=中转路径;

      中转文件名=DoubleToStr(AccountNumber(),0);
      RefreshRates();
      int handle;
      handle=FileOpen(中转文件名+"3.csv",FILE_CSV|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ,间隔符);
      if(handle>0)
        {
               FileWrite(handle,OrdersHistoryTotal());       
              
         FileClose(handle);
        }
      if(FILES文件夹路径!="")
         FILES文件夹路径2=FILES文件夹路径;
      else
         FILES文件夹路径2=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files";

      int t=CopyFileW(FILES文件夹路径2+"\\"+中转文件名+"3.csv",中转路径2+"\\"+中转文件名+"3.csv",0);


      if(!(!IsStopped() && IsExpertEnabled() && IsTesting()==false && IsOptimization()==false))
         return;
      Sleep(300); 
   return;
}
int hisorder;
int 取数()
{  

   中转文件名=DoubleToStr(AccountNumber(),0);
   int handle;
   handle=FileOpen(中转文件名+"3.csv",FILE_CSV|FILE_READ|FILE_SHARE_WRITE|FILE_SHARE_READ,间隔符);
   if(handle>0){
      for(int i=0;i<1;i++){
         hisorder = FileReadString(handle);
      }
      FileClose(handle);
   }
    return(hisorder);

return(-1);

}
void 持仓(int total)
{  
   if(IsDllsAllowed()==false)
      return;

   if(中转路径=="")
     {
      CreateDirectoryW("C:\\云脑中转路径",0);
      中转路径2="C:\\云脑中转路径";
     }
   else
      中转路径2=中转路径;

      中转文件名=DoubleToStr(AccountNumber(),0);
      RefreshRates();
      int handle;
      handle=FileOpen(中转文件名+"4.csv",FILE_CSV|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ,间隔符);
      if(handle>0)
        {
               FileWrite(handle,total);       
              
         FileClose(handle);
        }
      if(FILES文件夹路径!="")
         FILES文件夹路径2=FILES文件夹路径;
      else
         FILES文件夹路径2=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files";

      int t=CopyFileW(FILES文件夹路径2+"\\"+中转文件名+"4.csv",中转路径2+"\\"+中转文件名+"4.csv",0);


      if(!(!IsStopped() && IsExpertEnabled() && IsTesting()==false && IsOptimization()==false))
         return;
      Sleep(300); 
   return;
}
int he;
int 和()
{  

   中转文件名=DoubleToStr(AccountNumber(),0);
   int handle;
   handle=FileOpen(中转文件名+"4.csv",FILE_CSV|FILE_READ|FILE_SHARE_WRITE|FILE_SHARE_READ,间隔符);
   if(handle>0){
      for(int i=0;i<1;i++){
         he = FileReadString(handle);
      }
      FileClose(handle);
   }
    return(he);

return(-1);

}
void 净值传入(double equity,int account){

    string Query;
   if(real_connect()==false){printf("更新净值信息时连接数据库错误！");}
   // Inserting data 1 row
   Query = StringConcatenate("UPDATE parameterinfo SET MAccEquity =",equity," WHERE account = ",account,"");
   if (MySqlExecute(DB, Query)) {
      Print ("Succeeded: ", Query);
   }
   else {
      Print ("Error: ", MySqlErrorDescription);
      Print ("Query: ", Query);
   }
    MySqlDisconnect(DB);
   Print ("Disconnected. Script done!");

}

int 接收端账号()
{
   int    i,Cursor,Rows;
    int Maccount = AccountNumber();
   if(real_connect()==false){printf("查询净值时连接数据库错误！"); return(false);}
   string Query = StringConcatenate("SELECT account FROM parameterinfo WHERE Mainaccount = ",Maccount," and MAccEquity = 0.00");
   Print ("SQL> ", Query);
   Cursor = MySqlCursorOpen(DB, Query);
   if (Cursor >= 0)  {
     Rows = MySqlCursorRows(Cursor);
     Print (Rows, " row(s) selected.");
     for (i=0; i<Rows; i++)   {
      if (MySqlCursorFetchRow(Cursor))  {
        int account = MySqlGetFieldAsInt(Cursor, 0);
        MySqlCursorClose(Cursor); // NEVER FORGET TO CLOSE CURSOR !!!
        MySqlDisconnect(DB);
        Print ("Disconnected. Script done!"); 
        return(account); 
      }
     } 
   }
   MySqlCursorClose(Cursor); // NEVER FORGET TO CLOSE CURSOR !!!
   MySqlDisconnect(DB);
   Print ("Disconnected. Script done!");  
   return(-1);
}
