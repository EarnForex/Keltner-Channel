//+------------------------------------------------------------------+
//|                                              Keltner_Channel.mq4 |
//                                        Based on version by Gilani |
//|                             Copyright © 2011-2022, EarnForex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011-2022, www.EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/Keltner-Channel/"
#property version   "1.01"
#property strict

#property description "Displays classical Keltner Channel technical indicator."
#property description "You can modify main MA period, mode of the MA and type of prices used in MA."
#property description "Buy when candle closes above the upper band."
#property description "Sell when candle closes below the lower band."
#property description "Use a *very conservative* stop-loss and 3-4 times higher take-profit."

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrRed
#property indicator_type1 DRAW_LINE
#property indicator_label1 "KC-Up"
#property indicator_color2 clrBlue
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_DASHDOT
#property indicator_label2 "KC-Mid"
#property indicator_color3 clrRed
#property indicator_type3 DRAW_LINE
#property indicator_label3 "KC-Low"

input int MA_Period = 10;
input ENUM_MA_METHOD Mode_MA = MODE_SMA;
input ENUM_APPLIED_PRICE Price_Type = PRICE_TYPICAL;

double Upper[], Middle[], Lower[];

void OnInit()
{
    SetIndexBuffer(0, Upper);
    SetIndexBuffer(1, Middle);
    SetIndexBuffer(2, Lower);

    IndicatorSetString(INDICATOR_SHORTNAME, "Keltner Channel (" + IntegerToString(MA_Period) + ")");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time_timeseries[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]
               )
{
    int limit;
    double avg;
    int counted_bars = IndicatorCounted();
    if (counted_bars < 0) return -1;
    if (Bars < MA_Period) return 0;
    if (counted_bars > 0) counted_bars--;

    limit = Bars - counted_bars;
    if (limit > Bars - MA_Period) limit = Bars - MA_Period;

    for (int i = 0; i < limit; i++)
    {
        Middle[i] = iMA(NULL, 0, MA_Period, 0, Mode_MA, Price_Type, i);
        avg = findAvg(MA_Period, i);
        Upper[i] = Middle[i] + avg;
        Lower[i] = Middle[i] - avg;
    }

    return rates_total;
}

//+------------------------------------------------------------------+
//| Finds the moving average of the price ranges                     |
//+------------------------------------------------------------------+
double findAvg(int period, int shift)
{
    double sum = 0;

    for (int i = shift; i < (shift + period); i++)
        sum += High[i] - Low[i];

    sum = sum / period;

    return(sum);
}
//+------------------------------------------------------------------+