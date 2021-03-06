#include    "ttEnvironmentVariables.mqh"     //环境变量
#include    "ttOrdersVariables.mqh"          //通用函数库

ButtonVariable Main_bnt[3]; //主控按钮名称变量 开关仪表盘、启动暂停EA、一键清仓
string PrvfixString ="tt"+StringSubstr(__FILE__,0,StringLen(__FILE__)-4); //程序名作为对象名前缀关键字，以便批量删除，不影响其他对象

/*
函    数:输出标签到图表
输出参数:true-输出成功
算    法:
*/
bool    egLableOut(const    bool                isout=true,               //允许输出
                   const    string              text="Label",             //输出内容
                   const    string              name="Label",             //对象名称
                   const    int                 font_size=10,             //字体尺寸
                   const    color               clr=clrRed,               //字体颜色
                   const    long                chart_ID=0,               //主图ID
                   const    int                 sub_window=0,             //副图编号
                   const    ENUM_BASE_CORNER    corner=CORNER_LEFT_UPPER, //锚点
                   const    int                 x=0,                      //x坐标
                   const    int                 y=0,                      //y坐标
                   const    string              font="Arial",             //字体类型
                   const    double              angle=0.0,                //字体角度
                   const    ENUM_ANCHOR_POINT   anchor=ANCHOR_LEFT_UPPER, //原始坐标
                   const    bool                back=false,               //设置为背景
                   const    bool                selection=false,          //高亮移动
                   const    bool                hidden=false,             //列表中隐藏对象名
                   const    long                z_order=0                 //priority for mouse click
                  )
{
    if (!isout) return(false);
    if (ObjectFind(chart_ID,name)!=-1)
    {
        //修改对象属性
        ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
        ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
        ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
        ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
        ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
        ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
        ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
        ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
        ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
        ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
        ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
        ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
        ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
        ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
        return(true);
    }
    //创建输出对象
    ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0);
    ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
    ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
    ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
    ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
    ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
    ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
    ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
    ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
    ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
    ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
    ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
    ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
    return(true);
}


/*
函    数:删除关键字对象
输出参数:
算    法:
*/
void egObjectsDeleteByKeyword(const  long   chart_ID=0, //主图ID
                                     string keyword=""
                             )
{
    for (int i=ObjectsTotal(chart_ID)-1;i>=0;i--)
    {
        if (StringFind(ObjectName(i),keyword,0)>-1)
        {
            ObjectDelete(chart_ID,ObjectName(i));
        }
    }
    return;
}

//+------------------------------------------------------------------+
//| 初始化面板 按钮等                                                |
//+------------------------------------------------------------------+  

void Init_UI(TradesStatistical &TS_in)
{
   //--- 主控按钮变量初始化 开关仪表盘、启动暂停EA、一键清仓
   Main_bnt[0].name=PrvfixString+"_btn_DB"; //开关仪表盘按钮名称
   Main_bnt[0].state=false;
   Main_bnt[1].name=PrvfixString+"_btn_EA"; //启动暂停EA按钮名称
   Main_bnt[1].state=true;
   Main_bnt[2].name=PrvfixString+"_btn_CL"; //一键清仓按钮名称
   Main_bnt[2].state=true;
   egMainButton(TS_in);
}

