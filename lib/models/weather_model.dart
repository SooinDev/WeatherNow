class WeatherModel {
  final String location;
  final String country;
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final double feelsLike;
  final int uvIndex;
  final DateTime updatedAt;
  final WeatherType weatherType;
  final double? pressure;
  final double? visibility;
  final DateTime? sunrise;
  final DateTime? sunset;
  final int? windDegree;
  final String iconCode;

  WeatherModel({
    required this.location,
    required this.country,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.uvIndex,
    required this.updatedAt,
    required this.weatherType,
    this.pressure,
    this.visibility,
    this.sunrise,
    this.sunset,
    this.windDegree,
    required this.iconCode,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: json['name'] ?? 'Unknown',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      uvIndex: 0, // UV 인덱스는 별도 API 호출 필요
      updatedAt: DateTime.now(),
      weatherType: _getWeatherType(json['weather'][0]['main']),
      pressure: (json['main']?['pressure'] as num?)?.toDouble(),
      visibility: (json['visibility'] as num?)?.toDouble(),
      sunrise: json['sys']?['sunrise'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['sys']['sunrise'] as int) * 1000)
          : null,
      sunset: json['sys']?['sunset'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['sys']['sunset'] as int) * 1000)
          : null,
      windDegree: json['wind']?['deg'] as int?,
      iconCode: json['weather'][0]['icon'] ?? '01d',
    );
  }

  static WeatherType _getWeatherType(String condition) {
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

  // 온도를 섭씨로 반환 (이미 metric 단위로 받음)
  double get temperatureInCelsius => temperature;

  // 체감온도를 섭씨로 반환
  double get feelsLikeInCelsius => feelsLike;

  // 풍향을 도수로 반환 (windDegree 필드 사용)
  double? get windDirection => windDegree?.toDouble();
}

enum WeatherType {
  sunny,
  cloudy,
  rainy,
  snowy,
  stormy,
  foggy,
}

class WeeklyWeatherModel {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final WeatherType weatherType;
  final String condition;

  WeeklyWeatherModel({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherType,
    required this.condition,
  });

  factory WeeklyWeatherModel.fromJson(Map<String, dynamic> json) {
    return WeeklyWeatherModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      weatherType: WeatherModel._getWeatherType(json['weather'][0]['main']),
      condition: json['weather'][0]['main'],
    );
  }

  // 온도를 섭씨로 반환 (이미 metric 단위로 받음)
  double get maxTempInCelsius => maxTemp;
  double get minTempInCelsius => minTemp;
}

class HourlyWeatherModel {
  final DateTime time;
  final double temperature;
  final double precipitationProbability;
  final double windSpeed;
  final int humidity;
  final String condition;
  final String iconCode;
  final WeatherType weatherType;

  HourlyWeatherModel({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.humidity,
    required this.condition,
    required this.iconCode,
    required this.weatherType,
  });

  factory HourlyWeatherModel.fromJson(Map<String, dynamic> json) {
    return HourlyWeatherModel(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      precipitationProbability: (json['pop'] as num? ?? 0.0).toDouble() * 100,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      humidity: json['main']['humidity'] as int,
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'] ?? '01d',
      weatherType: WeatherModel._getWeatherType(json['weather'][0]['main']),
    );
  }

  // 온도를 섭씨로 반환
  double get temperatureInCelsius => temperature;
}

class AirQualityModel {
  final int aqi;
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm25;
  final double pm10;
  final double nh3;
  final String qualityLevel;

  AirQualityModel({
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm25,
    required this.pm10,
    required this.nh3,
    required this.qualityLevel,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final components = json['components'];
    final aqi = json['main']['aqi'] as int;

    return AirQualityModel(
      aqi: aqi,
      co: (components['co'] as num).toDouble(),
      no: (components['no'] as num).toDouble(),
      no2: (components['no2'] as num).toDouble(),
      o3: (components['o3'] as num).toDouble(),
      so2: (components['so2'] as num).toDouble(),
      pm25: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
      nh3: (components['nh3'] as num).toDouble(),
      qualityLevel: _getQualityLevel(aqi),
    );
  }

  static String _getQualityLevel(int aqi) {
    switch (aqi) {
      case 1:
        return '매우 좋음';
      case 2:
        return '좋음';
      case 3:
        return '보통';
      case 4:
        return '나쁨';
      case 5:
        return '매우 나쁨';
      default:
        return '알 수 없음';
    }
  }
}
