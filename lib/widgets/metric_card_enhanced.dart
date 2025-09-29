import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class MetricCardEnhanced extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final double progressValue;
  final double maxValue;
  final Color color;
  final bool isGood;
  final bool showGauge;
  final String? lastUpdated;
  final VoidCallback? onTap;

  const MetricCardEnhanced({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.progressValue,
    required this.maxValue,
    required this.color,
    required this.isGood,
    this.showGauge = false,
    this.lastUpdated,
    this.onTap,
  });

  @override
  State<MetricCardEnhanced> createState() => _MetricCardEnhancedState();
}

class _MetricCardEnhancedState extends State<MetricCardEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _shadowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progressValue / widget.maxValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(MetricCardEnhanced oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressValue != widget.progressValue) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progressValue / widget.maxValue,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animationController, _hoverController]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: Transform.scale(
            scale: _scaleAnimation.value + (_hoverAnimation.value * 0.02),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                transform: Matrix4.translationValues(
                  0,
                  -_hoverAnimation.value * 4,
                  0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.15 + (_hoverAnimation.value * 0.1)),
                      blurRadius: _shadowAnimation.value,
                      spreadRadius: _shadowAnimation.value * 0.3,
                      offset: Offset(0, 4 + (_hoverAnimation.value * 2)),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _isHovered
                          ? widget.color.withOpacity(0.08)
                          : widget.color.withOpacity(0.05),
                      Colors.white,
                      _isHovered
                          ? Colors.white
                          : widget.color.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isHovered
                            ? widget.color.withOpacity(0.3)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enhanced Header
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(
                                    0.1 + (_hoverAnimation.value * 0.1),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isHovered
                                      ? [
                                          BoxShadow(
                                            color: widget.color.withOpacity(0.2),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: widget.color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _isHovered
                                            ? widget.color
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (widget.lastUpdated != null)
                                      Text(
                                        widget.lastUpdated!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Status indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor().withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Enhanced Value Display
                          Expanded(
                            child: widget.showGauge
                                ? _buildEnhancedGauge()
                                : _buildEnhancedLinearProgress(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLinearProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Value Display
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isHovered ? widget.color : widget.color.withOpacity(0.8),
          ),
          child: Text(widget.value),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            color: _isHovered
                ? widget.color.withOpacity(0.8)
                : AppColors.textSecondary,
          ),
          child: Text(widget.unit),
        ),
        const SizedBox(height: 12),

        // Enhanced Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.border.withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              width: MediaQuery.of(context).size.width,
              child: LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getEnhancedProgressColor(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Animated Percentage
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _getEnhancedProgressColor(),
          ),
          child: Text(
            '${(_progressAnimation.value * 100).round()}%',
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedGauge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.color.withOpacity(0.1),
              widget.color.withOpacity(0.05),
            ],
          ),
        ),
        child: SleekCircularSlider(
          appearance: CircularSliderAppearance(
            size: 90,
            customWidths: CustomSliderWidths(
              progressBarWidth: 8,
              trackWidth: 6,
              shadowWidth: 0,
            ),
            customColors: CustomSliderColors(
              progressBarColor: widget.color,
              trackColor: AppColors.border.withOpacity(0.5),
              dotColor: widget.color,
              shadowColor: Colors.transparent,
            ),
            angleRange: 360,
            startAngle: 270,
            animationEnabled: true,
          ),
          min: 0,
          max: widget.maxValue,
          initialValue: widget.progressValue,
          innerWidget: (percentage) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withOpacity(0.2),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? widget.color : widget.color,
                    ),
                    child: Text(widget.value),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 10,
                      color: _isHovered
                          ? widget.color.withOpacity(0.8)
                          : AppColors.textSecondary,
                    ),
                    child: Text(widget.unit),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor() {
    final percentage = widget.progressValue / widget.maxValue;

    if (widget.title.contains('Tank') || widget.title.contains('Fuel')) {
      if (percentage < 0.2) return AppColors.error;
      if (percentage < 0.5) return AppColors.warning;
      return AppColors.success;
    } else if (widget.title.contains('Temp')) {
      if (percentage > 0.9) return AppColors.error;
      if (percentage > 0.7) return AppColors.warning;
      return AppColors.info;
    } else if (widget.title.contains('RPM')) {
      return widget.color;
    }

    return widget.color;
  }

  Color _getEnhancedProgressColor() {
    final percentage = _progressAnimation.value;

    if (widget.title.contains('Tank') || widget.title.contains('Fuel')) {
      if (percentage < 0.3) return AppColors.error;
      if (percentage < 0.7) return AppColors.warning;
      return AppColors.success;
    } else if (widget.title.contains('Temp')) {
      if (percentage > 0.8) return AppColors.error;
      if (percentage > 0.6) return AppColors.warning;
      return AppColors.info;
    } else if (widget.title.contains('RPM')) {
      return widget.color;
    }

    return widget.color;
  }
}