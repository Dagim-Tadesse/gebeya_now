import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'sign_in_page.dart';
import 'facebook_home_page.dart';
import 'facebook_friends_page.dart';

class FacebookWatchPage extends StatefulWidget {
  const FacebookWatchPage({super.key});

  @override
  State<FacebookWatchPage> createState() => _FacebookWatchPageState();
}

class _FacebookWatchPageState extends State<FacebookWatchPage> {
  final List<_VideoItem> _videos = List.generate(
    8,
    (i) => _VideoItem(
      title: 'Trending video #${i + 1}',
      channel: 'Popular Page',
      views: (i + 1) * 1234,
      thumbnailUrl: 'https://picsum.photos/id/${1040 + i}/900/600',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(context),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _videos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildVideoCard(_videos[index]),
      ),
      bottomNavigationBar: _buildBottomNav(currentIndex: 2),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          const Text(
            'facebook',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1877F2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search Facebook',
                  hintStyle: TextStyle(color: Color(0xFF65676B)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF65676B)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat, color: Color(0xFF1877F2)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Color(0xFF1877F2)),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Color(0xFF1877F2)),
          tooltip: 'Sign out',
          onPressed: () async {
            await AuthService().signOut();
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildVideoCard(_VideoItem v) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.network(
                  v.thumbnailUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: const Color(0xFFF0F2F5),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, color: Color(0xFF65676B)),
                            SizedBox(width: 8),
                            Text(
                              'Unable to load video thumbnail',
                              style: TextStyle(color: Color(0xFF65676B)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.play_arrow, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Watch', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${v.channel} • ${v.views} views',
                  style: const TextStyle(color: Color(0xFF65676B)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _Action(icon: Icons.thumb_up_outlined, label: 'Like'),
                    _Action(icon: Icons.comment_outlined, label: 'Comment'),
                    _Action(icon: Icons.share, label: 'Share'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav({required int currentIndex}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1877F2),
        unselectedItemColor: const Color(0xFF65676B),
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const FacebookHomePage()),
              );
              break;
            case 1:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const FacebookFriendsPage()),
              );
              break;
            case 2:
              // Already on Watch
              break;
            default:
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Page coming soon')));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Watch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}

class _VideoItem {
  final String title;
  final String channel;
  final int views;
  final String thumbnailUrl;
  const _VideoItem({
    required this.title,
    required this.channel,
    required this.views,
    required this.thumbnailUrl,
  });
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Action({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF65676B), size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF65676B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
