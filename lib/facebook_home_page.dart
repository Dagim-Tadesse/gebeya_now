import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'sign_in_page.dart';

class FacebookHomePage extends StatefulWidget {
  const FacebookHomePage({super.key});

  @override
  State<FacebookHomePage> createState() => _FacebookHomePageState();
}

class _FacebookHomePageState extends State<FacebookHomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _demoImages = const [
    'https://picsum.photos/id/1015/800/600',
    'https://picsum.photos/id/1025/800/600',
    'https://picsum.photos/id/1035/800/600',
    'https://picsum.photos/id/1045/800/600',
    'https://picsum.photos/id/1055/800/600',
    'https://picsum.photos/id/1065/800/600',
    'https://picsum.photos/id/1075/800/600',
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              width: 100,
              height: 40,
              // decoration: BoxDecoration(
              //   color: const Color.fromARGB(255, 255, 255, 255),
              //    borderRadius: BorderRadius.circular(20),
              // ),
              child: const Center(
                child: Text(
                  'facebook',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1877F2),
                  ),
                ),
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
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Create Post Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF1877F2),
                        backgroundImage: AssetImage('assets/images/logo.jpg'),
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
                              hintText: "What's on your mind?",
                              hintStyle: TextStyle(color: Color(0xFF65676B)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: Icons.videocam,
                        label: 'Live',
                        color: Colors.red,
                      ),
                      _buildActionButton(
                        icon: Icons.photo_library,
                        label: 'Photo',
                        color: Colors.green,
                      ),
                      _buildActionButton(
                        icon: Icons.video_call,
                        label: 'Room',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stories Section
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: 6,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCreateStoryCard();
                  }
                  return _buildStoryCard(index);
                },
              ),
            ),

            // News Feed Posts
            _buildPost(
              userName: 'John Doe',
              timeAgo: '2h',
              postText: 'Beautiful view right here!!',
              likes: 123,
              comments: 15,
              shares: 5,
              postImageUrl: 'https://picsum.photos/id/1015/1000/700',
              profileImageUrl: 'https://picsum.photos/id/1005/200/200',
            ),
            _buildPost(
              userName: 'Jane Smith',
              timeAgo: '5h',
              postText: 'me at home with my books be like: ',
              likes: 89,
              comments: 12,
              shares: 3,
              postImageUrl: 'https://picsum.photos/id/1025/1000/700',
              profileImageUrl: 'https://picsum.photos/id/1011/200/200',
            ),
            _buildPost(
              userName: 'Mike Johnson',
              timeAgo: '1d',
              postText: 'Greatest vacation ever! 🏖️',
              likes: 256,
              comments: 34,
              shares: 18,
              postImageUrl: 'https://picsum.photos/id/1035/1000/700',
              profileImageUrl: 'https://picsum.photos/id/1012/200/200',
            ),
            _buildPost(
              userName: 'Sarah Williams',
              timeAgo: '3h',
              postText: 'how do people eve take pics of this, Majestic! ',
              likes: 145,
              comments: 28,
              shares: 7,
              postImageUrl: 'https://picsum.photos/id/1045/1000/700',
              profileImageUrl: 'https://picsum.photos/id/1013/200/200',
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          currentIndex: 0,
          onTap: (index) {},
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
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF65676B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateStoryCard() {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E6EB), width: 1),
        image: const DecorationImage(
          image: AssetImage('assets/images/logo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_circle, color: Color(0xFF1877F2)),
                  SizedBox(height: 4),
                  Text(
                    'Create Story',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(_demoImages[index % _demoImages.length]),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              clipBehavior: Clip.antiAlias,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  _demoImages[(index + 1) % _demoImages.length],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Friend Name',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPost({
    required String userName,
    required String timeAgo,
    required String postText,
    required int likes,
    required int comments,
    required int shares,
    String? postImageUrl,
    String? profileImageUrl,
  }) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1877F2),
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Color(0xFF65676B),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.public,
                          size: 12,
                          color: Color(0xFF65676B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Color(0xFF65676B)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(postText, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 12),
          if (postImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                postImageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (postImageUrl == null)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Color(0xFF65676B)),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.thumb_up, size: 18, color: Color(0xFF1877F2)),
              const SizedBox(width: 4),
              Text(
                '$likes',
                style: const TextStyle(color: Color(0xFF65676B), fontSize: 14),
              ),
              const Spacer(),
              Text(
                '$comments comments',
                style: const TextStyle(color: Color(0xFF65676B), fontSize: 14),
              ),
              const SizedBox(width: 12),
              Text(
                '$shares shares',
                style: const TextStyle(color: Color(0xFF65676B), fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPostActionButton(Icons.thumb_up_outlined, 'Like'),
              _buildPostActionButton(Icons.comment_outlined, 'Comment'),
              _buildPostActionButton(Icons.share, 'Share'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Row(
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
      ),
    );
  }
}
