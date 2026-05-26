import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Shared small widgets used across all Quality Diagnosis screens.

class QdField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const QdField(this.label, this.controller, this.hint, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

class QdSectionLabel extends StatelessWidget {
  final String text;
  const QdSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class QdInfoCard extends StatelessWidget {
  final String text;
  const QdInfoCard(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class QdResultCard extends StatelessWidget {
  final List<Widget> children;
  const QdResultCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class QdResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const QdResultRow(this.label, this.value,
      {super.key, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: highlight ? 14 : 13,
              color: highlight ? AppTheme.textPrimary : AppTheme.textSecondary,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 16 : 14,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              color: highlight ? AppTheme.primary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class QdDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const QdDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      // ignore: deprecated_member_use
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
    );
  }
}
