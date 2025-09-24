import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../models/location_model.dart';
import '../utils/constants.dart';

class LocationService extends GetxService {
  LocationModel? _currentLocation;

  LocationModel? get currentLocation => _currentLocation;

  // 위치 권한 확인
  Future<bool> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // 위치 서비스 활성화 확인
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // 현재 위치 가져오기
  Future<LocationModel?> getCurrentLocation() async {
    try {
      // 위치 서비스 확인
      if (!await isLocationServiceEnabled()) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }

      // 권한 확인
      if (!await checkPermission()) {
        throw Exception('위치 권한이 거부되었습니다.');
      }

      // 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // 주소 정보 가져오기
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _currentLocation = LocationModel.fromPlacemark(
          latitude: position.latitude,
          longitude: position.longitude,
          locality: place.locality ?? 'Unknown',
          country: place.country ?? 'Unknown',
          administrativeArea: place.administrativeArea,
        );
      } else {
        _currentLocation = LocationModel.fromPosition(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      return _currentLocation;
    } catch (e) {
      print('Location error: $e');
      return null;
    }
  }

  // 캐시된 위치 사용할지 확인
  bool shouldUseCache() {
    if (_currentLocation == null) return false;

    final now = DateTime.now();
    final diff = now.difference(_currentLocation!.updatedAt);

    return diff.inMinutes < AppConstants.locationCacheMinutes;
  }

  // 위치 업데이트 (필요시에만)
  Future<LocationModel?> getLocationWithCache() async {
    if (shouldUseCache()) {
      return _currentLocation;
    }

    return await getCurrentLocation();
  }

  // 특정 좌표의 주소 가져오기
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality}, ${place.country}';
      }

      return 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  // 두 지점 간 거리 계산 (km)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // 위치가 크게 변경되었는지 확인 (10km 이상)
  bool hasLocationChangedSignificantly(LocationModel newLocation) {
    if (_currentLocation == null) return true;

    double distance = calculateDistance(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      newLocation.latitude,
      newLocation.longitude,
    );

    return distance > 10; // 10km 이상 변경시
  }

  // 위치 서비스 초기화
  @override
  void onInit() {
    super.onInit();
    _initLocationService();
  }

  void _initLocationService() {
    // 위치 설정 확인 (API 변경으로 인해 제거)
    // 위치 변경 스트림 설정 (필요시)
    // _setupLocationStream();
  }

}
