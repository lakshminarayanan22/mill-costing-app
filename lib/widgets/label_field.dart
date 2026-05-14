import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// Reusable labeled numeric text field with optional unit suffix.
class LabelField extends StatelessWidget {
  final String label;
  final String? unit;
  final String? hint;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final bool isInteger;
  final bool enabled;

  const LabelField({
    super.key,
    required this.label,
    required this.controller,
    this.unit,
    this.hint,
    this.onChanged,
    this.isInteger = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.numberWithOptions(
            decimal: !isInteger,
            signed: false,
          ),
          inputFormatters: isInteger
              ? [FilteringTextInputFormatter.digitsOnly]
              : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            suffixStyle: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
