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
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: json['name'] ?? 'Unknown',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      uvIndex: 0, // UV 인덱스는 별도 API 호출 필요
      updatedAt: DateTime.now(),
      weatherType: _getWeatherType(json['weather'][0]['main']),
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
