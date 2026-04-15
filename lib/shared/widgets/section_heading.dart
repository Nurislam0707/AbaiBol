import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitleWidgets = subtitle == null
        ? null
        : <Widget>[
            const SizedBox(height: 6),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              ...?subtitleWidgets,
            ],
          ),
        ),
        // ignore: use_null_aware_elements
        if (trailing != null) trailing!,
      ],
    );
  }
}
