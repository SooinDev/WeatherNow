import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/text_styles.dart';
import '../../../utils/constants.dart';
import 'gradient_background.dart';
import 'weather_animation.dart';
import 'temperature_display.dart';
import 'location_display.dart';
import 'gesture_handler.dart';
import '../../weekly/widgets/weekly_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AppController>(
        builder: (controller) {
          if (controller.hasError) {
            return _buildErrorView(controller);
          }

          return Stack(
            children: [
              // 그라데이션 배경
              GradientBackground(
                weatherType: controller.currentWeather?.condition ?? 'Clear',
                opacity: controller.backgroundOpacity,
              ),

              // 날씨 애니메이션 (배경)
              if (controller.currentWeather != null)
                WeatherAnimation(
                  weatherType: controller.currentWeather!.weatherType,
                  opacity: controller.backgroundOpacity,
                ),

              // 메인 컨텐츠
              SafeArea(
                child: GestureHandler(
                  onSwipeUp: () {
                    if (!controller.isWeeklyViewVisible) {
                      controller.toggleWeeklyView();
                    }
                  },
                  onSwipeDown: () {
                    if (controller.isWeeklyViewVisible) {
                      controller.hideWeeklyView();
                    }
                  },
                  onRefresh: () => controller.refreshData(),
                  child: _buildMainContent(controller),
                ),
              ),

              // 주간 날씨 오버레이 - 전체 화면을 덮음
              if (controller.isWeeklyViewVisible)
                Positioned.fill(
                  child: WeeklyScreen(
                    onClose: () => controller.hideWeeklyView(),
                    weeklyWeather: controller.weeklyWeather ?? [],
                    weatherType: controller.currentWeather?.condition ?? 'Clear',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(AppController controller) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // 상단 여백 (iOS 스타일)
          SizedBox(height: 20.h),

          // 위치 정보
          LocationDisplay(
            location: controller.currentLocation,
            weatherType: controller.currentWeather?.condition ?? 'Clear',
          ),

          SizedBox(height: 30.h),

          // 메인 온도 영역 (화면의 중앙 차지)
          Expanded(
            flex: 3,
            child: Center(
              child: TemperatureDisplay(
                weather: controller.currentWeather,
                isCelsius: controller.isCelsius,
                onTemperatureUnitToggle: () =>
                    controller.toggleTemperatureUnit(),
                weatherType: controller.currentWeather?.condition ?? 'Clear',
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // 추가 정보 영역
          SizedBox(
            height: 120.h,
            child: _buildAdditionalInfo(controller),
          ),

          SizedBox(height: 30.h),

          // 하단 힌트
          _buildBottomHint(),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(AppController controller) {
    if (controller.currentWeather == null) {
      return const SizedBox.shrink();
    }

    final weather = controller.currentWeather!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(24.r),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // 날씨 설명
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: AppTextStyles.weatherDescription.copyWith(
              fontSize: 13.sp,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w400,
              color: controller.isTextColorChanged
                  ? AppConstants.swipedPrimaryTextColor
                  : AppConstants.darkPrimaryTextColor,
              height: 1.2
            ),
            child: Text(
              weather.description.toUpperCase(),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 16.h),

          // 상세 정보 행
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherDetail(
                  '체감',
                  '${weather.feelsLikeInCelsius.round()}°',
                  Icons.thermostat_outlined,
                  controller,
                ),
                _buildDivider(),
                _buildWeatherDetail(
                  '습도',
                  '${weather.humidity}%',
                  Icons.water_drop_outlined,
                  controller,
                ),
                _buildDivider(),
                _buildWeatherDetail(
                  '바람',
                  '${weather.windSpeed.round()}m/s',
                  Icons.air,
                  controller,
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon, AppController controller) {
    return Flexible(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: controller.isTextColorChanged
                  ? AppConstants.swipedSecondaryTextColor
                  : AppConstants.darkPrimaryTextColor,
              size: 14.sp,
            ),
            SizedBox(height: 6.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.detailLabel.copyWith(
                  fontSize: 10.sp,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w400,
                  color: controller.isTextColorChanged
                      ? AppConstants.swipedAccentTextColor
                      : AppConstants.darkPrimaryTextColor,
                  height: 1.1
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 3.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.detailValue.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: controller.isTextColorChanged
                      ? AppConstants.swipedPrimaryTextColor
                      : AppConstants.darkPrimaryTextColor,
                  height: 1.1
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40.h,
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

  Widget _buildBottomHint() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: AppColors.white20,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black10,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -5 * (1 - value)),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: AppColors.white30.withValues(alpha: 0.6 + (0.4 * value)),
                  size: 14.sp,
                ),
              );
            },
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: GetBuilder<AppController>(
              builder: (controller) => Text(
                '위로 스와이프하여 주간 날씨 보기',
                style: AppTextStyles.caption.copyWith(
                  color: controller.isTextColorChanged
                      ? AppConstants.swipedAccentTextColor
                      : AppConstants.darkPrimaryTextColor,
                  fontSize: 12.sp,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                  height: 1.2
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(AppController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.cloudyGradient,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppConstants.darkPrimaryTextColor,
                ),
                SizedBox(height: 24.h),
                Text(
                  '오류가 발생했습니다',
                  style: AppTextStyles.sectionHeader.copyWith(
                    color: AppConstants.darkPrimaryTextColor,
                    fontSize: 22.sp, // 크기 증가로 가독성 향상
                    letterSpacing: 0.5, // 글자 간격 추가
                    height: 1.2, // 줄 간격 개선
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppConstants.darkPrimaryTextColor,
                    fontSize: 15.sp, // 크기 증가로 가독성 향상
                    letterSpacing: 0.3, // 글자 간격 추가
                    height: 1.4, // 줄 간격 개선
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                SizedBox(height: 40.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: AppConstants.darkPrimaryTextColor,
                      width: 1,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      controller.clearError();
                      controller.refreshData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white10,
                      foregroundColor: AppConstants.darkPrimaryTextColor,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 18.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                    ),
                    child: Text(
                      '다시 시도',
                      style: AppTextStyles.buttonText.copyWith(
                        fontWeight: FontWeight.w700, // 더 강조된 가독성
                        letterSpacing: 1.0, // 글자 간격 확대
                        height: 1.2, // 줄 간격 개선
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
