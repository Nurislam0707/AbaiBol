import 'package:supabase_flutter/supabase_flutter.dart';

class AnonymousAuthService {
  const AnonymousAuthService(this._client);

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<User> ensureSignedIn() async {
    final existingUser = _client.auth.currentUser;
    if (existingUser != null) {
      return existingUser;
    }

    final response = await _client.auth.signInAnonymously();
    final user = response.user;
    if (user == null) {
      throw StateError('Anonymous sign-in did not return a user.');
    }

    return user;
  }
}
