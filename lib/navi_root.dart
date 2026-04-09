import 'package:flutter/material.dart';

import 'screens/cal_screen.dart';

class NaviRoot extends StatefulWidget {
  const NaviRoot({super.key});
  @override
  State<NaviRoot> createState() => _NaviRootState();
}

class _NaviRootState extends State<NaviRoot> {
  final GlobalKey<CalScreenState> _calKey = GlobalKey();
  int _currentIndex = 0;
  bool _showDates = true;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CalScreen(key: _calKey, showDates: _showDates),
      const Center(child: Text('アーカイブ')),
      const Center(child: Text('タイムライン')),
      const Center(child: Text('プロフィール')),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji Diary'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_currentIndex == 0) // カレンダー画面の時だけ表示
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: () => setState(() => _showDates = !_showDates),
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _showDates ? Icons.block : Icons.radio_button_unchecked,
                      color: _showDates ? Colors.red : Colors.green,
                      size: 28,
                    ),
                    const Text(
                      '1',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: pages[_currentIndex],
      // 真ん中の投稿ボタン
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // もし他のタブにいたら、カレンダータブに切り替え
          setState(() {
            _currentIndex = 0;
          });

          // CalScreenの関数を実行する
          // currentState が null でないことを確認して呼び出し
          Future.microtask(() {
            _calKey.currentState?.triggerTodayAction();
          });
        },
        child: const Icon(Icons.add_reaction),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.calendar_month,
                color: _currentIndex == 0 ? Colors.cyan : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            IconButton(
              icon: Icon(
                Icons.view_headline,
                color: _currentIndex == 1 ? Colors.cyan : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
            const SizedBox(width: 40), // ボタン用の隙間
            IconButton(
              icon: Icon(
                Icons.group,
                color: _currentIndex == 2 ? Colors.cyan : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 2),
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: _currentIndex == 3 ? Colors.cyan : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}
