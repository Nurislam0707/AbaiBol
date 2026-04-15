import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/services/anonymous_auth_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final anonymousAuthServiceProvider = Provider<AnonymousAuthService>(
  (ref) => AnonymousAuthService(ref.watch(supabaseClientProvider)),
);

final currentAnonymousUserIdProvider = Provider<String?>(
  (ref) => ref.watch(anonymousAuthServiceProvider).currentUserId,
);
