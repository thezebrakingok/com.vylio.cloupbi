import 'package:flutter/foundation.dart';

/// Configuración pública del cliente Supabase.
///
/// Los valores llegan mediante --dart-define-from-file o --dart-define.
/// Nunca se guardan claves dentro del código fuente ni del repositorio.
class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static void assertValid() {
    if (!isConfigured && kReleaseMode) {
      throw StateError(
        'Supabase no está configurado. Usa --dart-define-from-file.',
      );
    }
  }
}
