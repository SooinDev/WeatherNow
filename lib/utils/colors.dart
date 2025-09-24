import 'package:flutter/material.dart';

class AppColors {
  // 기본 색상 (iOS 스타일)
  static const Color primary = Color(0xFF007AFF);
  static const Color secondary = Color(0xFF34C759);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFF2F2F7);
  static const Color error = Color(0xFFFF3B30);

  // 텍스트 색상 (iOS 스타일)
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textLight = Color(0xFFAEAEB2);
  static const Color textWhite = Colors.white;

  // 날씨별 그라데이션 색상 (더 세련되고 고급스러운 톤)
  static const List<Color> sunnyGradient = [
    Color(0xFFFFF3A5), // 부드러운 크림 옐로우
    Color(0xFFFFB347), // 따뜻한 피치 오렌지
    Color(0xFFFF8C42), // 세련된 선셋 오렌지
  ];

  static const List<Color> cloudyGradient = [
    Color(0xFFF8F9FA), // 매우 부드러운 화이트
    Color(0xFFE9ECEF), // 고급스러운 라이트 그레이
    Color(0xFFCED4DA), // 우아한 미디움 그레이
  ];

  static const List<Color> rainyGradient = [
    Color(0xFF74C0FC), // 부드러운 스카이 블루
    Color(0xFF339AF0), // 깊은 오션 블루
    Color(0xFF1971C2), // 고급스러운 네이비 블루
  ];

  static const List<Color> snowyGradient = [
    Color(0xFFFFFBFF), // 순수한 화이트
    Color(0xFFF1F3F4), // 아이시 화이트
    Color(0xFFE8EAED), // 소프트 실버
  ];

  static const List<Color> stormyGradient = [
    Color(0xFF6C757D), // 세련된 스톰 그레이
    Color(0xFF495057), // 깊은 차콜
    Color(0xFF212529), // 고급스러운 블랙
  ];

  static const List<Color> foggyGradient = [
    Color(0xFFF8F9FA), // 미스티 화이트
    Color(0xFFE9ECEF), // 포그 그레이
    Color(0xFFDEE2E6), // 소프트 미스트
  ];

  // 시간대별 그라데이션 (고급스러운 톤)
  static const List<Color> morningGradient = [
    Color(0xFFFFF2CC), // 부드러운 모닝 골드
    Color(0xFFFFE066), // 따뜻한 선라이즈
    Color(0xFFFFCC02), // 생동감 있는 골든
  ];

  static const List<Color> afternoonGradient = [
    Color(0xFF87CEEB), // 부드러운 스카이 블루
    Color(0xFF4FC3F7), // 밝은 애프터눈 블루
    Color(0xFF29B6F6), // 생동감 있는 블루
  ];

  static const List<Color> eveningGradient = [
    Color(0xFFFFB74D), // 따뜻한 이브닝 골드
    Color(0xFFFF8A65), // 부드러운 선셋 오렌지
    Color(0xFFFF7043), // 로맨틱 코랄
  ];

  static const List<Color> nightGradient = [
    Color(0xFF7E57C2), // 신비로운 퍼플
    Color(0xFF5C6BC0), // 깊은 나이트 블루
    Color(0xFF3F51B5), // 고급스러운 미드나이트
  ];

  // 투명도가 있는 색상
  static Color white10 = Colors.white.withValues(alpha: 0.1);
  static Color white20 = Colors.white.withValues(alpha: 0.2);
  static Color white30 = Colors.white.withValues(alpha: 0.3);
  static Color white40 = Colors.white.withValues(alpha: 0.4);
  static Color white50 = Colors.white.withValues(alpha: 0.5);
  static Color white60 = Colors.white.withValues(alpha: 0.6);
  static Color white70 = Colors.white.withValues(alpha: 0.7);
  static Color white80 = Colors.white.withValues(alpha: 0.8);
  static Color white90 = Colors.white.withValues(alpha: 0.9);
  static Color black10 = Colors.black.withValues(alpha: 0.1);
  static Color black20 = Colors.black.withValues(alpha: 0.2);
  static Color black30 = Colors.black.withValues(alpha: 0.3);

  // 시간에 따른 그라데이션 반환
  static List<Color> getTimeBasedGradient() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return morningGradient; // 아침
    } else if (hour >= 12 && hour < 18) {
      return afternoonGradient; // 오후
    } else if (hour >= 18 && hour < 21) {
      return eveningGradient; // 저녁
    } else {
      return nightGradient; // 밤
    }
  }

  // 날씨에 따른 그라데이션 반환
  static List<Color> getWeatherGradient(String weatherType) {
    switch (weatherType.toLowerCase()) {
      case 'clear':
        return sunnyGradient;
      case 'clouds':
        return cloudyGradient;
      case 'rain':
      case 'drizzle':
        return rainyGradient;
      case 'snow':
        return snowyGradient;
      case 'thunderstorm':
        return stormyGradient;
      case 'mist':
      case 'fog':
        return foggyGradient;
      default:
        return getTimeBasedGradient();
    }
  }

  // 날씨와 시간을 조합한 그라데이션 반환
  static List<Color> getCombinedGradient(String weatherType) {
    final weatherColors = getWeatherGradient(weatherType);
    final timeColors = getTimeBasedGradient();

    // 날씨 색상과 시간 색상을 블렌딩하고 약간 어둡게 처리
    return [
      (Color.lerp(weatherColors[0], timeColors[0], 0.7) ?? weatherColors[0]).withValues(alpha: 0.85),
      (Color.lerp(weatherColors[1], timeColors[1], 0.7) ?? weatherColors[1]).withValues(alpha: 0.9),
      (Color.lerp(weatherColors[2], timeColors[2], 0.7) ?? weatherColors[2]).withValues(alpha: 0.95),
    ];
  }

  // 배경 밝기를 기반으로 최적의 텍스트 색상 반환
  static Color getAdaptiveTextColor(String weatherType, {String textType = 'primary'}) {
    final isDarkBackground = _isDarkBackground(weatherType);

    switch (textType) {
      case 'secondary':
        return isDarkBackground
          ? const Color(0xFFE8E8E8) // 밝은 보조 텍스트
          : const Color(0xFF4A4A4A); // 어두운 보조 텍스트
      case 'accent':
        return isDarkBackground
          ? const Color(0xFFD0D0D0) // 밝은 강조 텍스트
          : const Color(0xFF666666); // 어두운 강조 텍스트
      default: // primary
        return isDarkBackground
          ? const Color(0xFFFFFFFF) // 밝은 주요 텍스트
          : const Color(0xFF1A1A1A); // 어두운 주요 텍스트
    }
  }

  // 배경이 어두운지 판별하는 헬퍼 메서드
  static bool _isDarkBackground(String weatherType) {
    final hour = DateTime.now().hour;

    // 밤 시간 (19:00 - 05:59)이면 대부분 어두운 배경
    if (hour >= 19 || hour < 6) {
      return true;
    }

    // 날씨 타입에 따른 판별
    switch (weatherType.toLowerCase()) {
      case 'thunderstorm': // 폭풍우는 항상 어두움
        return true;
      case 'rain':
      case 'drizzle': // 비는 중간 정도의 어두움, 시간에 따라 조정
        return hour < 7 || hour > 18;
      case 'clear': // 맑은 날씨
      case 'clouds': // 흐린 날씨
      case 'snow': // 눈
      case 'mist':
      case 'fog': // 안개
        return false; // 대체로 밝은 배경
      default:
        return hour >= 19 || hour < 6; // 기본적으로 시간 기준
    }
  }

  // 시간에 따른 텍스트 색상 반환 (하위 호환성을 위해 유지)
  static Color getTimeBasedTextColor() {
    return textPrimary; // 항상 기본 검정색 텍스트 사용
  }

  // 적응형 텍스트 색상에 투명도 적용
  static Color getAdaptiveTextColorWithOpacity(String weatherType, double opacity, {String textType = 'primary'}) {
    return getAdaptiveTextColor(weatherType, textType: textType).withValues(alpha: opacity);
  }

  // 시간에 따른 투명도 적용된 텍스트 색상들 (하위 호환성)
  static Color getTimeBasedTextColor10() => getTimeBasedTextColor().withValues(alpha: 0.1);
  static Color getTimeBasedTextColor20() => getTimeBasedTextColor().withValues(alpha: 0.2);
  static Color getTimeBasedTextColor30() => getTimeBasedTextColor().withValues(alpha: 0.3);
  static Color getTimeBasedTextColor40() => getTimeBasedTextColor().withValues(alpha: 0.4);
  static Color getTimeBasedTextColor50() => getTimeBasedTextColor().withValues(alpha: 0.5);
  static Color getTimeBasedTextColor60() => getTimeBasedTextColor().withValues(alpha: 0.6);
  static Color getTimeBasedTextColor70() => getTimeBasedTextColor().withValues(alpha: 0.7);
  static Color getTimeBasedTextColor80() => getTimeBasedTextColor().withValues(alpha: 0.8);
  static Color getTimeBasedTextColor90() => getTimeBasedTextColor().withValues(alpha: 0.9);
}
