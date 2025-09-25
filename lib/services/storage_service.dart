import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../utils/constants.dart';

class StorageService {
  SharedPreferences? _prefs;

  // 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 마지막 위치 저장
  Future<bool> saveLocation(LocationModel location) async {
    try {
      final locationJson = json.encode(location.toJson());
      return await _prefs!
          .setString(AppConstants.keyLastLocation, locationJson);
    } catch (e) {
      print('Location save error: $e');
      return false;
    }
  }

  // 마지막 위치 가져오기
  Future<LocationModel?> getLastLocation() async {
    try {
      final locationJson = _prefs!.getString(AppConstants.keyLastLocation);
      if (locationJson != null) {
        final locationMap = json.decode(locationJson);
        return LocationModel.fromJson(locationMap);
      }
      return null;
    } catch (e) {
      print('Location load error: $e');
      return null;
    }
  }

  // 날씨 데이터 저장
  Future<bool> saveWeather(WeatherModel weather) async {
    try {
      final weatherData = {
        'location': weather.location,
        'country': weather.country,
        'temperature': weather.temperature,
        'condition': weather.condition,
        'description': weather.description,
        'humidity': weather.humidity,
        'windSpeed': weather.windSpeed,
        'feelsLike': weather.feelsLike,
        'uvIndex': weather.uvIndex,
        'updatedAt': weather.updatedAt.toIso8601String(),
        'weatherType': weather.weatherType.toString(),
        'pressure': weather.pressure,
        'visibility': weather.visibility,
        'sunrise': weather.sunrise?.toIso8601String(),
        'sunset': weather.sunset?.toIso8601String(),
        'windDegree': weather.windDegree,
        'iconCode': weather.iconCode,
      };

      final weatherJson = json.encode(weatherData);
      final result =
          await _prefs!.setString(AppConstants.keyLastWeather, weatherJson);

      // 업데이트 시간도 별도 저장
      await _prefs!.setString(
          AppConstants.keyLastUpdate, DateTime.now().toIso8601String());

      return result;
    } catch (e) {
      print('Weather save error: $e');
      return false;
    }
  }

  // 날씨 데이터 가져오기
  Future<WeatherModel?> getLastWeather() async {
    try {
      final weatherJson = _prefs!.getString(AppConstants.keyLastWeather);
      if (weatherJson != null) {
        final weatherMap = json.decode(weatherJson);

        // WeatherType enum 변환
        WeatherType weatherType = WeatherType.cloudy;
        final weatherTypeString = weatherMap['weatherType'];
        if (weatherTypeString != null) {
          weatherType = WeatherType.values.firstWhere(
            (e) => e.toString() == weatherTypeString,
            orElse: () => WeatherType.cloudy,
          );
        }

        return WeatherModel(
          location: weatherMap['location'],
          country: weatherMap['country'],
          temperature: weatherMap['temperature'],
          condition: weatherMap['condition'],
          description: weatherMap['description'],
          humidity: weatherMap['humidity'],
          windSpeed: weatherMap['windSpeed'],
          feelsLike: weatherMap['feelsLike'],
          uvIndex: weatherMap['uvIndex'],
          updatedAt: DateTime.parse(weatherMap['updatedAt']),
          weatherType: weatherType,
          pressure: weatherMap['pressure'],
          visibility: weatherMap['visibility'],
          sunrise: weatherMap['sunrise'] != null ? DateTime.parse(weatherMap['sunrise']) : null,
          sunset: weatherMap['sunset'] != null ? DateTime.parse(weatherMap['sunset']) : null,
          windDegree: weatherMap['windDegree'],
          iconCode: weatherMap['iconCode'] ?? '01d',
        );
      }
      return null;
    } catch (e) {
      print('Weather load error: $e');
      return null;
    }
  }

  // 마지막 업데이트 시간 가져오기
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final timeString = _prefs!.getString(AppConstants.keyLastUpdate);
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
      return null;
    } catch (e) {
      print('Last update time load error: $e');
      return null;
    }
  }

  // 온도 단위 저장
  Future<bool> saveTemperatureUnit(bool isCelsius) async {
    try {
      return await _prefs!.setBool(AppConstants.keyTemperatureUnit, isCelsius);
    } catch (e) {
      print('Temperature unit save error: $e');
      return false;
    }
  }

  // 온도 단위 가져오기
  bool getTemperatureUnit() {
    try {
      return _prefs!.getBool(AppConstants.keyTemperatureUnit) ??
          true; // 기본값: 섭씨
    } catch (e) {
      print('Temperature unit load error: $e');
      return true;
    }
  }

  // 사용자 설정 저장
  Future<bool> saveUserSetting(String key, dynamic value) async {
    try {
      if (value is String) {
        return await _prefs!.setString(key, value);
      } else if (value is int) {
        return await _prefs!.setInt(key, value);
      } else if (value is double) {
        return await _prefs!.setDouble(key, value);
      } else if (value is bool) {
        return await _prefs!.setBool(key, value);
      } else {
        return await _prefs!.setString(key, json.encode(value));
      }
    } catch (e) {
      print('User setting save error: $e');
      return false;
    }
  }

  // 사용자 설정 가져오기
  T? getUserSetting<T>(String key, [T? defaultValue]) {
    try {
      if (T == String) {
        return _prefs!.getString(key) as T? ?? defaultValue;
      } else if (T == int) {
        return _prefs!.getInt(key) as T? ?? defaultValue;
      } else if (T == double) {
        return _prefs!.getDouble(key) as T? ?? defaultValue;
      } else if (T == bool) {
        return _prefs!.getBool(key) as T? ?? defaultValue;
      } else {
        final jsonString = _prefs!.getString(key);
        if (jsonString != null) {
          return json.decode(jsonString) as T;
        }
        return defaultValue;
      }
    } catch (e) {
      print('User setting load error: $e');
      return defaultValue;
    }
  }

  // 데이터 삭제
  Future<bool> removeData(String key) async {
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      print('Data remove error: $e');
      return false;
    }
  }

  // 모든 데이터 삭제
  Future<bool> clearAllData() async {
    try {
      return await _prefs!.clear();
    } catch (e) {
      print('Clear all data error: $e');
      return false;
    }
  }

  // 캐시된 데이터가 유효한지 확인
  Future<bool> isCacheValid(String key, int validMinutes) async {
    try {
      final lastUpdateString = _prefs!.getString('${key}_timestamp');
      if (lastUpdateString != null) {
        final lastUpdate = DateTime.parse(lastUpdateString);
        final now = DateTime.now();
        final diff = now.difference(lastUpdate);
        return diff.inMinutes < validMinutes;
      }
      return false;
    } catch (e) {
      print('Cache validity check error: $e');
      return false;
    }
  }

  // 캐시 타임스탬프 저장
  Future<bool> saveCacheTimestamp(String key) async {
    try {
      return await _prefs!
          .setString('${key}_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      print('Cache timestamp save error: $e');
      return false;
    }
  }
}
