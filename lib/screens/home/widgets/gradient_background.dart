import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

class GradientBackground extends StatelessWidget {
  final String weatherType;
  final double opacity;

  const GradientBackground({
    super.key,
    required this.weatherType,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.getCombinedGradient(weatherType),
          ),
        ),
      ),
    );
  }
}
