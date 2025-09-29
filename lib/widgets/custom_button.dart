import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 44,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: AppTheme.buttonBorderRadius,
          boxShadow: isDisabled ? null : AppTheme.buttonShadow,
        ),
        child: ElevatedButton(
          onPressed: (isDisabled || isLoading) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDisabled ? AppColors.textHint : color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.buttonBorderRadius,
            ),
            disabledBackgroundColor: AppColors.textHint.withOpacity(0.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 8),
                  child: Icon(
                    icon,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.buttonText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double size;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: isDisabled ? null : AppTheme.buttonShadow,
        ),
        child: Material(
          color: isDisabled ? AppColors.textHint : color,
          borderRadius: BorderRadius.circular(size / 2),
          child: InkWell(
            onTap: (isDisabled || isLoading) ? null : onPressed,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      icon,
                      size: 20,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
