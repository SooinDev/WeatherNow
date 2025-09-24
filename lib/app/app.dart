import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/widgets/home_screen.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

class WeatherMainApp extends StatefulWidget {
  const WeatherMainApp({super.key});

  @override
  State<WeatherMainApp> createState() => _WeatherMainAppState();
}

class _WeatherMainAppState extends State<WeatherMainApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    // 의존성 주입
    Get.put(LocationService());
    Get.put(WeatherService());
    Get.put(AppController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const SplashScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
