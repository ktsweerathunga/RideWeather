import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_model.dart';

class RainProbabilityChart extends StatelessWidget {
  final List<HourlyWeather> hourlyData;
  final Color primaryColor;

  const RainProbabilityChart({
    super.key,
    required this.hourlyData,
    this.primaryColor = const Color(0xFF3B82F6),
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No hourly data available')),
      );
    }

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()}%\n${_getHourLabel(groupIndex)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _getHourLabel(value.toInt()),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 25,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _createBarGroups(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return hourlyData.asMap().entries.map((entry) {
      final index = entry.key;
      final weather = entry.value;
      final rainProbability = weather.rainProbability.toDouble();

      Color barColor;
      if (rainProbability >= 80) {
        barColor = const Color(0xFFDC2626); // Red
      } else if (rainProbability >= 60) {
        barColor = const Color(0xFFEA580C); // Orange
      } else if (rainProbability >= 40) {
        barColor = const Color(0xFFFBBF24); // Yellow
      } else if (rainProbability >= 20) {
        barColor = const Color(0xFF10B981); // Green
      } else {
        barColor = const Color(0xFF10B981); // Green
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: rainProbability,
            color: barColor,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            gradient: LinearGradient(
              colors: [
                barColor,
                barColor.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      );
    }).toList();
  }

  String _getHourLabel(int index) {
    if (index >= 0 && index < hourlyData.length) {
      final hour = hourlyData[index].dateTime.hour;
      return '${hour.toString().padLeft(2, '0')}:00';
    }
    return '';
  }
}
