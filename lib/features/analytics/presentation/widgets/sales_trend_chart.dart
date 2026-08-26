import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/sales_report_model.dart';
import '../utils/analytics_formatters.dart';

class SalesTrendChart extends StatelessWidget {
  final List<SalesTrendModel> trend;

  const SalesTrendChart({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: Colors.white,
        child: Container(
          height: 220,
          alignment: Alignment.center,
          child: Text(
            'No sales trend data available for this period',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
      );
    }

    final grossSpots = <FlSpot>[];
    final netSpots = <FlSpot>[];

    double maxVal = 0;
    for (int i = 0; i < trend.length; i++) {
      final item = trend[i];
      grossSpots.add(FlSpot(i.toDouble(), item.grossSales));
      netSpots.add(FlSpot(i.toDouble(), item.netSales));
      if (item.grossSales > maxVal) maxVal = item.grossSales;
      if (item.netSales > maxVal) maxVal = item.netSales;
    }

    if (maxVal == 0) maxVal = 1000;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Revenue Trend',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    _buildLegendItem('Gross', Colors.blue.shade600),
                    const SizedBox(width: 12),
                    _buildLegendItem('Net', Colors.teal.shade700),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (val, meta) {
                          if (val == 0) return const SizedBox.shrink();
                          return Text(
                            AnalyticsFormatters.formatCompactCurrency(val),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: trend.length > 6 ? (trend.length / 4).ceilToDouble() : 1,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < trend.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                AnalyticsFormatters.formatShortDate(trend[idx].periodStart),
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (trend.length - 1).toDouble().clamp(0, double.infinity),
                  minY: 0,
                  maxY: maxVal * 1.15,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isGross = spot.barIndex == 0;
                          return LineTooltipItem(
                            '${isGross ? "Gross" : "Net"}: ${AnalyticsFormatters.formatCurrency(spot.y)}',
                            TextStyle(
                              color: isGross ? Colors.blue.shade200 : Colors.tealAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: grossSpots,
                      isCurved: true,
                      color: Colors.blue.shade600,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: netSpots,
                      isCurved: true,
                      color: Colors.teal.shade600,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
