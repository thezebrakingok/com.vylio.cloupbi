import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'core/supabase_service.dart';
import 'data/auth_service.dart';
import 'data/social_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const CloUpBiApp());
}

class CloUpBiApp extends StatelessWidget {
  const CloUpBiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CloUP BI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B5F),
          brightness: Brightness.light,
          primary: const Color(0xFFFF6B5F),
          secondary: const Color(0xFF5C67F2),
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfigReady.isConfigured) {
      return const ConfigurationNotice();
    }
    return StreamBuilder(
      stream: const AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (SupabaseService.currentUser == null) return const AuthPage();
        return const HomeShell();
      },
    );
  }
}

class SupabaseConfigReady {
  const SupabaseConfigReady._();
  static bool get isConfigured => SupabaseService.client != null;
}

class ConfigurationNotice extends StatelessWidget {
  const ConfigurationNotice({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(),
            const SizedBox(height: 24),
            const Text(
              'Falta configurar Supabase',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172943),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compilá la app usando --dart-define-from-file con tus variables locales.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6F7E94)),
            ),
          ],
        ),
      ),
    ),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _auth = const AuthService();
  bool _isSignUp = false;
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 50, 28, 28),
          children: [
            const BrandMark(),
            const SizedBox(height: 42),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D10233F),
                    blurRadius: 26,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSignUp ? 'Crea tu cuenta' : 'Bienvenido de nuevo',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172943),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'Únete a la comunidad que comparte lo que la inspira.'
                        : 'Entrá para ver las novedades de tu comunidad.',
                    style: const TextStyle(
                      color: Color(0xFF7B8AA1),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isSignUp) ...[
                    TextField(
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        hintText: 'ej: cloupbi_user',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre visible',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: _isSignUp
                          ? 'Correo electrónico'
                          : 'Usuario o correo electrónico',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B5F),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isSignUp ? 'Crear cuenta' : 'Iniciar sesión'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp ? 'Ya tengo una cuenta' : 'Crear una cuenta',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tus datos se protegen con autenticación y políticas RLS de Supabase.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B5)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final username = _username.text.trim().toLowerCase();
    final identifier = _email.text.trim();
    if (identifier.isEmpty ||
        password.length < 6 ||
        (_isSignUp &&
            (username.length < 3 ||
                !RegExp(r'^[a-z0-9_.]+$').hasMatch(username)))) {
      _show(
        _isSignUp
            ? 'Usá un usuario de 3 caracteres o más, correo válido y contraseña de al menos 6 caracteres.'
            : 'Ingresá tu usuario o correo y una contraseña de al menos 6 caracteres.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      if (_isSignUp) {
        final response = await _auth.signUp(
          username: username,
          email: email,
          password: password,
          displayName: _name.text,
        );
        if (mounted && response.session == null) {
          _show('Cuenta creada. Revisá tu correo para confirmar el acceso.');
        }
      } else {
        await _auth.signIn(identifier: identifier, password: password);
      }
    } catch (error) {
      if (mounted) _show(_friendlyAuthError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyAuthError(Object error) {
    final message = error.toString();
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('already registered')) {
      return 'Ese correo ya está registrado.';
    }
    return 'No pudimos completar la operación. Revisá tu conexión e intentá de nuevo.';
  }

  void _show(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _repository = const SocialRepository();
  int _selectedIndex = 0;
  bool _loading = true;
  String? _error;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      FeedPage(
        posts: _posts,
        loading: _loading,
        error: _error,
        onRefresh: _loadFeed,
        onLike: _toggleLike,
        onComment: _showComments,
        onCreate: () => setState(() => _selectedIndex = 2),
      ),
      const DiscoverPage(),
      CreatePage(onPostCreated: _createPost),
      const NotificationsPage(),
      ProfilePage(onSignOut: () => const AuthService().signOut()),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFE1DE),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Descubrir',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded),
            label: 'Crear',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Future<void> _loadFeed() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _repository.fetchFeed();
      if (!mounted) return;
      setState(() {
        _posts = rows.map(Post.fromMap).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No pudimos cargar el feed. Intentá actualizar de nuevo.';
      });
    }
  }

  Future<void> _createPost(String body, String? imageUrl) async {
    await _repository.createPost(body: body, imageUrl: imageUrl);
    await _loadFeed();
    if (mounted) setState(() => _selectedIndex = 0);
  }

  Future<void> _toggleLike(Post post) async {
    final oldValue = post.liked;
    setState(() {
      post.liked = !oldValue;
      post.likes += post.liked ? 1 : -1;
    });
    try {
      if (post.liked) {
        await _repository.likePost(post.id);
      } else {
        await _repository.unlikePost(post.id);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        post.liked = oldValue;
        post.likes += oldValue ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos actualizar el like.')),
      );
    }
  }

  Future<void> _showComments(Post post) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(post: post, repository: _repository),
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    required this.posts,
    required this.loading,
    required this.error,
    required this.onRefresh,
    required this.onLike,
    required this.onComment,
    required this.onCreate,
  });
  final List<Post> posts;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Post post) onLike;
  final Future<void> Function(Post post) onComment;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF7F8FC),
            titleSpacing: 20,
            title: const BrandMark(),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mail_outline_rounded),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: ComposerCard(onTap: onCreate)),
          if (loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B5F)),
              ),
            ),
          if (!loading && error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Sin conexión al feed',
                message: error!,
                actionLabel: 'Reintentar',
                onAction: onRefresh,
              ),
            ),
          if (!loading && error == null && posts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.forum_outlined,
                title: 'Todavía no hay publicaciones',
                message:
                    'Sé la primera persona en compartir algo con la comunidad.',
              ),
            ),
          if (!loading && error == null && posts.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverList.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) => PostCard(
                  post: posts[index],
                  onLike: onLike,
                  onComment: onComment,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: const Color(0xFF9AA5B5)),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172943),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(color: Color(0xFF7B8AA1), height: 1.4),
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 18),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    ),
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => RichText(
    text: const TextSpan(
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF10233F),
        letterSpacing: -1,
      ),
      children: [
        TextSpan(text: 'CloUP'),
        TextSpan(
          text: ' BI',
          style: TextStyle(color: Color(0xFFFF6B5F)),
        ),
      ],
    ),
  );
}

