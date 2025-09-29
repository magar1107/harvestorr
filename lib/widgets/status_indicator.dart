import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;
  final Color? onlineColor;
  final Color? offlineColor;

  const StatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 8,
    this.onlineColor,
    this.offlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOnline
            ? (onlineColor ?? AppColors.success)
            : (offlineColor ?? AppColors.error),
        border: Border.all(
          color: Colors.white,
          width: size / 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline
                ? (onlineColor ?? AppColors.success)
                : (offlineColor ?? AppColors.error)).withOpacity(0.3),
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }
}

class AnimatedStatusIndicator extends StatefulWidget {
  final bool isOnline;
  final double size;
  final Duration animationDuration;

  const AnimatedStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 8,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedStatusIndicator> createState() => _AnimatedStatusIndicatorState();
}

class _AnimatedStatusIndicatorState extends State<AnimatedStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * _pulseAnimation.value,
          height: widget.size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isOnline ? AppColors.success : AppColors.error,
            border: Border.all(
              color: Colors.white,
              width: widget.size / 4,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isOnline ? AppColors.success : AppColors.error)
                    .withOpacity(0.3),
                blurRadius: (widget.size / 2) * _pulseAnimation.value,
                spreadRadius: (widget.size / 4) * _pulseAnimation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
