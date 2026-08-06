import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My First Flutter UI',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const ReferenceLayoutPage()
    );
  }
}

class ReferenceLayoutPage extends StatelessWidget {
  const ReferenceLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Outer gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFC857),
              Color(0xFFFF5FA2),
              Color(0xFF7B61FF),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          // Mock Phone Screen Container
          child: Container(
            width: 320,
            height: 650,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 24,
                  offset: Offset(0, 14),
                ),
              ],
              border: Border.all(color: Colors.black87, width: 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Column(
                children: [
                  _TopBar(),
                  const Divider(height: 1, thickness: 1),
                  _ProfileRow(),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6D5DF6),
                            Color(0xFFFF5FA2),
                            Color(0xFFFFC857),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  _ActionArea(),
                  _BottomNav(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical:10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Instagram',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Icon(Icons.favorite_border, size:26),
                SizedBox(width: 12),
                Icon(Icons.send_outlined, size: 26),
              ]
            )
          ]
        )
      )
    );
  }
}

class _ProfileRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFFE9D2FF),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: const Text(
              'username',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.more_vert, size:22)
        ],
      ),
    );
  }
}

class _ActionArea extends StatelessWidget {
  const _ActionArea();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 26),
              SizedBox(width: 10),
              Icon(Icons.chat_bubble_outline, size: 24),
              SizedBox(width: 10),
              Icon(Icons.send_outlined, size: 24),
              Spacer(), // Pushes the bookmark icon to the far right
              Icon(Icons.bookmark_border, size: 24),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '10547 Likes',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6),
          Text(
            '@username   Lorem ipsum dolor sit amet, consectetur',
            style: TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6),
          Text(
            '#lorem  #ipsum  #dolor  #sit  #amet  #consectetur',
            style: TextStyle(fontSize: 10, color: Colors.blueGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.home_filled, size: 28),
          Icon(Icons.search, size: 28),
          Icon(Icons.add_box_outlined, size: 28),
          Icon(Icons.video_library_outlined, size: 28),
          Icon(Icons.person_outline, size: 28),
        ]
      ),
    );
  }
}