import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_service.dart';

class AuthService {
  const AuthService();

  Stream<AuthState> get authStateChanges {
    final client = SupabaseService.client;
    if (client == null) return const Stream.empty();
    return client.auth.onAuthStateChange;
  }

  Future<AuthResponse> signUp({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    final client = SupabaseService.client;
    if (client == null) throw StateError('Supabase no está configurado.');
    return client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'username': username.trim().toLowerCase(),
        if (displayName != null && displayName.trim().isNotEmpty)
          'display_name': displayName.trim(),
      },
    );
  }

  Future<AuthResponse> signIn({
    required String identifier,
    required String password,
  }) async {
    final client = SupabaseService.client;
    if (client == null) throw StateError('Supabase no está configurado.');
    var email = identifier.trim();
    if (!email.contains('@')) {
      final resolved = await client.rpc<String?>(
        'resolve_login_email',
        params: {'identifier': email},
      );
      if (resolved == null || resolved.isEmpty) {
        throw const AuthException('Invalid login credentials');
      }
      email = resolved;
    }
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await SupabaseService.client?.auth.signOut();
  }
}
