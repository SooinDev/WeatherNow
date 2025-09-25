import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/location_model.dart';
import '../../../utils/text_styles.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';

class LocationDisplay extends StatelessWidget {
  final LocationModel? location;
  final String? weatherType;

  const LocationDisplay({
    super.key,
    this.location,
    this.weatherType,
  });

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.06),
              Colors.black.withValues(alpha: 0.12),
              Colors.black.withValues(alpha: 0.09),
            ],
          ),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: AppColors.white20,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black10,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              color: AppColors.white30,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            GetBuilder<AppController>(
              builder: (controller) => Text(
                '위치 정보 없음',
                style: AppTextStyles.locationPrimary.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  height: 1.2,
                  color: controller.isTextColorChanged
                      ? AppConstants.swipedSecondaryTextColor
                      : AppConstants.darkPrimaryTextColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.1),
            Colors.black.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.15),
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
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            color: AppColors.white30,
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GetBuilder<AppController>(
                  builder: (controller) => AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 600),
                    style: AppTextStyles.locationPrimary.copyWith(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      height: 1.2,
                      color: controller.isTextColorChanged
                          ? AppConstants.swipedPrimaryTextColor
                          : AppConstants.darkPrimaryTextColor,
                    ),
                    child: Text(
                      location!.shortName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                GetBuilder<AppController>(
                  builder: (controller) => AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 600),
                    style: AppTextStyles.locationSecondary.copyWith(
                      fontSize: 14.sp,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      color: controller.isTextColorChanged
                          ? AppConstants.swipedSecondaryTextColor
                          : AppConstants.darkPrimaryTextColor,
                    ),
                    child: Text(
                      location!.country,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
