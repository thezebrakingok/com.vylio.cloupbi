# Supabase en CloUP BI

El proyecto usa `supabase_flutter` y recibe la configuración en tiempo de compilación. Las claves no se guardan en GitHub.

## Compilar localmente

```bash
flutter pub get
flutter run --dart-define-from-file=/home/ubuntu/.config/vylio/supabase.dart-defines.json
flutter build apk --dart-define-from-file=/home/ubuntu/.config/vylio/supabase.dart-defines.json
```

El APK release se compila con `flutter build apk --release --dart-define-from-file=...` y requiere la firma privada local configurada en `android/key.properties`. Ese archivo, el keystore y sus contraseñas nunca se suben al repositorio.

Para otros equipos, copiá `supabase.defines.example.json` a un archivo local privado y completá `SUPABASE_URL` y `SUPABASE_ANON_KEY` o `SUPABASE_PUBLISHABLE_KEY` según la clave pública disponible en el panel de Supabase. No subas ese archivo al repositorio.

## Autenticación real

El registro solicita **nombre de usuario, correo y contraseña**. El inicio de sesión acepta el correo o el nombre de usuario junto con la contraseña. La resolución de usuario se realiza mediante la función `resolve_login_email` en Supabase.

## Publicaciones reales

El feed no contiene historias, tendencias ni posts de ejemplo. Una publicación puede tener texto de hasta 500 caracteres y una imagen seleccionada desde el dispositivo. Las imágenes se suben al bucket público `post-media` con rutas separadas por usuario y las tablas mantienen RLS.

## Esquema inicial creado

- `profiles`: perfil público asociado a `auth.users`.
- `posts`: publicaciones de hasta 500 caracteres.
- `post_likes`: likes únicos por usuario y publicación.
- `comments`: comentarios.
- `follows`: relaciones de seguimiento.
- `notifications`: eventos de interacción.

Todas las tablas tienen **Row Level Security** habilitado. Las operaciones de escritura exigen un usuario autenticado y solo permiten modificar recursos propios.

La migración aplicada en el proyecto Supabase se llama `create_cloupbi_social_schema`.

También se aplicaron `create_social_notification_triggers` y `enable_username_login_and_post_storage`.
