import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API 키 (환경변수에서 로드)
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static String get weatherBaseUrl => dotenv.env['WEATHER_BASE_URL'] ?? 'https://api.openweathermap.org/data/2.5';

  // 애니메이션 시간
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // 제스처 감도
  static const double swipeThreshold = 100.0;
  static const double swipeVelocityThreshold = 300.0;

  // 캐시 시간 (분)
  static const int weatherCacheMinutes = 10;
  static const int locationCacheMinutes = 60;

  // UI 상수
  static const double borderRadius = 24.0;
  static const double cardElevation = 8.0;
  static const double iconSize = 120.0;

  // 색상 상수 (통일된 텍스트 색상)
  // 모든 텍스트에 사용할 통일된 색상 - 흰색으로 변경
  static const Color darkPrimaryTextColor = Color(0xFFFFFFFF); // 흰색
  static const Color darkSecondaryTextColor = Color(0xFFFFFFFF); // 흰색
  static const Color darkAccentTextColor = Color(0xFFFFFFFF); // 흰색

  // 어두운 배경용도 동일한 색상 적용
  static const Color lightPrimaryTextColor = Color(0xFFFFFFFF); // 흰색
  static const Color lightSecondaryTextColor = Color(0xFFFFFFFF); // 흰색
  static const Color lightAccentTextColor = Color(0xFFFFFFFF); // 흰색

  // 스와이프 후 변경될 밝은 텍스트 색상
  static const Color swipedPrimaryTextColor = Color(0xFFFFFFFF); // 밝은 흰색
  static const Color swipedSecondaryTextColor = Color(0xFFF5F5F5); // 연한 흰색
  static const Color swipedAccentTextColor = Color(0xFFE0E0E0); // 회색빛 흰색

  // 그라데이션 색상 키
  static const Map<String, String> weatherGradients = {
    'sunny': 'sunny_gradient',
    'cloudy': 'cloudy_gradient',
    'rainy': 'rainy_gradient',
    'snowy': 'snowy_gradient',
    'stormy': 'stormy_gradient',
    'foggy': 'foggy_gradient',
  };

  // 날씨별 아이콘
  static const Map<String, String> weatherIcons = {
    'Clear': '☀️',
    'Clouds': '☁️',
    'Rain': '🌧️',
    'Drizzle': '🌦️',
    'Snow': '❄️',
    'Thunderstorm': '⛈️',
    'Mist': '🌫️',
    'Fog': '🌫️',
  };

  // SharedPreferences 키
  static const String keyLastLocation = 'last_location';
  static const String keyLastWeather = 'last_weather';
  static const String keyLastUpdate = 'last_update';
  static const String keyTemperatureUnit = 'temperature_unit';
}

class AppStrings {
  // 일반
  static const String appName = 'Weather Minimal';
  static const String loading = '날씨 정보를 가져오는 중...';
  static const String retry = '다시 시도';
  static const String settings = '설정';

  // 오류 메시지
  static const String locationError = '위치 정보를 가져올 수 없습니다.';
  static const String weatherError = '날씨 정보를 가져올 수 없습니다.';
  static const String networkError = '인터넷 연결을 확인해주세요.';
  static const String permissionError = '위치 권한이 필요합니다.';

  // 날씨 설명
  static const Map<String, String> weatherDescriptions = {
    'Clear': '맑음',
    'Clouds': '흐림',
    'Rain': '비',
    'Drizzle': '이슬비',
    'Snow': '눈',
    'Thunderstorm': '천둥번개',
    'Mist': '안개',
    'Fog': '짙은 안개',
  };

  // 요일
  static const List<String> weekdays = [
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
    '일요일'
  ];

  // 월
  static const List<String> months = [
    '1월',
    '2월',
    '3월',
    '4월',
    '5월',
    '6월',
    '7월',
    '8월',
    '9월',
    '10월',
    '11월',
    '12월'
  ];
}
