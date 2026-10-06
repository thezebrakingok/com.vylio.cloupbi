import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase_service.dart';

class SocialRepository {
  const SocialRepository();

  Future<List<Map<String, dynamic>>> fetchFeed({int limit = 20}) async {
    final client = SupabaseService.client;
    if (client == null) return const [];

    final response = await client
        .from('posts')
        .select(
          'id, body, image_url, tag, created_at, author_id, profiles(id, username, display_name, avatar_url)',
        )
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createPost({
    required String body,
    String? tag,
    String? imageUrl,
  }) async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) {
      throw StateError('Debes iniciar sesión para publicar.');
    }

    await client.from('posts').insert({
      'author_id': user.id,
      'body': body.trim(),
      if (tag != null && tag.trim().isNotEmpty) 'tag': tag.trim(),
      if (imageUrl != null && imageUrl.trim().isNotEmpty)
        'image_url': imageUrl.trim(),
    });
  }

  Future<String> uploadPostImage({
    required Uint8List bytes,
    required String extension,
  }) async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) {
      throw StateError('Debes iniciar sesión.');
    }
    final safeExtension = extension.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    final path =
        '${user.id}/${DateTime.now().microsecondsSinceEpoch}.$safeExtension';
    await client.storage
        .from('post-media')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: 'image/$safeExtension',
            upsert: false,
          ),
        );
    return client.storage.from('post-media').getPublicUrl(path);
  }

  Future<void> likePost(String postId) async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) {
      throw StateError('Debes iniciar sesión.');
    }
    await client.from('post_likes').upsert({
      'post_id': postId,
      'user_id': user.id,
    });
  }

  Future<void> unlikePost(String postId) async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) {
      throw StateError('Debes iniciar sesión.');
    }
    await client
        .from('post_likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', user.id);
  }

  Future<void> follow(String profileId) async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) {
      throw StateError('Debes iniciar sesión.');
    }
    await client.from('follows').upsert({
      'follower_id': user.id,
      'following_id': profileId,
    });
  }

  Future<void> unfollow(String profileId) async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) {
      throw StateError('Debes iniciar sesión.');
    }
    await client
        .from('follows')
        .delete()
        .eq('follower_id', user.id)
        .eq('following_id', profileId);
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final client = SupabaseService.client;
    if (client == null) return const [];
    final response = await client
        .from('comments')
        .select(
          'id, body, created_at, author_id, profiles(username, display_name)',
        )
        .eq('post_id', postId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addComment({
    required String postId,
    required String body,
  }) async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) {
      throw StateError('Debes iniciar sesión.');
    }
    await client.from('comments').insert({
      'post_id': postId,
      'author_id': user.id,
      'body': body.trim(),
    });
  }

  Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    final client = SupabaseService.client;
    if (client == null || query.trim().isEmpty) return const [];
    final response = await client
        .from('profiles')
        .select('id, username, display_name, avatar_url')
        .or(
          'username.ilike.%${query.trim()}%,display_name.ilike.%${query.trim()}%',
        )
        .limit(20);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> isFollowing(String profileId) async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) return false;
    final response = await client
        .from('follows')
        .select('following_id')
        .eq('follower_id', user.id)
        .eq('following_id', profileId)
        .maybeSingle();
    return response != null;
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) return const [];
    final response = await client
        .from('notifications')
        .select(
          'id, kind, created_at, read_at, actor_id, profiles:actor_id(username, display_name)',
        )
        .eq('recipient_id', user.id)
        .order('created_at', ascending: false)
        .limit(30);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markNotificationsRead() async {
    final client = SupabaseService.client;
    final user = SupabaseService.currentUser;
    if (client == null || user == null) return;
    await client
        .from('notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('recipient_id', user.id)
        .isFilter('read_at', null);
  }
}
