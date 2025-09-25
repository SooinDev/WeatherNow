import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/weather_model.dart';
import '../../../utils/text_styles.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';
import '../../../services/weather_service.dart';
import '../../detail/widgets/weather_detail_screen.dart';

class TemperatureDisplay extends StatelessWidget {
  final WeatherModel? weather;
  final bool isCelsius;
  final VoidCallback? onTemperatureUnitToggle;
  final String? weatherType;

  const TemperatureDisplay({
    super.key,
    this.weather,
    this.isCelsius = true,
    this.onTemperatureUnitToggle,
    this.weatherType,
  });

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Opacity(
              opacity: value * 0.6,
              child: Text(
                '--°',
                style: AppTextStyles.temperatureLarge.copyWith(
                  letterSpacing: -0.5,
                  color: AppColors.getAdaptiveTextColor(weatherType ?? 'Clear'),
                ),
              ),
            );
          },
        ),
      );
    }

    final temperature = isCelsius
        ? weather!.temperatureInCelsius
        : (weather!.temperatureInCelsius * 9 / 5) + 32;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final controller = Get.find<AppController>();
        if (controller.currentWeather != null && controller.currentLocation != null) {
          // 추가 날씨 데이터 로드
          final weatherService = Get.find<WeatherService>();

          final hourlyWeather = await weatherService.getHourlyForecast(controller.currentLocation!);
          final airQuality = await weatherService.getAirPollution(controller.currentLocation!);
          final uvIndex = await weatherService.getUVIndex(controller.currentLocation!);

          // 상세 화면 열기
          if (context.mounted) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, _) => WeatherDetailScreen(
                  weather: controller.currentWeather!,
                  hourlyWeather: hourlyWeather,
                  airQuality: airQuality != null ? AirQualityModel.fromJson(airQuality) : null,
                  uvIndex: uvIndex,
                  weatherType: controller.currentWeather!.condition,
                  onClose: () => Navigator.of(context).pop(),
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (context, animation, _, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  );
                },
              ),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // 애니메이션이 적용된 온도 표시
          TweenAnimationBuilder<double>(
            key: ValueKey('${temperature.round()}°'),
            tween: Tween(begin: 0.0, end: temperature),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return GetBuilder<AppController>(
                builder: (controller) => AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 400),
                  style: AppTextStyles.temperatureLarge.copyWith(
                    letterSpacing: -1.0,
                    color: controller.isTextColorChanged
                        ? AppConstants.swipedPrimaryTextColor
                        : AppConstants.darkPrimaryTextColor,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: AppColors.black20,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${animatedValue.round()}°',
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16.h),

          // 애니메이션이 적용된 단위 표시 (탭하면 단위 변경)
          GestureDetector(
            onTap: onTemperatureUnitToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white10,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.white20,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black10,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: GetBuilder<AppController>(
                  builder: (controller) => Text(
                    isCelsius ? '섭씨' : '화씨',
                    key: ValueKey(isCelsius),
                    style: AppTextStyles.temperatureSmall.copyWith(
                      color: controller.isTextColorChanged
                          ? AppConstants.swipedSecondaryTextColor
                          : AppConstants.darkPrimaryTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      height: 1.1
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
