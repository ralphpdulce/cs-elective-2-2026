import 'package:flutter/cupertino.dart';
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
      title: 'Responsive & Adaptive Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE0E0E0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State to track current platform mode
  TargetPlatform _currentPlatform = TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    final isCupertino = _currentPlatform == TargetPlatform.iOS;

    // Apply active platform target across app widgets
    return Theme(
      data: Theme.of(context).copyWith(platform: _currentPlatform),
      child: Scaffold(
        // Floating button to toggle platform mode on live preview
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: isCupertino ? Colors.blue : Colors.black87,
          foregroundColor: Colors.white,
          icon: Icon(isCupertino ? Icons.phone_iphone : Icons.phone_android),
          label: Text(
            isCupertino ? 'Mode: iOS (Cupertino)' : 'Mode: Android (Material)',
          ),
          onPressed: () {
            setState(() {
              _currentPlatform = isCupertino
                  ? TargetPlatform.android
                  : TargetPlatform.iOS;
            });
          },
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;

            // Cupertino/iOS Navigation wrapper
            if (isCupertino && !isDesktop) {
              return CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: Text(
                    'responsivedashboard (${_currentPlatform.name})',
                  ),
                  backgroundColor: const Color(0xFF2C2C2C),
                ),
                child: SafeArea(child: _buildLayout(constraints)),
              );
            }

            // Material/Android Navigation wrapper
            return Scaffold(
              appBar: isDesktop
                  ? null
                  : AppBar(
                      title: Text(
                        'responsivedashboard (${_currentPlatform.name})',
                      ),
                      elevation: 0,
                    ),
              drawer: isDesktop ? null : const _AppDrawer(),
              body: _buildLayout(constraints),
            );
          },
        ),
      ),
    );
  }

  // 1. Responsive Layout Switcher
  Widget _buildLayout(BoxConstraints constraints) {
    if (constraints.maxWidth < 600) {
      return _MobileLayout(platform: _currentPlatform);
    } else if (constraints.maxWidth < 1100) {
      return _TabletLayout(platform: _currentPlatform);
    } else {
      return _DesktopLayout(platform: _currentPlatform);
    }
  }
}

// --- Wireframe Reusable Boxes ---

class _WireframeBox extends StatelessWidget {
  final double? height;
  final Widget? child;

  const _WireframeBox({this.height, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFC4C4C4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

// --- Drawer Navigation Menu ---

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFFD9D9D9),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.favorite, size: 50, color: Colors.black87),
          const SizedBox(height: 40),
          _drawerItem(Icons.home, 'D A S H B O A R D'),
          _drawerItem(Icons.settings, 'S E T T I N G S'),
          _drawerItem(Icons.info, 'A B O U T'),
          _drawerItem(Icons.logout, 'L O G O U T'),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Platform-Adaptive Button Component ---

class _AdaptiveButton extends StatelessWidget {
  final String label;
  final TargetPlatform platform;

  const _AdaptiveButton({required this.label, required this.platform});

  @override
  Widget build(BuildContext context) {
    if (platform == TargetPlatform.iOS) {
      return CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: () {},
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: () {},
      child: Text(label),
    );
  }
}

// --- Responsive Layout Variants ---

class _MobileLayout extends StatelessWidget {
  final TargetPlatform platform;
  const _MobileLayout({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _WireframeBox(),
                _WireframeBox(),
                _WireframeBox(),
                _WireframeBox(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const _WireframeBox(height: 50),
            ),
          ),
          const SizedBox(height: 8),
          _AdaptiveButton(label: 'Mobile Adaptive Action', platform: platform),
        ],
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final TargetPlatform platform;
  const _TabletLayout({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              children: const [
                Expanded(child: _WireframeBox()),
                SizedBox(width: 10),
                Expanded(child: _WireframeBox()),
                SizedBox(width: 10),
                Expanded(child: _WireframeBox()),
                SizedBox(width: 10),
                Expanded(child: _WireframeBox()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, __) => const _WireframeBox(height: 60),
            ),
          ),
          const SizedBox(height: 8),
          _AdaptiveButton(label: 'Tablet Adaptive Action', platform: platform),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final TargetPlatform platform;
  const _DesktopLayout({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _AppDrawer(),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Container(
                  height: 35,
                  width: double.infinity,
                  color: const Color(0xFF2C2C2C),
                  alignment: Alignment.center,
                  child: Text(
                    'responsivedashboard (${platform.name})',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: Row(
                    children: const [
                      Expanded(child: _WireframeBox()),
                      SizedBox(width: 10),
                      Expanded(child: _WireframeBox()),
                      SizedBox(width: 10),
                      Expanded(child: _WireframeBox()),
                      SizedBox(width: 10),
                      Expanded(child: _WireframeBox()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, __) => const _WireframeBox(height: 50),
                  ),
                ),
                const SizedBox(height: 8),
                _AdaptiveButton(
                  label: 'Desktop Adaptive Action',
                  platform: platform,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 59.0, right: 12.0, bottom: 12.0),
            child: Column(
              children: const [
                Expanded(flex: 2, child: _WireframeBox()),
                SizedBox(height: 10),
                Expanded(flex: 1, child: _WireframeBox()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}