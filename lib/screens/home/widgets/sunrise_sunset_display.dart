import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';
import '../../../models/weather_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/text_styles.dart';
import '../../../utils/colors.dart';
import 'package:intl/intl.dart';

class SunriseSunsetDisplay extends StatelessWidget {
  final WeatherModel weather;

  const SunriseSunsetDisplay({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    if (weather.sunrise == null || weather.sunset == null) {
      return const SizedBox.shrink();
    }

    return GetBuilder<AppController>(
      builder: (controller) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
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
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSunInfo(
                  '일출',
                  _formatTime(weather.sunrise!),
                  Icons.wb_sunny_outlined,
                  controller,
                ),
                _buildDivider(),
                _buildSunInfo(
                  '일몰',
                  _formatTime(weather.sunset!),
                  Icons.brightness_3_outlined,
                  controller,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSunInfo(
      String label, String time, IconData icon, AppController controller) {
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
              size: 16.sp,
            ),
            SizedBox(height: 8.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.detailLabel.copyWith(
                    fontSize: 11.sp,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w400,
                    color: controller.isTextColorChanged
                        ? AppConstants.swipedAccentTextColor
                        : AppConstants.darkPrimaryTextColor,
                    height: 1.1),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                time,
                style: AppTextStyles.detailValue.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: controller.isTextColorChanged
                        ? AppConstants.swipedPrimaryTextColor
                        : AppConstants.darkPrimaryTextColor,
                    height: 1.1),
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
      height: 50.h,
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