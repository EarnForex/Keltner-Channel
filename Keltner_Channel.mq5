//+------------------------------------------------------------------+
//|                                              Keltner_Channel.mq5 |
//                                        Based on version by Gilani |
//|                             Copyright © 2011-2022, EarnForex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011-2022, www.EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/Keltner-Channel/"
#property version   "1.01"

#property description "Displays classical Keltner Channel technical indicator."
#property description "You can modify main MA period, mode of the MA and type of prices used in MA."
#property description "Buy when candle closes above the upper band."
#property description "Sell when candle closes below the lower band."
#property description "Use a *very conservative* stop-loss and 3-4 times higher take-profit."

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
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

double Upper[], Middle[], Lower[], MA_Buffer;

void OnInit()
{
    SetIndexBuffer(0, Upper, INDICATOR_DATA);
    SetIndexBuffer(1, Middle, INDICATOR_DATA);
    SetIndexBuffer(2, Lower, INDICATOR_DATA);

    IndicatorSetString(INDICATOR_SHORTNAME, "Keltner Channel (" + IntegerToString(MA_Period) + ")");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    int limit;
    double avg;

    int counted_bars = prev_calculated;

    if (counted_bars < 0) return -1;
    if (counted_bars > 0) counted_bars--;

    limit = counted_bars;

    if (limit < MA_Period) limit = MA_Period;

    int myMA = iMA(NULL, 0, MA_Period, 0, Mode_MA, Price_Type);
    if  (CopyBuffer(myMA, 0, 0, rates_total, Middle) != rates_total) return 0;

    for (int i = rates_total - 1; i >= limit; i--)
    {
        avg = findAvg(MA_Period, i, High, Low);
        Upper[i] = Middle[i] + avg;
        Lower[i] = Middle[i] - avg;
    }

    return rates_total;
}

//+------------------------------------------------------------------+
//| Finds the moving average of the price ranges                     |
//+------------------------------------------------------------------+
double findAvg(int period, int shift, const double &High[], const double &Low[])
{
    double sum = 0;

    for (int i = shift; i > (shift - period); i--)
        sum += High[i] - Low[i];

    sum = sum / period;

    return(sum);
}
//+------------------------------------------------------------------+