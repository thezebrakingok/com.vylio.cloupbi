import 'package:flutter/material.dart';

void main() {
  runApp(const CloUpBiApp());
}

class CloUpBiApp extends StatelessWidget {
  const CloUpBiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF10233F);
    const coral = Color(0xFFFF6B5F);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CloUP BI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: coral,
          brightness: Brightness.light,
          primary: coral,
          secondary: const Color(0xFF5C67F2),
          surface: Colors.white,
        ),
        fontFamily: 'sans',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8FC),
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  final List<Post> _posts = [
    Post(
      id: 1,
      author: 'Sofia Mendes',
      handle: '@sofimendes',
      time: '12 min',
      avatar: 'https://i.pravatar.cc/150?img=47',
      image: 'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=1200&q=80',
      text: 'A veces la mejor parte del viaje es descubrir una esquina que no estaba en el mapa.',
      likes: 248,
      comments: 24,
      tag: '#viajes',
    ),
    Post(
      id: 2,
      author: 'Nico Rojas',
      handle: '@nico.rojas',
      time: '1 h',
      avatar: 'https://i.pravatar.cc/150?img=12',
      image: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1200&q=80',
      text: 'Nuevo espacio, nuevas ideas. ¿Qué están creando hoy?',
      likes: 96,
      comments: 11,
      tag: '#creadores',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      FeedPage(
        posts: _posts,
        onLike: _toggleLike,
        onSave: _toggleSave,
        onCreate: _openComposer,
      ),
      const DiscoverPage(),
      CreatePage(onPostCreated: _addPost),
      const NotificationsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFE1DE),
        height: 74,
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

  void _toggleLike(int id) {
    setState(() {
      final post = _posts.firstWhere((item) => item.id == id);
      post.liked = !post.liked;
      post.likes += post.liked ? 1 : -1;
    });
  }

  void _toggleSave(int id) {
    setState(() {
      final post = _posts.firstWhere((item) => item.id == id);
      post.saved = !post.saved;
    });
  }

  void _addPost(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _posts.insert(
        0,
        Post(
          id: DateTime.now().millisecondsSinceEpoch,
          author: 'Alex Vylio',
          handle: '@alexvylio',
          time: 'ahora',
          avatar: 'https://i.pravatar.cc/150?img=68',
          text: text.trim(),
          likes: 0,
          comments: 0,
          tag: '#mipost',
        ),
      );
      _selectedIndex = 0;
    });
  }

  void _openComposer() {
    setState(() => _selectedIndex = 2);
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    required this.posts,
    required this.onLike,
    required this.onSave,
    required this.onCreate,
  });

  final List<Post> posts;
  final void Function(int id) onLike;
  final void Function(int id) onSave;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFFF7F8FC),
          surfaceTintColor: const Color(0xFFF7F8FC),
          titleSpacing: 20,
          title: const BrandMark(),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mail_outline_rounded),
                  ),
                  Positioned(
                    right: 5,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B5F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(child: StoriesRow(onCreate: onCreate)),
        SliverToBoxAdapter(child: ComposerCard(onTap: onCreate)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          sliver: SliverList.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) =>
                PostCard(post: posts[index], onLike: onLike, onSave: onSave),
          ),
        ),
      ],
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
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
}

class StoriesRow extends StatelessWidget {
  const StoriesRow({super.key, required this.onCreate});
  final VoidCallback onCreate;

