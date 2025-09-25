import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/weather_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/text_styles.dart';
import '../../home/widgets/charts/temperature_chart.dart';
import '../../home/widgets/charts/precipitation_chart.dart';
import '../../home/widgets/charts/wind_compass.dart';
import '../../home/widgets/gradient_background.dart';
import '../../home/widgets/weather_animation.dart';

class WeatherDetailScreen extends StatefulWidget {
  final VoidCallback onClose;
  final WeatherModel? weather;
  final List<HourlyWeatherModel>? hourlyWeather;
  final AirQualityModel? airQuality;
  final double? uvIndex;
  final String weatherType;

  const WeatherDetailScreen({
    super.key,
    required this.onClose,
    this.weather,
    this.hourlyWeather,
    this.airQuality,
    this.uvIndex,
    required this.weatherType,
  });

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isAtTop = _scrollController.offset <= 0;
    if (_isAtTop != isAtTop) {
      setState(() {
        _isAtTop = isAtTop;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // 스크롤이 맨 위에 있을 때만 아래로 드래그하면 닫기
        if (_isAtTop && details.delta.dy > 5) {
          widget.onClose();
        }
      },
      child: Stack(
        children: [
          // 메인화면과 동일한 배경 적용
          GradientBackground(
            weatherType: widget.weatherType,
            opacity: 1.0,
          ),

          // 날씨 애니메이션 (메인화면과 동일)
          WeatherAnimation(
            weatherType: _getWeatherType(widget.weatherType),
            opacity: 1.0,
          ),

          // 메인 컨텐츠
          SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),

              // 스크롤 가능한 컨텐츠
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                    children: [
                      // 추가 날씨 정보
                      if (widget.weather != null) _buildExtendedWeatherInfo(),

                      // 24시간 온도 차트
                      if (widget.hourlyWeather != null && widget.hourlyWeather!.isNotEmpty)
                        _buildChartSection(
                          TemperatureChart(
                            hourlyWeather: widget.hourlyWeather!,
                            isCelsius: true,
                          ),
                        ),

                      // 강수 확률 차트
                      if (widget.hourlyWeather != null && widget.hourlyWeather!.isNotEmpty)
                        _buildChartSection(
                          PrecipitationChart(
                            hourlyWeather: widget.hourlyWeather!,
                          ),
                        ),

                      // 바람 나침반
                      if (widget.weather != null)
                        _buildChartSection(
                          WindCompass(weather: widget.weather!),
                        ),

                      // 대기질 정보
                      if (widget.airQuality != null) _buildAirQualityInfo(),

                      SizedBox(height: 100.h),
                    ],
                  ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DefaultTextStyle.merge(
            style: const TextStyle(
              decoration: TextDecoration.none,
            ),
            child: Text(
              '상세 날씨 정보',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.getAdaptiveTextColor(widget.weatherType),
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtendedWeatherInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '추가 정보',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2.0,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 3x2 그리드로 정보 표시
          Row(
            children: [
              Expanded(child: _buildInfoCard('기압', '${widget.weather!.pressure?.toStringAsFixed(0) ?? 'N/A'} hPa')),
              SizedBox(width: 12.w),
              Expanded(child: _buildInfoCard('가시거리', '${((widget.weather!.visibility ?? 0) / 1000).toStringAsFixed(1)} km')),
              SizedBox(width: 12.w),
              Expanded(child: _buildInfoCard('UV 지수', widget.uvIndex?.toStringAsFixed(1) ?? 'N/A')),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(child: _buildInfoCard('일출', widget.weather!.sunrise != null
                  ? '${widget.weather!.sunrise!.hour}:${widget.weather!.sunrise!.minute.toString().padLeft(2, '0')}'
                  : 'N/A')),
              SizedBox(width: 12.w),
              Expanded(child: _buildInfoCard('일몰', widget.weather!.sunset != null
                  ? '${widget.weather!.sunset!.hour}:${widget.weather!.sunset!.minute.toString().padLeft(2, '0')}'
                  : 'N/A')),
              SizedBox(width: 12.w),
              Expanded(child: _buildInfoCard('습도', '${widget.weather!.humidity}%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2.0,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2.0,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Widget chart) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: chart,
    );
  }

  Widget _buildAirQualityInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '대기질 정보',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2.0,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getAirQualityColor(),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Text(
                  widget.airQuality!.qualityLevel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // AQI 수치
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  'AQI',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2.0,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${widget.airQuality!.aqi}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.none,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // 세부 오염물질 정보
          Row(
            children: [
              Expanded(child: _buildPollutantInfo('PM2.5', widget.airQuality!.pm25, 'μg/m³')),
              SizedBox(width: 12.w),
              Expanded(child: _buildPollutantInfo('PM10', widget.airQuality!.pm10, 'μg/m³')),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(child: _buildPollutantInfo('NO₂', widget.airQuality!.no2, 'μg/m³')),
              SizedBox(width: 12.w),
              Expanded(child: _buildPollutantInfo('O₃', widget.airQuality!.o3, 'μg/m³')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantInfo(String name, double value, String unit) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2.0,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 2.0,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  WeatherType _getWeatherType(String weatherType) {
    switch (weatherType.toLowerCase()) {
      case 'clear':
        return WeatherType.sunny;
      case 'sunny':
        return WeatherType.sunny;
      case 'cloudy':
        return WeatherType.cloudy;
      case 'overcast':
        return WeatherType.cloudy;
      case 'rain':
        return WeatherType.rainy;
      case 'drizzle':
        return WeatherType.rainy;
      case 'shower':
        return WeatherType.rainy;
      case 'thunderstorm':
        return WeatherType.stormy;
      case 'snow':
        return WeatherType.snowy;
      case 'blizzard':
        return WeatherType.snowy;
      case 'fog':
        return WeatherType.foggy;
      case 'mist':
        return WeatherType.foggy;
      default:
        return WeatherType.sunny;
    }
  }

  Color _getAirQualityColor() {
    if (widget.airQuality == null) return Colors.grey;

    switch (widget.airQuality!.aqi) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

