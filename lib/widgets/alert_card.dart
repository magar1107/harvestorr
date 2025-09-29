import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

enum AlertSeverity {
  info,
  warning,
  error,
  critical,
}

class AlertItem {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;
  final String deviceId;

  const AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
    required this.deviceId,
  });
}

class AlertCard extends StatefulWidget {
  final AlertItem alert;
  final VoidCallback? onTap;
  final bool isExpanded;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.isExpanded = false,
  });

  @override
  State<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.cardBorderRadius,
                side: BorderSide(
                  color: _getSeverityColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              color: _getSeverityColor().withOpacity(0.05),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: AppTheme.cardBorderRadius,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          // Severity indicator
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getSeverityColor(),
                              boxShadow: [
                                BoxShadow(
                                  color: _getSeverityColor().withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Alert info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.alert.title,
                                  style: AppTextStyles.alertTitle.withColor(
                                    _getSeverityColor(),
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(widget.alert.timestamp),
                                  style: AppTextStyles.timestamp,
                                ),
                              ],
                            ),
                          ),

                          // Severity badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getSeverityText(),
                              style: AppTextStyles.labelSmall.withColor(
                                Colors.white,
                              ),
                            ),
                          ),

                          // Unread indicator
                          if (!widget.alert.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),

                      if (widget.isExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          widget.alert.message,
                          style: AppTextStyles.alertMessage,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Device: ${widget.alert.deviceId}',
                              style: AppTextStyles.bodySmall.withColor(
                                AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                textStyle: AppTextStyles.labelSmall,
                              ),
                              child: Text(
                                'View Details',
                                style: AppTextStyles.labelSmall.withColor(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getSeverityColor() {
    switch (widget.alert.severity) {
      case AlertSeverity.info:
        return AppColors.alertInfo;
      case AlertSeverity.warning:
        return AppColors.alertWarning;
      case AlertSeverity.error:
        return AppColors.alertError;
      case AlertSeverity.critical:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getSeverityText() {
    switch (widget.alert.severity) {
      case AlertSeverity.info:
        return 'INFO';
      case AlertSeverity.warning:
        return 'WARNING';
      case AlertSeverity.error:
        return 'ERROR';
      case AlertSeverity.critical:
        return 'CRITICAL';
      default:
        return 'UNKNOWN';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class ExpandableAlertCard extends StatefulWidget {
  final AlertItem alert;
  final VoidCallback? onTap;

  const ExpandableAlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  State<ExpandableAlertCard> createState() => _ExpandableAlertCardState();
}

class _ExpandableAlertCardState extends State<ExpandableAlertCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AlertCard(
      alert: widget.alert,
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        widget.onTap?.call();
      },
      isExpanded: _isExpanded,
    );
  }
}
