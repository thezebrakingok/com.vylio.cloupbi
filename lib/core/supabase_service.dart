import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class SupabaseService {
  const SupabaseService._();

  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
      debug: false,
    );
  }

  static SupabaseClient? get client {
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client;
  }

  static User? get currentUser => client?.auth.currentUser;
}