//+------------------------------------------------------------------+
//|  主控按钮                                                        |
//|  根据Main_Button_State显示按钮状态
//+------------------------------------------------------------------+
void egMainButton(TradesStatistical &TS_in)
{
   long   chartID =0;
//--- 没有按钮，创建按钮
   if(ObjectFind(chartID,Main_bnt[1].name)==-1)
   {
      bool restest =egButtonOut(true,chartID,Main_bnt[1].name,0,260,3,40,15,CORNER_RIGHT_UPPER,"EA  ||","Arial",7,clrWhite,clrGreen,clrGray,false,false,false,true,0);
   }
   if(ObjectFind(chartID,Main_bnt[2].name)==-1)
   {
      egButtonOut(true,chartID,Main_bnt[2].name,0,330,3,65,15,CORNER_RIGHT_UPPER,"Close All >>","Arial",7,clrWhite,clrGreen,clrGray,false,false,false,true,0);
   }
//--- 根据Main_Button_State显示按钮状态
//执行暂停EA
   if(ObjectFind(chartID,Main_bnt[1].name)!=-1
      && ((   Main_bnt[1].state==false
      && ObjectSetString(chartID,Main_bnt[1].name,OBJPROP_TEXT,"EA  >>")
      && ObjectSetInteger(chartID,Main_bnt[1].name,OBJPROP_BGCOLOR,clrSlateGray)
      )
      || (Main_bnt[1].state==true
      && ObjectSetString(chartID,Main_bnt[1].name,OBJPROP_TEXT,"EA  ||")
      && ObjectSetInteger(chartID,Main_bnt[1].name,OBJPROP_BGCOLOR,clrGreen)
      )
      )
      )
   {
   }
//一键清仓
   if(ObjectFind(chartID,Main_bnt[2].name)!=-1
      && (( TS_in.buy_orders + TS_in.buylimit_orders + TS_in.buystop_orders + TS_in.sell_orders + TS_in.selllimit_orders + TS_in.sellstop_orders == 0
      && ObjectSetString(chartID,Main_bnt[2].name,OBJPROP_TEXT,"Close All ..")
      && ObjectSetInteger(chartID,Main_bnt[2].name,OBJPROP_BGCOLOR,clrSlateGray)
      && ObjectSetInteger(chartID,Main_bnt[2].name,OBJPROP_STATE,false)
      )
      || ( TS_in.buy_orders + TS_in.buylimit_orders + TS_in.buystop_orders + TS_in.sell_orders + TS_in.selllimit_orders + TS_in.sellstop_orders > 0
      && ObjectSetString(chartID,Main_bnt[2].name,OBJPROP_TEXT,"Close All >>")
      && ObjectSetInteger(chartID,Main_bnt[2].name,OBJPROP_BGCOLOR,clrGreen)
      && ObjectSetInteger(chartID,Main_bnt[2].name,OBJPROP_STATE,false)
      )
      )
      )
   {
      Main_bnt[2].state=false;
   }

   return;
  }
  

/*
函    数:输出按钮到图表
输出参数:true-输出成功
算    法:
*/
bool    egButtonOut(const   bool              isout=true,               //允许输出
                    const   long              chart_ID=0,               //主图ID
                    const   string            name="Button",            //对象名称
                    const   int               sub_window=0,             //副图编号
                    const   int               x=0,                      //x坐标
                    const   int               y=0,                      //y坐标
                    const   int               width=50,                 //按钮宽度
                    const   int               height=18,                //按钮高度
                    const   ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, //锚点
                    const   string            text="Button",            //按钮文字
                    const   string            font="Arial",             //文字字体
                    const   int               font_size=10,             //文字尺寸
                    const   color             clr=clrBlack,             //文字颜色
                    const   color             back_clr=clrGray,         //背景色
                    const   color             border_clr=clrNONE,       //边框色
                    const   bool              state=false,              //按下状态
                    const   bool              back=false,               //设置为背景
                    const   bool              selection=false,          //高亮移动
                    const   bool              hidden=true,              //列表中隐藏对象名
                    const   long              z_order=0                 // priority for mouse click
                   )
{
    if (!isout) return(true);
    //更改对象属性
    if (ObjectFind(chart_ID,name)!=-1)
    {
        ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
        ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
        ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
        ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
        ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
        ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
        ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
        ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
        ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
        ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
        ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
        ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
        ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
        ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
        ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
        ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
        ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
        return(true);
    }
    //创建输出对象
    ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
    ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
    ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
    ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
    ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
    ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
    ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
    ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
    ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
    ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
    ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
    ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
    ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
    ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
    ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
    ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
    return(true);
}

//+------------------------------------------------------------------+
//|输出                                                              |
//+------------------------------------------------------------------+
void Write(string name, int x, int y, string text, int fontsize, string fontname, color setColor) {
   if(ObjectFind(name)<0) ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(name, text, fontsize, fontname, setColor);
   ObjectSet(name, OBJPROP_CORNER, 1);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
}
