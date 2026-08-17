import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import 'home_tab.dart';
import 'level_map_tab.dart';
import 'settings_tab.dart';
import 'shop_tab.dart';
import 'stats_tab.dart';

/// Hosts the five primary tabs behind a single persistent bottom
/// navigation bar. Secondary screens (gameplay, legal, sound
/// settings, etc.) are pushed as routes on top of this shell.
class MainShell extends StatefulWidget {
  final int initialTabIndex;

  const MainShell({super.key, this.initialTabIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialTabIndex;

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AppBackground(
        child: IndexedStack(
          index: _index,
          children: [
            HomeTab(onGoToTab: _goToTab),
            const LevelMapTab(),
            const ShopTab(),
            const StatsTab(),
            const SettingsTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goToTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Levels'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_rounded), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
