import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../core/localization/app_strings.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('Abai Feedback', style: theme.textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(
                'Nuris Platform - ${strings.shareFeedbackSafely.toLowerCase()}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                label: strings.anonymousReview,
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
