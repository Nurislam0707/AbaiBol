import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isInverted = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isInverted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isInverted
              ? Colors.white
              : Theme.of(context).colorScheme.primary,
          foregroundColor: isInverted
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
        ),
      ),
    );
  }
}
