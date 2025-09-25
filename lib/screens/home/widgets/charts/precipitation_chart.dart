import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../models/weather_model.dart';
import '../../../../utils/colors.dart';

class PrecipitationChart extends StatelessWidget {
  final List<HourlyWeatherModel> hourlyWeather;

  const PrecipitationChart({
    super.key,
    required this.hourlyWeather,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyWeather.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '24시간 강수 확률',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
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
                      reservedSize: 35.h,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < hourlyWeather.length && index % 2 == 0) {
                          final hour = hourlyWeather[index].time.hour;
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              '${hour}시',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
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
                      interval: 25,
                      reservedSize: 45.w,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 9.sp,
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
                barGroups: _getPrecipitationBars(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.white10,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex >= 0 && groupIndex < hourlyWeather.length) {
                        final weather = hourlyWeather[groupIndex];
                        return BarTooltipItem(
                          '${weather.time.hour}시\n${weather.precipitationProbability}%',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        );
                      }
                      return null;
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

  List<BarChartGroupData> _getPrecipitationBars() {
    return List.generate(hourlyWeather.length, (index) {
      final precipitation = hourlyWeather[index].precipitationProbability;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: precipitation.toDouble(),
            color: _getPrecipitationColor(precipitation.round()),
            width: 12.w,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(4.r),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                _getPrecipitationColor(precipitation.round()).withValues(alpha: 0.6),
                _getPrecipitationColor(precipitation.round()),
              ],
            ),
          ),
        ],
        showingTooltipIndicators: [],
      );
    });
  }

  Color _getPrecipitationColor(int precipitation) {
    if (precipitation < 20) {
      return Colors.green.withValues(alpha: 0.8);
    } else if (precipitation < 50) {
      return Colors.yellow.withValues(alpha: 0.8);
    } else if (precipitation < 75) {
      return Colors.orange.withValues(alpha: 0.8);
    } else {
      return Colors.red.withValues(alpha: 0.8);
    }
  }
}