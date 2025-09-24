import 'package:flutter/material.dart';

class GestureHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final VoidCallback? onRefresh;

  const GestureHandler({
    super.key,
    required this.child,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onRefresh,
  });

  @override
  State<GestureHandler> createState() => _GestureHandlerState();
}

class _GestureHandlerState extends State<GestureHandler> {
  double _startY = 0;
  bool _isPanning = false;
  static const double swipeThreshold = 50.0;
  static const double velocityThreshold = 500.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _startY = details.globalPosition.dy;
        _isPanning = true;
      },
      onPanUpdate: (details) {
        if (!_isPanning) return;

        final currentY = details.globalPosition.dy;
        final deltaY = currentY - _startY;

        // 연속적인 작은 움직임 감지 방지
        if (deltaY.abs() < 10) return;

        // 위로 스와이프 (deltaY가 음수)
        if (deltaY < -swipeThreshold && details.delta.dy < -3) {
          _isPanning = false;
          widget.onSwipeUp?.call();
        }
        // 아래로 스와이프 (deltaY가 양수)
        else if (deltaY > swipeThreshold && details.delta.dy > 3) {
          _isPanning = false;
          widget.onSwipeDown?.call();
        }
      },
      onPanEnd: (details) {
        if (!_isPanning) return;

        _isPanning = false;

        // 빠른 스와이프 감지 (속도 기반)
        final velocity = details.velocity.pixelsPerSecond.dy;

        if (velocity < -velocityThreshold) {
          // 빠른 위 스와이프
          widget.onSwipeUp?.call();
        } else if (velocity > velocityThreshold) {
          // 빠른 아래 스와이프
          widget.onSwipeDown?.call();
        }
      },
      onDoubleTap: () {
        // 더블 탭으로 새로고침
        widget.onRefresh?.call();
      },
      child: widget.child,
    );
  }
}
