import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'sign_in_page.dart';
import 'facebook_home_page.dart';
import 'facebook_watch_page.dart';

class FacebookFriendsPage extends StatefulWidget {
  const FacebookFriendsPage({super.key});

  @override
  State<FacebookFriendsPage> createState() => _FacebookFriendsPageState();
}

class _FacebookFriendsPageState extends State<FacebookFriendsPage> {
  final List<_FriendRequest> _requests = const [
    _FriendRequest(
      name: 'Emily Clark',
      mutual: 12,
      avatarUrl: 'https://picsum.photos/id/1011/200/200',
    ),
    _FriendRequest(
      name: 'Robert Miles',
      mutual: 5,
      avatarUrl: 'https://picsum.photos/id/1012/200/200',
    ),
    _FriendRequest(
      name: 'Ava Johnson',
      mutual: 3,
      avatarUrl: 'https://picsum.photos/id/1013/200/200',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            'Friend requests',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._requests.map(_buildRequestCard),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'People you may know',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _buildSuggestionCard(index);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(currentIndex: 1),
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

  Widget _buildRequestCard(_FriendRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(req.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${req.mutual} mutual friends',
                  style: const TextStyle(color: Color(0xFF65676B)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                        ),
                        onPressed: () {},
                        child: const Text('Confirm'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(int index) {
    final img = 'https://picsum.photos/id/${1020 + index}/300/300';
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(img, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Suggested Friend',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '2 mutual friends',
              style: TextStyle(color: Color(0xFF65676B), fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                minimumSize: const Size(double.infinity, 36),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () {},
              child: const Text('Add Friend'),
            ),
          ),
          const SizedBox(height: 8),
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
              // Already on Friends
              break;
            case 2:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const FacebookWatchPage()),
              );
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

class _FriendRequest {
  final String name;
  final int mutual;
  final String avatarUrl;
  const _FriendRequest({
    required this.name,
    required this.mutual,
    required this.avatarUrl,
  });
}
