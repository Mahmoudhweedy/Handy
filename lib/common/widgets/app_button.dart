import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

enum AppButtonType { elevated, outlined, text }

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final double? elevation;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.elevated,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.textStyle,
  });

  /// Factory constructor for elevated button
  factory AppButton.elevated({
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsets? padding,
    double? elevation,
    TextStyle? textStyle,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.elevated,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: borderRadius,
      padding: padding,
      elevation: elevation,
      textStyle: textStyle,
    );
  }

  /// Factory constructor for outlined button
  factory AppButton.outlined({
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? foregroundColor,
    Color? borderColor,
    double? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.outlined,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
    );
  }

  /// Factory constructor for text button
  factory AppButton.text({
    required String text,
    VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.medium,
    bool isLoading = false,
    bool isFullWidth = false,
    IconData? icon,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? foregroundColor,
    double? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: AppButtonType.text,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      foregroundColor: foregroundColor,
      borderRadius: borderRadius,
      padding: padding,
      textStyle: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate dimensions based on size
    final dimensions = _getButtonDimensions();
    final padding = this.padding ?? dimensions.padding;
    final borderRadius = this.borderRadius ?? AppConstants.defaultBorderRadius;

    // Build button content
    Widget buttonChild = _buildButtonContent(context);

    // Handle loading state
    if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: dimensions.iconSize,
            height: dimensions.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.elevated
                    ? (foregroundColor ?? colorScheme.onPrimary)
                    : (foregroundColor ?? colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: textStyle ?? TextStyle(fontSize: dimensions.fontSize),
          ),
        ],
      );
    }

    // Wrap in full width container if needed
    Widget button = _buildButton(context, buttonChild, padding, borderRadius);

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildButton(
    BuildContext context,
    Widget child,
    EdgeInsets padding,
    double borderRadius,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = onPressed != null && !isLoading;

    switch (type) {
      case AppButtonType.elevated:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: foregroundColor ?? colorScheme.onPrimary,
            padding: padding,
            elevation: elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: textStyle,
          ),
          child: child,
        );

      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? colorScheme.primary,
            padding: padding,
            side: BorderSide(
              color: borderColor ?? foregroundColor ?? colorScheme.primary,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: textStyle,
          ),
          child: child,
        );

      case AppButtonType.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? colorScheme.primary,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            textStyle: textStyle,
          ),
          child: child,
        );
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    final dimensions = _getButtonDimensions();

    if (isLoading) {
      return const SizedBox.shrink(); // Content is built in the main build method for loading
    }

    final List<Widget> children = [];

    // Add prefix icon or icon
    if (prefixIcon != null) {
      children.add(prefixIcon!);
      children.add(const SizedBox(width: 8));
    } else if (icon != null) {
      children.add(Icon(icon, size: dimensions.iconSize));
      children.add(const SizedBox(width: 8));
    }

    // Add text
    children.add(
      Text(text, style: textStyle ?? TextStyle(fontSize: dimensions.fontSize)),
    );

    // Add suffix icon
    if (suffixIcon != null) {
      children.add(const SizedBox(width: 8));
      children.add(suffixIcon!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  _ButtonDimensions _getButtonDimensions() {
    switch (size) {
      case AppButtonSize.small:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          fontSize: 14,
          iconSize: 16,
        );
      case AppButtonSize.medium:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          fontSize: 16,
          iconSize: 18,
        );
      case AppButtonSize.large:
        return const _ButtonDimensions(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          fontSize: 18,
          iconSize: 20,
        );
    }
  }
}

class _ButtonDimensions {
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;

  const _ButtonDimensions({
    required this.padding,
    required this.fontSize,
    required this.iconSize,
  });
}
