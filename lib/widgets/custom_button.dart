import 'package:flutter/material.dart';
import '../core/constants.dart';

enum ButtonType { primary, secondary, danger, success }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors['background'],
        foregroundColor: colors['foreground'],
        disabledBackgroundColor: colors['background']?.withOpacity(0.5),
        disabledForegroundColor: colors['foreground']?.withOpacity(0.5),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingLarge,
          vertical: AppConstants.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors['foreground'] ?? Colors.white,
                ),
              ),
            )
          : Row(
              mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppConstants.paddingSmall),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: AppConstants.fontFamily,
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );

    return isFullWidth 
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  Map<String, Color> _getColors() {
    switch (type) {
      case ButtonType.primary:
        return {
          'background': AppConstants.primaryBlue,
          'foreground': Colors.white,
        };
      case ButtonType.secondary:
        return {
          'background': AppConstants.backgroundWhite,
          'foreground': AppConstants.primaryBlue,
        };
      case ButtonType.danger:
        return {
          'background': AppConstants.rainRed,
          'foreground': Colors.white,
        };
      case ButtonType.success:
        return {
          'background': AppConstants.clearGreen,
          'foreground': Colors.white,
        };
    }
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonType type;
  final double size;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = 24.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    
    return Container(
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: size),
        color: colors['foreground'],
        tooltip: tooltip,
        padding: const EdgeInsets.all(AppConstants.paddingSmall),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }

  Map<String, Color> _getColors() {
    switch (type) {
      case ButtonType.primary:
        return {
          'background': AppConstants.primaryBlue,
          'foreground': Colors.white,
        };
      case ButtonType.secondary:
        return {
          'background': AppConstants.backgroundWhite,
          'foreground': AppConstants.primaryBlue,
        };
      case ButtonType.danger:
        return {
          'background': AppConstants.rainRed,
          'foreground': Colors.white,
        };
      case ButtonType.success:
        return {
          'background': AppConstants.clearGreen,
          'foreground': Colors.white,
        };
    }
  }
}
