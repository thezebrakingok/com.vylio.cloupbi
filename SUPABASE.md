# Supabase en CloUP BI

El proyecto usa `supabase_flutter` y recibe la configuración en tiempo de compilación. Las claves no se guardan en GitHub.

## Compilar localmente

```bash
flutter pub get
flutter run --dart-define-from-file=/home/ubuntu/.config/vylio/supabase.dart-defines.json
flutter build apk --dart-define-from-file=/home/ubuntu/.config/vylio/supabase.dart-defines.json
```

Para otros equipos, copiá `supabase.defines.example.json` a un archivo local privado y completá `SUPABASE_URL` y `SUPABASE_ANON_KEY` o `SUPABASE_PUBLISHABLE_KEY` según la clave pública disponible en el panel de Supabase. No subas ese archivo al repositorio.

## Esquema inicial creado

- `profiles`: perfil público asociado a `auth.users`.
- `posts`: publicaciones de hasta 500 caracteres.
- `post_likes`: likes únicos por usuario y publicación.
- `comments`: comentarios.
- `follows`: relaciones de seguimiento.
- `notifications`: eventos de interacción.

Todas las tablas tienen **Row Level Security** habilitado. Las operaciones de escritura exigen un usuario autenticado y solo permiten modificar recursos propios.

La migración aplicada en el proyecto Supabase se llama `create_cloupbi_social_schema`.
