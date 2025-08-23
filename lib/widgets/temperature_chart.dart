import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';

class TemperatureChart extends StatelessWidget {
  final List<DailyWeather> forecasts;
  final Color primaryColor;

  const TemperatureChart({
    super.key,
    required this.forecasts,
    this.primaryColor = const Color(0xFF3B82F6),
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= 0 && value.toInt() < forecasts.length) {
                    final forecast = forecasts[value.toInt()];
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        '${forecast.date.day}/${forecast.date.month}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}°',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          minX: 0,
          maxX: (forecasts.length - 1).toDouble(),
          minY: _getMinTemp() - 2,
          maxY: _getMaxTemp() + 2,
          lineBarsData: [
            // High temperature line
            LineChartBarData(
              spots: _getHighTempSpots(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.7),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: primaryColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.3),
                    primaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Low temperature line
            LineChartBarData(
              spots: _getLowTempSpots(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade300,
                  Colors.blue.shade200,
                ],
              ),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.blue.shade300,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getHighTempSpots() {
    return forecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.maxTemp);
    }).toList();
  }

  List<FlSpot> _getLowTempSpots() {
    return forecasts.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.minTemp);
    }).toList();
  }

  double _getMinTemp() {
    return forecasts.map((f) => f.minTemp).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxTemp() {
    return forecasts.map((f) => f.maxTemp).reduce((a, b) => a > b ? a : b);
  }
}
