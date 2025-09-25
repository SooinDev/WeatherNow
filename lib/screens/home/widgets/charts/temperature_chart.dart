import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../models/weather_model.dart';
import '../../../../utils/colors.dart';

class TemperatureChart extends StatelessWidget {
  final List<HourlyWeatherModel> hourlyWeather;
  final bool isCelsius;

  const TemperatureChart({
    super.key,
    required this.hourlyWeather,
    this.isCelsius = true,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyWeather.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '24시간 온도 변화',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 100.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.2),
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
                      reservedSize: 30.h,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        // 8시간 간격으로 표시하여 훨씬 더 넓은 간격 확보
                        if (index >= 0 && index < hourlyWeather.length && index % 8 == 0) {
                          final hour = hourlyWeather[index].time.hour;
                          return Container(
                            margin: EdgeInsets.only(top: 12.h),
                            child: Text(
                              '$hour시',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 2.0,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 35.w,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: Text(
                            '${value.toInt()}°',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (hourlyWeather.length - 1).toDouble(),
                minY: _getMinTemp() - 2,
                maxY: _getMaxTemp() + 2,
                lineBarsData: [
                  LineChartBarData(
                    spots: _getTemperatureSpots(),
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: Colors.white,
                          strokeWidth: 1.5,
                          strokeColor: AppColors.white30,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.white20,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final index = barSpot.x.toInt();
                        if (index >= 0 && index < hourlyWeather.length) {
                          final weather = hourlyWeather[index];
                          return LineTooltipItem(
                            '${weather.time.hour}시\n${weather.temperature.round()}°C',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getTemperatureSpots() {
    // 3시간 간격으로 데이터 포인트를 줄여서 덜 촘촘하게 표시
    List<FlSpot> spots = [];
    for (int i = 0; i < hourlyWeather.length; i += 3) {
      final temp = hourlyWeather[i].temperature;
      spots.add(FlSpot(i.toDouble(), temp));
    }
    return spots;
  }

  double _getMinTemp() {
    if (hourlyWeather.isEmpty) return 0;
    return hourlyWeather.map((w) => w.temperature).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxTemp() {
    if (hourlyWeather.isEmpty) return 0;
    return hourlyWeather.map((w) => w.temperature).reduce((a, b) => a > b ? a : b);
  }
}