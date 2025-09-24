import 'package:get/get.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AppController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();
  final WeatherService _weatherService = Get.find<WeatherService>();
  late StorageService _storageService;

  // 앱 상태
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // 날씨 데이터
  LocationModel? _currentLocation;
  WeatherModel? _currentWeather;
  List<WeeklyWeatherModel>? _weeklyWeather;

  // UI 상태
  bool _isWeeklyViewVisible = false;
  double _backgroundOpacity = 1.0;
  bool _isTextColorChanged = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  LocationModel? get currentLocation => _currentLocation;
  WeatherModel? get currentWeather => _currentWeather;
  List<WeeklyWeatherModel>? get weeklyWeather => _weeklyWeather;
  bool get isWeeklyViewVisible => _isWeeklyViewVisible;
  double get backgroundOpacity => _backgroundOpacity;
  bool get isTextColorChanged => _isTextColorChanged;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  // 앱 초기화
  Future<void> _initializeApp() async {
    try {
      _isLoading = true;
      _hasError = false;
      update();

      // 저장소 서비스 초기화
      _storageService = StorageService();
      await _storageService.init();

      // 캐시된 데이터 로드
      await _loadCachedData();

      // 현재 위치 가져오기
      await _getCurrentLocation();

      // 날씨 데이터 가져오기
      if (_currentLocation != null) {
        await _getWeatherData();
      }

      _isLoading = false;
      update();
    } catch (e) {
      _handleError('앱 초기화 중 오류가 발생했습니다: $e');
    }
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    try {
      final location = await _locationService.getLocationWithCache();

      if (location != null) {
        _currentLocation = location;
        // 위치 정보 캐시
        await _storageService.saveLocation(location);
        update();
      } else {
        throw Exception(AppStrings.locationError);
      }
    } catch (e) {
      _handleError(AppStrings.locationError);
    }
  }

  // 날씨 데이터 가져오기
  Future<void> _getWeatherData() async {
    if (_currentLocation == null) return;

    try {
      // 현재 날씨
      final weather =
          await _weatherService.getCurrentWeather(_currentLocation!);
      if (weather != null) {
        _currentWeather = weather;
        await _storageService.saveWeather(weather);
      }

      // 주간 날씨
      final weekly = await _weatherService.getWeeklyWeather(_currentLocation!);
      if (weekly != null) {
        _weeklyWeather = weekly;
      }

      update();
    } catch (e) {
      _handleError(AppStrings.weatherError);
    }
  }

  // 캐시된 데이터 로드
  Future<void> _loadCachedData() async {
    try {
      // 마지막 위치 로드
      final cachedLocation = await _storageService.getLastLocation();
      if (cachedLocation != null) {
        _currentLocation = cachedLocation;
      }

      // 마지막 날씨 데이터 로드
      final cachedWeather = await _storageService.getLastWeather();
      if (cachedWeather != null) {
        _currentWeather = cachedWeather;
      }

      update();
    } catch (e) {
      print('캐시 로드 오류: $e');
    }
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    try {
      _hasError = false;
      update();

      // 위치 새로고침
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        _currentLocation = location;
        await _storageService.saveLocation(location);
      }

      // 날씨 데이터 새로고침
      if (_currentLocation != null) {
        final weather = await _weatherService.refreshWeather(_currentLocation!);
        if (weather != null) {
          _currentWeather = weather;
          await _storageService.saveWeather(weather);
        }

        final weekly =
            await _weatherService.getWeeklyWeather(_currentLocation!);
        if (weekly != null) {
          _weeklyWeather = weekly;
        }
      }

      update();
    } catch (e) {
      _handleError('데이터 새로고침 중 오류가 발생했습니다.');
    }
  }

  // 주간 날씨 뷰 토글
  void toggleWeeklyView() {
    if (_isWeeklyViewVisible) return; // 이미 열려있으면 무시

    _isWeeklyViewVisible = true;
    _backgroundOpacity = 0.3;
    _isTextColorChanged = true; // 위로 스와이프 시 텍스트 색상 변경
    update();
  }

  // 주간 날씨 뷰 숨기기
  void hideWeeklyView() {
    if (!_isWeeklyViewVisible) return; // 이미 닫혀있으면 무시

    _isWeeklyViewVisible = false;
    _backgroundOpacity = 1.0;
    _isTextColorChanged = false; // 아래로 스와이프 시 텍스트 색상 원래대로
    update();
  }

  // 배경 투명도 설정
  void setBackgroundOpacity(double opacity) {
    _backgroundOpacity = opacity.clamp(0.0, 1.0);
    update();
  }

  // 오류 처리
  void _handleError(String message) {
    _hasError = true;
    _errorMessage = message;
    _isLoading = false;
    update();
  }

  // 오류 클리어
  void clearError() {
    _hasError = false;
    _errorMessage = '';
    update();
  }

  // 위치 변경 이벤트 핸들러
  void onLocationChanged(LocationModel newLocation) {
    if (_currentLocation == null ||
        _locationService.hasLocationChangedSignificantly(newLocation)) {
      _currentLocation = newLocation;
      _getWeatherData();
    }
  }

  // 온도 단위 변경 (섭씨/화씨)
  bool _isCelsius = true;
  bool get isCelsius => _isCelsius;

  void toggleTemperatureUnit() {
    _isCelsius = !_isCelsius;
    _storageService.saveTemperatureUnit(_isCelsius);
    update();
  }

  // 온도 포맷팅
  String formatTemperature(double temperature) {
    if (_isCelsius) {
      return '${temperature.round()}°';
    } else {
      double fahrenheit = _weatherService.celsiusToFahrenheit(temperature);
      return '${fahrenheit.round()}°';
    }
  }

  // 현재 시간 기반 인사말
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return '좋은 아침이에요';
    } else if (hour >= 12 && hour < 18) {
      return '좋은 오후예요';
    } else if (hour >= 18 && hour < 22) {
      return '좋은 저녁이에요';
    } else {
      return '좋은 밤이에요';
    }
  }

  // 날씨에 따른 추천 메시지
  String getWeatherRecommendation() {
    if (_currentWeather == null) return '';

    switch (_currentWeather!.weatherType) {
      case WeatherType.sunny:
        return '햇빛이 좋은 하루예요';
      case WeatherType.cloudy:
        return '구름이 많은 하루예요';
      case WeatherType.rainy:
        return '우산을 챙기세요';
      case WeatherType.snowy:
        return '눈이 오니 조심하세요';
      case WeatherType.stormy:
        return '실내에 머무르는 것이 좋겠어요';
      case WeatherType.foggy:
        return '시야가 좋지 않으니 주의하세요';
    }
  }

  // 앱 상태 리셋
  void resetAppState() {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    _currentLocation = null;
    _currentWeather = null;
    _weeklyWeather = null;
    _isWeeklyViewVisible = false;
    _backgroundOpacity = 1.0;
    _isTextColorChanged = false;
    update();
  }
}
