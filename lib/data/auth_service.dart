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
    final normalizedUsername = username.trim().toLowerCase();
    final normalizedEmail = email.trim().toLowerCase();
    final available = await client.rpc<bool>(
      'is_username_available',
      params: {'candidate': normalizedUsername},
    );
    if (available != true) {
      throw StateError('username_taken');
    }
    return client.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {
        'username': normalizedUsername,
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

  Future<void> resetPassword(String identifier) async {
    final client = SupabaseService.client;
    if (client == null) throw StateError('Supabase no está configurado.');
    var email = identifier.trim().toLowerCase();
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
    await client.auth.resetPasswordForEmail(email);
  }
}
