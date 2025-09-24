import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';
import '../../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // 페이드 애니메이션
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // 스케일 애니메이션
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // 회전 애니메이션
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    // 순차적으로 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scaleController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _rotationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.getTimeBasedGradient(),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimationLimiter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 600),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 0.0,
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    // 앱 아이콘/로고
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: AnimatedBuilder(
                            animation: _rotationAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationAnimation.value * 0.1, // 약간만 회전
                                child: Container(
                                  width: 120.w,
                                  height: 120.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.white20,
                                    borderRadius: BorderRadius.circular(30.r),
                                    border: Border.all(
                                      color: AppColors.white30,
                                      width: 2.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black20,
                                        blurRadius: 20.r,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.wb_sunny_outlined,
                                    size: 60.sp,
                                    color: AppConstants.darkPrimaryTextColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 40.h),

                    // 앱 이름
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Weather Minimal',
                        style: AppTextStyles.appTitle.copyWith(
                          color: AppConstants.darkPrimaryTextColor,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // 부제목
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        '아름다운 날씨, 간결한 디자인',
                        style: AppTextStyles.weatherDescription.copyWith(
                          fontSize: 16.sp,
                          color: AppConstants.darkPrimaryTextColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    SizedBox(height: 80.h),

                    // 로딩 인디케이터
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildLoadingIndicator(),
                        );
                      },
                    ),

                    SizedBox(height: 20.h),

                    // 로딩 텍스트
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        '날씨 정보를 가져오는 중...',
                        style: AppTextStyles.loadingText.copyWith(
                          color: AppConstants.darkPrimaryTextColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: CircularProgressIndicator(
        strokeWidth: 2.w,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white30),
        backgroundColor: AppColors.white10,
      ),
    );
  }
}
