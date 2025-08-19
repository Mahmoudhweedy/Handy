import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';

enum AppTextFieldType {
  text,
  email,
  password,
  phone,
  number,
  multiline,
  search,
}

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final AppTextFieldType type;
  final bool isRequired;
  final bool isReadOnly;
  final bool isEnabled;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final EdgeInsets? contentPadding;
  final double? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final bool showCounter;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.type = AppTextFieldType.text,
    this.isRequired = false,
    this.isReadOnly = false,
    this.isEnabled = true,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.helperStyle,
    this.errorStyle,
    this.showCounter = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.type == AppTextFieldType.password;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton =
          _controller.text.isNotEmpty && widget.type == AppTextFieldType.search;
    });
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {
      _showClearButton =
          _focusNode.hasFocus &&
          _controller.text.isNotEmpty &&
          widget.type == AppTextFieldType.search;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          _buildLabel(theme),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          readOnly: widget.isReadOnly,
          enabled: widget.isEnabled,
          maxLength: widget.maxLength,
          maxLines: _getMaxLines(),
          minLines: widget.minLines,
          keyboardType: _getKeyboardType(),
          textInputAction:
              widget.textInputAction ?? _getDefaultTextInputAction(),
          textCapitalization: widget.textCapitalization,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          inputFormatters:
              widget.inputFormatters ?? _getDefaultInputFormatters(),
          validator: widget.validator ?? _getDefaultValidator(),
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          onFieldSubmitted: widget.onSubmitted,
          style: widget.textStyle ?? theme.textTheme.bodyLarge,
          buildCounter: widget.showCounter
              ? null
              : (_, {required currentLength, maxLength, required isFocused}) =>
                    null,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: _buildPrefixIcon(),
            suffixIcon: _buildSuffixIcon(),
            prefixText: widget.prefixText,
            suffixText: widget.suffixText,
            filled: true,
            fillColor: widget.fillColor ?? theme.inputDecorationTheme.fillColor,
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: _buildBorder(theme, colorScheme.outline),
            enabledBorder: _buildBorder(
              theme,
              widget.borderColor ?? colorScheme.outline,
            ),
            focusedBorder: _buildBorder(
              theme,
              widget.focusedBorderColor ?? colorScheme.primary,
              width: 2,
            ),
            errorBorder: _buildBorder(
              theme,
              widget.errorBorderColor ?? colorScheme.error,
            ),
            focusedErrorBorder: _buildBorder(
              theme,
              widget.errorBorderColor ?? colorScheme.error,
              width: 2,
            ),
            hintStyle: widget.hintStyle ?? theme.inputDecorationTheme.hintStyle,
            helperStyle:
                widget.helperStyle ?? theme.inputDecorationTheme.helperStyle,
            errorStyle:
                widget.errorStyle ?? theme.inputDecorationTheme.errorStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(ThemeData theme) {
    return RichText(
      text: TextSpan(
        text: widget.label,
        style: widget.labelStyle ?? theme.inputDecorationTheme.labelStyle,
        children: [
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.prefixIcon != null) {
      return widget.prefixIcon;
    }

    switch (widget.type) {
      case AppTextFieldType.email:
        return const Icon(Icons.email_outlined);
      case AppTextFieldType.password:
        return const Icon(Icons.lock_outline);
      case AppTextFieldType.phone:
        return const Icon(Icons.phone_outlined);
      case AppTextFieldType.search:
        return const Icon(Icons.search);
      default:
        return null;
    }
  }

  Widget? _buildSuffixIcon() {
    final List<Widget> suffixIcons = [];

    // Add clear button for search fields
    if (_showClearButton) {
      suffixIcons.add(
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );
    }

    // Add password visibility toggle
    if (widget.type == AppTextFieldType.password) {
      suffixIcons.add(
        IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      );
    }

    // Add custom suffix icon
    if (widget.suffixIcon != null) {
      suffixIcons.add(widget.suffixIcon!);
    }

    if (suffixIcons.isEmpty) {
      return null;
    }

    if (suffixIcons.length == 1) {
      return suffixIcons.first;
    }

    return Row(mainAxisSize: MainAxisSize.min, children: suffixIcons);
  }

  OutlineInputBorder _buildBorder(
    ThemeData theme,
    Color color, {
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        widget.borderRadius ?? AppConstants.defaultBorderRadius,
      ),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.phone:
        return TextInputType.phone;
      case AppTextFieldType.number:
        return TextInputType.number;
      case AppTextFieldType.multiline:
        return TextInputType.multiline;
      case AppTextFieldType.password:
      case AppTextFieldType.text:
      case AppTextFieldType.search:
        return TextInputType.text;
    }
  }

  int? _getMaxLines() {
    if (widget.maxLines != null) {
      return widget.maxLines;
    }

    switch (widget.type) {
      case AppTextFieldType.multiline:
        return null;
      case AppTextFieldType.password:
        return 1;
      default:
        return 1;
    }
  }

  TextInputAction _getDefaultTextInputAction() {
    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputAction.next;
      case AppTextFieldType.password:
        return TextInputAction.done;
      case AppTextFieldType.phone:
        return TextInputAction.next;
      case AppTextFieldType.search:
        return TextInputAction.search;
      case AppTextFieldType.multiline:
        return TextInputAction.newline;
      default:
        return TextInputAction.next;
    }
  }

  List<TextInputFormatter>? _getDefaultInputFormatters() {
    switch (widget.type) {
      case AppTextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case AppTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }

  FormFieldValidator<String>? _getDefaultValidator() {
    if (!widget.isRequired) {
      return null;
    }

    return (value) {
      if (value == null || value.isEmpty) {
        return '${widget.label ?? 'This field'} is required';
      }

      switch (widget.type) {
        case AppTextFieldType.email:
          if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          break;
        case AppTextFieldType.password:
          if (value.length < AppConstants.minPasswordLength) {
            return 'Password must be at least ${AppConstants.minPasswordLength} characters';
          }
          break;
        case AppTextFieldType.phone:
          if (!RegExp(AppConstants.phonePattern).hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
          break;
        default:
          break;
      }

      return null;
    };
  }
}
