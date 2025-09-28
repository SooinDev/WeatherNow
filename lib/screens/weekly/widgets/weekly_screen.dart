import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/weather_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/text_styles.dart';
import '../../../utils/constants.dart';
import 'package:intl/intl.dart';

class WeeklyScreen extends StatefulWidget {
  final VoidCallback onClose;
  final List<WeeklyWeatherModel> weeklyWeather;
  final String? weatherType;
  final WeatherModel? currentWeather;

  const WeeklyScreen({
    super.key,
    required this.onClose,
    required this.weeklyWeather,
    this.weatherType,
    this.currentWeather,
  });

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeWithAnimation() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _closeWithAnimation,
          onPanUpdate: (details) {
            // 아래로 스와이프하면 닫기
            if (details.delta.dy > 6) {
              _closeWithAnimation();
            }
          },
          child: Container(
            color: AppColors.black30.withValues(alpha: _fadeAnimation.value * 0.8),
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                    // 드래그 핸들
                    Container(
                      margin: EdgeInsets.only(top: 20.h, bottom: 10.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.white30,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '주간 날씨',
                      style: AppTextStyles.sectionHeader.copyWith(
                        fontSize: 22.sp, // 크기 증가로 가독성 향상
                        fontWeight: FontWeight.w700, // 더 강조된 가독성
                        letterSpacing: 0.5, // 글자 간격 추가
                        height: 1.2, // 줄 간격 개선
                        color: AppConstants.darkPrimaryTextColor,
                      ),
                    ),

                    // 일출/일몰 정보 (currentWeather가 있을 때만 표시)
                    if (widget.currentWeather?.sunrise != null && widget.currentWeather?.sunset != null)
                      _buildSunriseSunsetInfo(),

                    SizedBox(height: 24.h),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: AppColors.white10,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: AppColors.white20,
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: widget.weeklyWeather.isEmpty
                            ? Center(
                                child: Text(
                                  '주간 날씨 정보가 없습니다',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppConstants.darkPrimaryTextColor,
                                    fontSize: 15.sp, // 크기 증가로 가독성 향상
                                    fontWeight: FontWeight.w500, // 더 강조된 가독성
                                    letterSpacing: 0.3, // 글자 간격 추가
                                    height: 1.3, // 줄 간격 개선
                                  ),
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: widget.weeklyWeather.length,
                                itemBuilder: (context, index) {
                                  final day = widget.weeklyWeather[index];
                                  return _buildWeeklyItem(day, index);
                                },
                              ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyItem(WeeklyWeatherModel day, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.white20,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _getDayName(day.date),
                      style: AppTextStyles.weeklyDay.copyWith(
                        fontSize: 17.sp, // 크기 증가로 가독성 향상
                        fontWeight: FontWeight.w600, // 더 강조된 가독성
                        letterSpacing: 0.3, // 글자 간격 추가
                        height: 1.2, // 줄 간격 개선
                        color: AppConstants.darkPrimaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 날씨 상태 아이콘 추가
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getWeatherIcon(day.weatherType),
                          size: 20.sp,
                          color: AppConstants.darkPrimaryTextColor.withValues(alpha: 0.8),
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            _getWeatherDescription(day.condition),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.darkPrimaryTextColor.withValues(alpha: 0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 기온 대비 더 세련된 그래픽
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.white10,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${day.minTempInCelsius.round()}°',
                                style: AppTextStyles.weeklyTempMin.copyWith(
                                  fontSize: 15.sp, // 크기 증가로 가독성 향상
                                  fontWeight: FontWeight.w500, // 더 강조된 가독성
                                  letterSpacing: 0.2, // 글자 간격 추가
                                  height: 1.2, // 줄 간격 개선
                                  color: AppConstants.darkPrimaryTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 2.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.white20,
                                AppColors.white30,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1.r),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.white20,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${day.maxTempInCelsius.round()}°',
                                style: AppTextStyles.weeklyTemp.copyWith(
                                  fontSize: 15.sp, // 크기 증가로 가독성 향상
                                  fontWeight: FontWeight.w700, // 더 강조된 가독성
                                  letterSpacing: 0.2, // 글자 간격 추가
                                  height: 1.2, // 줄 간격 개선
                                  color: AppConstants.darkPrimaryTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDayName(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  IconData _getWeatherIcon(WeatherType weatherType) {
    switch (weatherType) {
      case WeatherType.sunny:
        return Icons.wb_sunny;
      case WeatherType.cloudy:
        return Icons.cloud;
      case WeatherType.rainy:
        return Icons.water_drop;
      case WeatherType.snowy:
        return Icons.ac_unit;
      case WeatherType.stormy:
        return Icons.thunderstorm;
      case WeatherType.foggy:
        return Icons.foggy;
    }
  }

  String _getWeatherDescription(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '맑음';
      case 'clouds':
        return '흐림';
      case 'rain':
        return '비';
      case 'drizzle':
        return '이슬비';
      case 'snow':
        return '눈';
      case 'thunderstorm':
        return '뇌우';
      case 'mist':
      case 'fog':
        return '안개';
      default:
        return condition;
    }
  }

  Widget _buildSunriseSunsetInfo() {
    if (widget.currentWeather?.sunrise == null || widget.currentWeather?.sunset == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.07),
            Colors.black.withValues(alpha: 0.14),
            Colors.black.withValues(alpha: 0.11),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.white20,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black10,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSunInfo(
              '일출',
              _formatTime(widget.currentWeather!.sunrise!),
              Icons.wb_sunny_outlined,
            ),
            _buildDivider(),
            _buildSunInfo(
              '일몰',
              _formatTime(widget.currentWeather!.sunset!),
              Icons.brightness_3_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunInfo(String label, String time, IconData icon) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppConstants.darkPrimaryTextColor,
            size: 18.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.detailLabel.copyWith(
                fontSize: 11.sp,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w400,
                color: AppConstants.darkPrimaryTextColor,
                height: 1.1),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            time,
            style: AppTextStyles.detailValue.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: AppConstants.darkPrimaryTextColor,
                height: 1.1),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 45.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.white20,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
