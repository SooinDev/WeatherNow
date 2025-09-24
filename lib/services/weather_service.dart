import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/weather_model.dart';
import '../models/location_model.dart';
import '../utils/constants.dart';

class WeatherService extends GetxService {
  late Dio _dio;
  WeatherModel? _currentWeather;
  List<WeeklyWeatherModel>? _weeklyWeather;
  DateTime? _lastUpdate;

  WeatherModel? get currentWeather => _currentWeather;
  List<WeeklyWeatherModel>? get weeklyWeather => _weeklyWeather;

  @override
  void onInit() {
    super.onInit();
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.weatherBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 로깅 인터셉터 (개발용)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  // 현재 날씨 가져오기
  Future<WeatherModel?> getCurrentWeather(LocationModel location) async {
    try {
      if (_shouldUseCache()) {
        return _currentWeather;
      }

      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': location.latitude,
          'lon': location.longitude,
          'appid': AppConstants.weatherApiKey,
          'units': 'metric', // 섭씨 온도 사용
        },
      );

      if (response.statusCode == 200) {
        _currentWeather = WeatherModel.fromJson(response.data);
        _lastUpdate = DateTime.now();
        return _currentWeather;
      }

      return null;
    } on DioException catch (e) {
      print('Weather API Error: ${e.message}');
      return null;
    } catch (e) {
      print('Weather Service Error: $e');
      return null;
    }
  }

  // 주간 날씨 가져오기 (5일 예보 사용)
  Future<List<WeeklyWeatherModel>?> getWeeklyWeather(
      LocationModel location) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': location.latitude,
          'lon': location.longitude,
          'appid': AppConstants.weatherApiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> forecastList = response.data['list'];

        // 날짜별로 예보 데이터 그룹핑
        final Map<String, List<dynamic>> dailyForecasts = {};
        for (var forecast in forecastList) {
          final DateTime date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
          final String dateKey = '${date.year}-${date.month}-${date.day}';

          if (!dailyForecasts.containsKey(dateKey)) {
            dailyForecasts[dateKey] = [];
          }
          dailyForecasts[dateKey]!.add(forecast);
        }

        // 각 날짜별로 최고/최저 온도 계산
        _weeklyWeather = dailyForecasts.entries.map((entry) {
          final forecasts = entry.value;

          // 해당 날짜의 모든 온도에서 최고/최저 찾기
          double maxTemp = double.negativeInfinity;
          double minTemp = double.infinity;
          dynamic representativeData = forecasts.first;

          // 12시 데이터가 있으면 대표 데이터로 사용
          for (var forecast in forecasts) {
            final DateTime date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
            final double temp = (forecast['main']['temp'] as num).toDouble();

            if (temp > maxTemp) maxTemp = temp;
            if (temp < minTemp) minTemp = temp;

            if (date.hour == 12) {
              representativeData = forecast;
            }
          }

          // WeeklyWeatherModel 생성 (최고/최저 온도는 계산된 값 사용)
          return WeeklyWeatherModel(
            date: DateTime.fromMillisecondsSinceEpoch(representativeData['dt'] * 1000),
            maxTemp: maxTemp,
            minTemp: minTemp,
            weatherType: _getWeatherTypeFromCondition(representativeData['weather'][0]['main']),
            condition: representativeData['weather'][0]['main'],
          );
        }).toList();

        // 날짜순 정렬
        _weeklyWeather!.sort((a, b) => a.date.compareTo(b.date));

        return _weeklyWeather;
      }

      return null;
    } on DioException catch (e) {
      print('Weekly Weather API Error: ${e.message}');
      return null;
    } catch (e) {
      print('Weekly Weather Service Error: $e');
      return null;
    }
  }

  // 5일 예보 가져오기 (3시간 간격)
  Future<List<WeatherModel>?> getHourlyForecast(LocationModel location) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': location.latitude,
          'lon': location.longitude,
          'appid': AppConstants.weatherApiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> forecastList = response.data['list'];
        return forecastList
            .map((forecast) => WeatherModel.fromJson(forecast))
            .toList();
      }

      return null;
    } on DioException catch (e) {
      print('Hourly Forecast API Error: ${e.message}');
      return null;
    } catch (e) {
      print('Hourly Forecast Service Error: $e');
      return null;
    }
  }

  // UV 인덱스 가져오기 (별도 API)
  Future<double?> getUVIndex(LocationModel location) async {
    try {
      final response = await _dio.get(
        '/uvi',
        queryParameters: {
          'lat': location.latitude,
          'lon': location.longitude,
          'appid': AppConstants.weatherApiKey,
        },
      );

      if (response.statusCode == 200) {
        return (response.data['value'] as num).toDouble();
      }

      return null;
    } catch (e) {
      print('UV Index Error: $e');
      return null;
    }
  }

  // 대기 질 정보 가져오기
  Future<Map<String, dynamic>?> getAirPollution(LocationModel location) async {
    try {
      final response = await _dio.get(
        '/air_pollution',
        queryParameters: {
          'lat': location.latitude,
          'lon': location.longitude,
          'appid': AppConstants.weatherApiKey,
        },
      );

      if (response.statusCode == 200) {
        return response.data['list'][0];
      }

      return null;
    } catch (e) {
      print('Air Pollution Error: $e');
      return null;
    }
  }

  // 캐시 사용 여부 확인
  bool _shouldUseCache() {
    if (_currentWeather == null || _lastUpdate == null) return false;

    final now = DateTime.now();
    final diff = now.difference(_lastUpdate!);

    return diff.inMinutes < AppConstants.weatherCacheMinutes;
  }

  // 날씨 데이터 새로고침
  Future<WeatherModel?> refreshWeather(LocationModel location) async {
    _currentWeather = null;
    _lastUpdate = null;
    return await getCurrentWeather(location);
  }

  // 모든 날씨 데이터 가져오기
  Future<Map<String, dynamic>?> getAllWeatherData(
      LocationModel location) async {
    try {
      final results = await Future.wait([
        getCurrentWeather(location),
        getWeeklyWeather(location),
        getUVIndex(location),
        getAirPollution(location),
      ]);

      return {
        'current': results[0],
        'weekly': results[1],
        'uvIndex': results[2],
        'airPollution': results[3],
      };
    } catch (e) {
      print('Get All Weather Data Error: $e');
      return null;
    }
  }

  // 날씨 아이콘 URL 가져오기
  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  // 날씨 상태에 따른 배경 색상 가져오기
  String getWeatherGradientKey(String weatherType) {
    return AppConstants.weatherGradients[weatherType.toLowerCase()] ??
        AppConstants.weatherGradients['cloudy']!;
  }

  // 온도를 화씨로 변환
  double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  // 풍속을 km/h로 변환 (m/s에서)
  double mpsToKmph(double mps) {
    return mps * 3.6;
  }

  // 풍향을 각도에서 방향으로 변환
  String getWindDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    int index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  // 날씨 상태 한국어 변환
  String getWeatherDescriptionKorean(String englishDescription) {
    const translations = {
      'clear sky': '맑음',
      'few clouds': '구름 조금',
      'scattered clouds': '구름 많음',
      'broken clouds': '흐림',
      'overcast clouds': '구름 많음',
      'light rain': '가벼운 비',
      'moderate rain': '비',
      'heavy rain': '폭우',
      'light snow': '가벼운 눈',
      'snow': '눈',
      'heavy snow': '폭설',
      'mist': '안개',
      'fog': '짙은 안개',
      'thunderstorm': '천둥번개',
    };

    return translations[englishDescription.toLowerCase()] ?? englishDescription;
  }

  // 날씨 상태를 WeatherType으로 변환
  WeatherType _getWeatherTypeFromCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return WeatherType.sunny;
      case 'clouds':
        return WeatherType.cloudy;
      case 'rain':
      case 'drizzle':
        return WeatherType.rainy;
      case 'snow':
        return WeatherType.snowy;
      case 'thunderstorm':
        return WeatherType.stormy;
      case 'mist':
      case 'fog':
        return WeatherType.foggy;
      default:
        return WeatherType.cloudy;
    }
  }
}