class ComposerCard extends StatelessWidget {
  const ComposerCard({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10233F),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            child: Icon(Icons.person_rounded, color: Color(0xFF8290A8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: const Text(
                '¿Qué estás pensando?',
                style: TextStyle(color: Color(0xFF8290A8), fontSize: 14),
              ),
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.image_outlined, color: Color(0xFF5C67F2)),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });
  final Post post;
  final Future<void> Function(Post post) onLike;
  final Future<void> Function(Post post) onComment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0810233F),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  child: Icon(Icons.person_rounded, color: Color(0xFF8290A8)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF172943),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${post.handle} · ${post.time}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8B98AD),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: Color(0xFF8B98AD),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF35445D),
              ),
            ),
          ),
          if (post.image != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.55,
                  child: Image.network(
                    post.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Color(0xFFEAEFFC),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF8290A8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Text(
                  post.tag ?? '',
                  style: const TextStyle(
                    color: Color(0xFF5C67F2),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  '${post.likes} me gusta',
                  style: const TextStyle(
                    color: Color(0xFF8B98AD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFEFF1F5),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 5),
            child: Row(
              children: [
                Expanded(
                  child: _PostAction(
                    icon: post.liked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: 'Me gusta',
                    active: post.liked,
                    onTap: () => onLike(post),
                  ),
                ),
                Expanded(
                  child: _PostAction(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comentar',
                    onTap: () => onComment(post),
                  ),
                ),
                Expanded(
                  child: _PostAction(
                    icon: Icons.send_outlined,
                    label: 'Compartir',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compartir próximamente')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.post,
    required this.repository,
  });
  final Post post;
  final SocialRepository repository;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return FractionallySizedBox(
      heightFactor: .82,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE1EA),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Comentarios',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B5F),
                      ),
                    )
                  : _comments.isEmpty
                  ? const EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Sé la primera persona en comentar',
                      message: 'Comparte tu opinión sobre esta publicación.',
                    )
                  : ListView.separated(
                      itemCount: _comments.length,
                      separatorBuilder: (_, _) => const Divider(height: 20),
                      itemBuilder: (_, index) =>
                          _CommentTile(data: _comments[index]),
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Escribe un comentario...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sending ? null : _send,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFFFF6B5F),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _load() async {
    try {
      final result = await widget.repository.fetchComments(widget.post.id);
      if (mounted) {
        setState(() {
          _comments = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    setState(() => _sending = true);
    try {
      await widget.repository.addComment(postId: widget.post.id, body: body);
      _controller.clear();
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pudimos guardar el comentario.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final profile = data['profiles'] is Map<String, dynamic>
        ? data['profiles'] as Map<String, dynamic>
        : <String, dynamic>{};
    final name = (profile['display_name'] as String?)?.trim().isNotEmpty == true
        ? profile['display_name'] as String
        : (profile['username'] as String? ?? 'Usuario');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          child: Icon(Icons.person_rounded, size: 19, color: Color(0xFF8290A8)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172943),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data['body']?.toString() ?? '',
                style: const TextStyle(color: Color(0xFF53627A), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostAction extends StatelessWidget {
  const _PostAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: active ? const Color(0xFFFF6B5F) : const Color(0xFF7B8AA1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? const Color(0xFFFF6B5F) : const Color(0xFF7B8AA1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key, required this.onPostCreated});
  final Future<void> Function(String body, String? imageUrl) onPostCreated;

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  XFile? _selectedImage;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear publicación',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _busy ? null : _publish,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B5F),
              ),
              child: const Text('Publicar'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Icon(Icons.person_rounded, color: Color(0xFF8290A8)),
              ),
              SizedBox(width: 12),
              Text(
                'Publicación pública',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 8,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Comparte una idea, un momento o una recomendación...',
              fillColor: Colors.white,
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(_selectedImage!.path),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Color(0xFF5C67F2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Agregar una foto desde tu dispositivo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF53627A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publish() async {
    if (_controller.text.trim().isEmpty) {
      _show('Escribe algo antes de publicar');
      return;
    }
    setState(() => _busy = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final name = _selectedImage!.name;
        final extension = name.contains('.') ? name.split('.').last : 'jpg';
        imageUrl = await const SocialRepository().uploadPostImage(
          bytes: bytes,
          extension: extension,
        );
      }
      await widget.onPostCreated(_controller.text, imageUrl);
      _controller.clear();
      if (mounted) setState(() => _selectedImage = null);
    } catch (_) {
      if (mounted) _show('No pudimos publicar. Revisá tu sesión.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (mounted && image != null) setState(() => _selectedImage = image);
  }
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _query = TextEditingController();
  final _repository = const SocialRepository();
  List<Map<String, dynamic>> _results = [];
  final Set<String> _following = {};
  bool _loading = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      const SliverAppBar(
        pinned: true,
        title: Text('Descubrir', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: TextField(
            controller: _query,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Busca personas',
              suffixIcon: IconButton(
                onPressed: _search,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Busca personas reales de CloUP BI',
                style: TextStyle(color: Color(0xFF7B8AA1)),
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B5F)),
                ),
              if (!_loading &&
                  _query.text.trim().isNotEmpty &&
                  _results.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Text(
                    'No encontramos perfiles con esa búsqueda.',
                    style: TextStyle(color: Color(0xFF7B8AA1)),
                  ),
                ),
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Personas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172943),
                  ),
                ),
                const SizedBox(height: 10),
                ..._results.map(_profileTile),
              ],
            ],
          ),
        ),
      ),
    ],
  );

  Widget _profileTile(Map<String, dynamic> profile) {
    final id = profile['id'].toString();
    final name = (profile['display_name'] as String?)?.trim().isNotEmpty == true
        ? profile['display_name'] as String
        : (profile['username'] as String? ?? 'Usuario');
    final isFollowing = _following.contains(id);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            child: Icon(Icons.person_rounded, color: Color(0xFF8290A8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172943),
                  ),
                ),
                Text(
                  '@${profile['username'] ?? 'usuario'}',
                  style: const TextStyle(
                    color: Color(0xFF8B98AD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _toggleFollow(id, isFollowing),
            child: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
          ),
        ],
      ),
    );
  }

  Future<void> _search() async {
    if (_query.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final result = await _repository.searchProfiles(_query.text);
      if (mounted) {
        setState(() {
          _results = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _results = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow(String id, bool isFollowing) async {
    try {
      if (isFollowing) {
        await _repository.unfollow(id);
        if (mounted) setState(() => _following.remove(id));
      } else {
        await _repository.follow(id);
        if (mounted) setState(() => _following.add(id));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos actualizar el seguimiento.'),
          ),
        );
      }
    }
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _repository = const SocialRepository();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B5F)),
      );
    } else if (_items.isEmpty) {
      body = const EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Sin notificaciones',
        message: 'Las interacciones aparecerán aquí cuando haya actividad en tu cuenta.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) => _notificationTile(_items[index]),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: body,
    );
  }

  Widget _notificationTile(Map<String, dynamic> item) {
    final actor = item['profiles'] is Map<String, dynamic>
        ? item['profiles'] as Map<String, dynamic>
        : <String, dynamic>{};
    final name = (actor['display_name'] as String?)?.trim().isNotEmpty == true
        ? actor['display_name'] as String
        : (actor['username'] as String? ?? 'Alguien');
    final kind = item['kind']?.toString();
    final text = switch (kind) {
      'like' => '$name indicó que le gusta tu publicación.',
      'comment' => '$name comentó tu publicación.',
      'follow' => '$name comenzó a seguirte.',
      _ => '$name interactuó contigo.',
    };
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: const CircleAvatar(
        child: Icon(Icons.person_rounded, color: Color(0xFF8290A8)),
      ),
      title: Text(text, style: const TextStyle(color: Color(0xFF35445D))),
      subtitle: Text(
        item['read_at'] == null ? 'Nueva' : 'Vista',
        style: const TextStyle(color: Color(0xFF8B98AD)),
      ),
    );
  }

  Future<void> _load() async {
    try {
      final result = await _repository.fetchNotifications();
      await _repository.markNotificationsRead();
      if (mounted) {
        setState(() {
          _items = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onSignOut});
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final displayName = user?.userMetadata?['display_name'] as String?;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text(
            'Mi perfil',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 45,
                  child: Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: Color(0xFF8290A8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName?.isNotEmpty == true ? displayName! : 'CloUP BI',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172943),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Color(0xFF8B98AD)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Editar perfil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Post {
  Post({
    required this.id,
    required this.author,
    required this.handle,
    required this.time,
    required this.text,
    required this.likes,
    this.image,
    this.tag,
    this.authorId,
  });
  final String id;
  final String author;
  final String handle;
  final String time;
  final String text;
  final String? image;
  final String? tag;
  final String? authorId;
  int likes;
  bool liked = false;

  factory Post.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] is Map<String, dynamic>
        ? map['profiles'] as Map<String, dynamic>
        : <String, dynamic>{};
    final created = DateTime.tryParse(map['created_at']?.toString() ?? '')
        ?.toLocal();
    return Post(
      id: map['id'].toString(),
      author: (profile['display_name'] as String?)?.trim().isNotEmpty == true
          ? profile['display_name'] as String
          : (profile['username'] as String? ?? 'CloUP user'),
      handle: profile['username'] as String? ?? 'usuario',
      time: _relativeTime(created),
      text: map['body']?.toString() ?? '',
      likes: 0,
      image: map['image_url'] as String?,
      tag: map['tag'] as String?,
      authorId: map['author_id'] as String?,
    );
  }

  static String _relativeTime(DateTime? date) {
    if (date == null) return 'ahora';
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'ahora';
    if (difference.inHours < 1) return '${difference.inMinutes} min';
    if (difference.inDays < 1) return '${difference.inHours} h';
    return '${difference.inDays} d';
  }
}
