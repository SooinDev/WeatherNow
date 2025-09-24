import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'constants.dart';

class AppTextStyles {
  // 기본 폰트 패밀리 (iOS 스타일)
  static TextStyle get _baseStyle => GoogleFonts.inter();

  // 대형 온도 표시용 (iOS 스타일)
  static TextStyle get temperatureLarge => _baseStyle.copyWith(
        fontSize: 100.sp,
        fontWeight: FontWeight.w300, // 더 읽기 쉬운 두께
        color: AppConstants.darkPrimaryTextColor,
        height: 1.0, // 가독성을 위한 줄 간격 조정
        letterSpacing: -2.0, // 글자 간격 완화
        shadows: [
          Shadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: AppColors.textPrimary.withValues(alpha: 0.15),
          ),
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 20,
            color: AppColors.textPrimary.withValues(alpha: 0.05),
          ),
        ],
      );

  // 중간 크기 온도
  static TextStyle get temperatureMedium => _baseStyle.copyWith(
        fontSize: 64.sp,
        fontWeight: FontWeight.w400, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        height: 1.0, // 줄 간격 개선
        letterSpacing: -1.0, // 글자 간격 완화
      );

  // 작은 온도
  static TextStyle get temperatureSmall => _baseStyle.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500, // 더 명확한 가독성
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.2, // 글자 간격 추가
        height: 1.2, // 줄 간격 개선
      );

  // 위치 표시 (iOS 스타일)
  static TextStyle get locationPrimary => _baseStyle.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600, // 더 강조된 가독성
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.5, // 글자 간격 확대
        shadows: [
          Shadow(
            offset: const Offset(0, 1),
            blurRadius: 4,
            color: AppColors.textPrimary.withValues(alpha: 0.2),
          ),
          Shadow(
            offset: const Offset(0, 0),
            blurRadius: 12,
            color: AppColors.textPrimary.withValues(alpha: 0.1),
          ),
        ],
      );

  static TextStyle get locationSecondary => _baseStyle.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.4, // 글자 간격 확대
        height: 1.3, // 줄 간격 추가
        shadows: [
          Shadow(
            offset: const Offset(0, 1),
            blurRadius: 3,
            color: AppColors.textPrimary.withValues(alpha: 0.15),
          ),
        ],
      );

  // 날씨 설명
  static TextStyle get weatherDescription => _baseStyle.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w400, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.8, // 글자 간격 확대
        height: 1.4, // 줄 간격 추가
        shadows: [
          Shadow(
            offset: const Offset(0, 1),
            blurRadius: 3,
            color: AppColors.textPrimary.withValues(alpha: 0.15),
          ),
        ],
      );

  // 상세 정보
  static TextStyle get detailLabel => _baseStyle.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 1.2, // 글자 간격 확대
        height: 1.3, // 줄 간격 추가
        shadows: [
          Shadow(
            offset: const Offset(0, 1),
            blurRadius: 2,
            color: AppColors.textPrimary.withValues(alpha: 0.15),
          ),
        ],
      );

  static TextStyle get detailValue => _baseStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600, // 더 강조된 가독성
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.3, // 글자 간격 추가
        height: 1.2, // 줄 간격 개선
        shadows: [
          Shadow(
            offset: const Offset(0, 1),
            blurRadius: 3,
            color: AppColors.textPrimary.withValues(alpha: 0.2),
          ),
        ],
      );

  // 주간 날씨용
  static TextStyle get weeklyDay => _baseStyle.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.5, // 글자 간격 추가
        height: 1.3, // 줄 간격 개선
      );

  static TextStyle get weeklyTemp => _baseStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700, // 더 강조
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.3, // 글자 간격 추가
        height: 1.2, // 줄 간격 개선
      );

  static TextStyle get weeklyTempMin => _baseStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.3, // 글자 간격 추가
        height: 1.2, // 줄 간격 개선
      );

  // 에러 메시지
  static TextStyle get errorMessage => _baseStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.3, // 글자 간격 추가
        height: 1.4, // 줄 간격 개선
      );

  // 로딩 텍스트
  static TextStyle get loadingText => _baseStyle.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w400, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.5, // 글자 간격 추가
        height: 1.3, // 줄 간격 개선
      );

  // 버튼 텍스트
  static TextStyle get buttonText => _baseStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600, // 더 강조된 가독성
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.8, // 글자 간격 확대
        height: 1.2, // 줄 간격 개선
      );

  // 시간 표시
  static TextStyle get timeText => _baseStyle.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.3, // 글자 간격 추가
        height: 1.2, // 줄 간격 개선
      );

  // 앱 타이틀
  static TextStyle get appTitle => _baseStyle.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.5,
      );

  // 섹션 헤더
  static TextStyle get sectionHeader => _baseStyle.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppConstants.darkPrimaryTextColor,
      );

  // 바디 텍스트
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: AppConstants.darkPrimaryTextColor,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppConstants.darkPrimaryTextColor,
        height: 1.4,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppConstants.darkPrimaryTextColor,
        height: 1.3,
      );

  // 캡션
  static TextStyle get caption => _baseStyle.copyWith(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 0.5,
      );

  // 미니멀한 스타일을 위한 특별한 스타일들
  static TextStyle get minimal => _baseStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w300, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 1.8, // 글자 간격 조정
        height: 1.4, // 줄 간격 추가
      );

  static TextStyle get elegant => _baseStyle.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w400, // 가독성 향상
        color: AppConstants.darkPrimaryTextColor,
        letterSpacing: 1.2, // 글자 간격 조정
        height: 1.5, // 줄 간격 조정
      );

  // 애니메이션용 스타일 (투명도 변화)
  static TextStyle fadeIn(TextStyle baseStyle, double opacity) {
    return baseStyle.copyWith(
      color: baseStyle.color?.withValues(alpha: opacity),
    );
  }
}
