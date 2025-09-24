class LocationModel {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String? region;
  final DateTime updatedAt;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.region,
    required this.updatedAt,
  });

  factory LocationModel.fromPosition({
    required double latitude,
    required double longitude,
    String city = 'Unknown',
    String country = 'Unknown',
    String? region,
  }) {
    return LocationModel(
      latitude: latitude,
      longitude: longitude,
      city: city,
      country: country,
      region: region,
      updatedAt: DateTime.now(),
    );
  }

  factory LocationModel.fromPlacemark({
    required double latitude,
    required double longitude,
    required String locality,
    required String country,
    String? administrativeArea,
  }) {
    return LocationModel(
      latitude: latitude,
      longitude: longitude,
      city: locality,
      country: country,
      region: administrativeArea,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
      'region': region,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      country: json['country'],
      region: json['region'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get displayName {
    if (region != null && region!.isNotEmpty) {
      return '$city, $region';
    }
    return '$city, $country';
  }

  String get shortName => city;

  @override
  String toString() {
    return 'LocationModel(lat: $latitude, lng: $longitude, city: $city, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.city == city &&
        other.country == country;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^
        longitude.hashCode ^
        city.hashCode ^
        country.hashCode;
  }
}