  final List<Story> stories = const [
    Story('Tu historia', 'https://i.pravatar.cc/150?img=68', true),
    Story('Sofia', 'https://i.pravatar.cc/150?img=47', false),
    Story('Mateo', 'https://i.pravatar.cc/150?img=11', false),
    Story('Valen', 'https://i.pravatar.cc/150?img=32', false),
    Story('Nico', 'https://i.pravatar.cc/150?img=12', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final story = stories[index];
          return GestureDetector(
            onTap: story.isMine
                ? onCreate
                : () => _showStory(context, story.name),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: story.isMine
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFFFF6B5F), Color(0xFF5C67F2)],
                              ),
                        color: story.isMine ? const Color(0xFFE5E9F2) : null,
                      ),
                      child: CircleAvatar(
                        radius: 31,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF8290A8),
                        ),
                      ),
                    ),
                    if (story.isMine)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B5F),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF7F8FC),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  story.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF40516D),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStory(BuildContext context, String name) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Abriendo la historia de $name')));
  }
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
                '¿Qué estás pensando, Alex?',
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
    required this.onSave,
  });
  final Post post;
  final void Function(int id) onLike;
  final void Function(int id) onSave;

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
                        '${post.handle} · ${post.time}',
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
          const SizedBox(height: 8),
          if (post.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AspectRatio(
                  aspectRatio: 1.55,
                  child: Image.network(
                    post.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Color(0xFFEAEFFC),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 42,
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
                  post.tag,
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
                const SizedBox(width: 6),
                Text(
                  '${post.comments} comentarios',
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
                    onTap: () => onLike(post.id),
                  ),
                ),
                Expanded(
                  child: _PostAction(
                    icon: Icons.mode_comment_outlined,
                    label: 'Comentar',
                    onTap: () => _feedback(context, 'Comentarios próximamente'),
                  ),
                ),
                Expanded(
                  child: _PostAction(
                    icon: Icons.send_outlined,
                    label: 'Compartir',
                    onTap: () => _feedback(context, 'Listo para compartir'),
                  ),
                ),
                Expanded(
                  child: _PostAction(
                    icon: post.saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    label: 'Guardar',
                    active: post.saved,
                    onTap: () => onSave(post.id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _feedback(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
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

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          title: Text(
            'Descubrir',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Busca personas, temas o lugares',
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
                  'Tendencias para ti',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172943),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      [
                            '#viajes',
                            '#fotografia',
                            '#musica',
                            '#creadores',
                            '#cocina',
                            '#diseño',
                          ]
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.white,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 5,
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Personas que podrías seguir',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172943),
                  ),
                ),
                const SizedBox(height: 12),
                const FollowCard(
                  name: 'Lucía Ferrer',
                  handle: '@luciaf',
                  avatar: 'https://i.pravatar.cc/150?img=44',
                ),
                const FollowCard(
                  name: 'Tomás Paz',
                  handle: '@tomas.paz',
                  avatar: 'https://i.pravatar.cc/150?img=13',
                ),
                const FollowCard(
                  name: 'Mia Soler',
                  handle: '@miasoler',
                  avatar: 'https://i.pravatar.cc/150?img=49',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FollowCard extends StatelessWidget {
  const FollowCard({
    super.key,
    required this.name,
    required this.handle,
    required this.avatar,
  });
  final String name;
  final String handle;
  final String avatar;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            child: Icon(Icons.person_rounded, color: Color(0xFF8290A8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  handle,
                  style: const TextStyle(
                    color: Color(0xFF8B98AD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Ahora sigues a $name'))),
            child: const Text('Seguir'),
          ),
        ],
      ),
    ),
  );
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key, required this.onPostCreated});
  final void Function(String text) onPostCreated;

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _controller = TextEditingController();

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
              onPressed: _publish,
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
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                child: Icon(Icons.person_rounded, color: Color(0xFF8290A8)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alex Vylio',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEFFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Público',
                      style: TextStyle(fontSize: 11, color: Color(0xFF5C67F2)),
                    ),
                  ),
                ],
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xFF5C67F2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Añadir a tu publicación',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _CreateOption(icon: Icons.image_outlined, text: 'Foto'),
                    _CreateOption(icon: Icons.videocam_outlined, text: 'Video'),
                    _CreateOption(
                      icon: Icons.location_on_outlined,
                      text: 'Lugar',
                    ),
                    _CreateOption(icon: Icons.tag_rounded, text: 'Tema'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _publish() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe algo antes de publicar')),
      );
      return;
    }
    widget.onPostCreated(_controller.text);
    _controller.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publicación compartida en CloUP BI')),
    );
  }
}

class _CreateOption extends StatelessWidget {
  const _CreateOption({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: const Color(0xFF7B8AA1)),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF7B8AA1)),
        ),
      ],
    ),
  );
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      const SliverAppBar(
        pinned: true,
        title: Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList.list(
          children: const [
            NotificationTile(
              name: 'Sofia Mendes',
              text: 'le dio me gusta a tu publicación',
              time: 'Hace 4 min',
              avatar: 'https://i.pravatar.cc/150?img=47',
              icon: Icons.favorite_rounded,
              color: Color(0xFFFF6B5F),
            ),
            NotificationTile(
              name: 'Nico Rojas',
              text: 'comenzó a seguirte',
              time: 'Hace 32 min',
              avatar: 'https://i.pravatar.cc/150?img=12',
              icon: Icons.person_add_alt_1_rounded,
              color: Color(0xFF5C67F2),
            ),
            NotificationTile(
              name: 'Valen Cruz',
              text: 'comentó: ¡Qué buen lugar!',
              time: 'Ayer',
              avatar: 'https://i.pravatar.cc/150?img=32',
              icon: Icons.mode_comment_rounded,
              color: Color(0xFFFFB04A),
            ),
          ],
        ),
      ),
    ],
  );
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.name,
    required this.text,
    required this.time,
    required this.avatar,
    required this.icon,
    required this.color,
  });
  final String name, text, time, avatar;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 24,
                child: Icon(Icons.person_rounded, color: Color(0xFF8290A8)),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(icon, size: 11, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF53627A), height: 1.35),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172943),
                    ),
                  ),
                  TextSpan(text: ' $text\n'),
                  TextSpan(
                    text: time,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9AA5B5),
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
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
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
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                const Text(
                  'Alex Vylio',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172943),
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  '@alexvylio',
                  style: TextStyle(color: Color(0xFF8B98AD)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Creando momentos, compartiendo ideas y descubriendo lo que nos conecta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF53627A), height: 1.35),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(number: '128', label: 'Publicaciones'),
                    _Stat(number: '2.4k', label: 'Seguidores'),
                    _Stat(number: '386', label: 'Siguiendo'),
                  ],
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          sliver: SliverGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            children: const [
              _GridPhoto(
                url: 'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=500&q=70',
              ),
              _GridPhoto(
                url: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=500&q=70',
              ),
              _GridPhoto(
                url: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=500&q=70',
              ),
              _GridPhoto(
                url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&q=70',
              ),
              _GridPhoto(
                url: 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=500&q=70',
              ),
              _GridPhoto(
                url: 'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=500&q=70',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.number, required this.label});
  final String number, label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF172943),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8B98AD)),
        ),
      ],
    );
  }
}

class _GridPhoto extends StatelessWidget {
  const _GridPhoto({required this.url});
  final String url;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFFEAEFFC)),
    ),
  );
}

class Post {
  Post({
    required this.id,
    required this.author,
    required this.handle,
    required this.time,
    required this.avatar,
    required this.text,
    required this.likes,
    required this.comments,
    required this.tag,
    this.image,
  });
  final int id;
  final String author, handle, time, avatar, text, tag;
  final String? image;
  int likes, comments;
  bool liked = false;
  bool saved = false;
}

class Story {
  const Story(this.name, this.avatar, this.isMine);
  final String name, avatar;
  final bool isMine;
}
