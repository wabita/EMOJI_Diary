import 'package:flutter/material.dart';

import 'screens/arc_screen.dart';
import 'screens/cal_screen.dart';

enum AppTab { cal, arc, timeline, profile }

class NaviRoot extends StatefulWidget {
  const NaviRoot({super.key});
  @override
  State<NaviRoot> createState() => _NaviRootState();
}

class _NaviRootState extends State<NaviRoot> {
  final GlobalKey<CalScreenState> _calKey = GlobalKey();
  AppTab _currentTab = AppTab.cal;
  bool _showDates = true;

  final Map<DateTime, String> _dummyData = {
    DateTime(2025, 9, 1): '🎂',
    // ...
  };

  List<Widget> _buildPages() {
    return [
      CalScreen(key: _calKey, showDates: _showDates),
      ArcScreen(diaryEntries: _dummyData),
      const Center(child: Text('タイムライン')),
      const Center(child: Text('プロフィール')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji Diary'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_currentTab == AppTab.cal)
            IconButton(
              onPressed: () => setState(() => _showDates = !_showDates),
              icon: Icon(_showDates ? Icons.visibility : Icons.visibility_off),
            ),
        ],
      ),
      body: IndexedStack(index: _currentTab.index, children: _buildPages()),

      // 真ん中の投稿ボタン
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          shape: const CircleBorder(),

          onPressed: () {
            setState(() => _currentTab = AppTab.cal);
            Future.microtask(() {
              _calKey.currentState?.triggerTodayAction();
            });
          },
          child: const Icon(Icons.add_reaction, size: 34),
        ),
      ),

      // 下部のナビゲーションバー
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabButton(AppTab.cal, Icons.calendar_month),
            _buildTabButton(AppTab.arc, Icons.view_headline),
            const SizedBox(width: 48), // FAB用のスペース
            _buildTabButton(AppTab.timeline, Icons.group),
            _buildTabButton(AppTab.profile, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(AppTab tab, IconData icon) {
    final isSelected = _currentTab == tab;
    return IconButton(
      iconSize: 30,
      icon: Icon(icon, color: isSelected ? Colors.cyan : Colors.grey),
      onPressed: () => setState(() => _currentTab = tab),
    );
  }
}
