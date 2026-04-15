import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/bootstrap/app_bootstrap_provider.dart';
import 'core/constants/supabase_constants.dart';
import 'core/localization/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  runApp(const ProviderScope(child: NurisApp()));
}

class NurisApp extends ConsumerWidget {
  const NurisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);

    return bootstrap.when(
      data: (_) {
        final router = ref.watch(appRouterProvider);
        final themeMode = ref.watch(themeModeProvider);
        final strings = ref.watch(appStringsProvider);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: strings.appTitle,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const _StartupStateScreen(
          icon: Icons.shield_outlined,
          title: 'Preparing anonymous session',
          message: 'Connecting securely before loading reviews...',
          showLoader: true,
        ),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: _StartupStateScreen(
          icon: Icons.cloud_off_rounded,
          title: 'Unable to start review session',
          message: error.toString(),
        ),
      ),
    );
  }
}

class _StartupStateScreen extends StatelessWidget {
  const _StartupStateScreen({
    required this.icon,
    required this.title,
    required this.message,
    this.showLoader = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (showLoader) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
