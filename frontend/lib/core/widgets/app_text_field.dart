import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText && _obscure,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 20)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : widget.suffix,
          ),
        ),
      ],
    );
  }
}
