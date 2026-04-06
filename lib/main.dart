import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.cyan),
      home: const EmojiDiaryPage(),
    );
  }
}

class EmojiDiaryPage extends StatefulWidget {
  const EmojiDiaryPage({super.key});
  @override
  State<EmojiDiaryPage> createState() => _EmojiDiaryPageState();
}

class _EmojiDiaryPageState extends State<EmojiDiaryPage> {
  bool _isDetailView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // 日記データ
  final Map<DateTime, String> _diaryEntries = {
    DateTime(2025, 9, 1): '🎂',
    DateTime(2025, 9, 2): '💻',
    DateTime(2025, 9, 15): '🥺',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Emoji Diary'), centerTitle: true),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isDetailView ? _buildDailyViewPage() : _buildCalendarPage(),
      ),
    );
  }

  // --- カレンダー画面の構築 ---
  Widget _buildCalendarPage() {
    return Column(
      key: const ValueKey('CalendarPage'),
      children: [
        _buildCustomHeader(),
        TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          headerVisible: false,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selected, focused) {
            if (_selectedDay != null && isSameDay(_selectedDay, selected)) {
              setState(() => _isDetailView = true);
            } else {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            }
          },
          calendarBuilders: _buildCalendarBuilders(),
          calendarStyle: _buildCalendarStyle(),
          // スワイプで月を変えた時にヘッダーの文字も連動させる設定
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),
      ],
    );
  }

  // --- 詳細画面の構築 ---
  Widget _buildDailyViewPage() {
    return Column(
      key: const ValueKey('DailyPage'),
      children: [
        _buildCustomHeader(onBack: () => setState(() => _isDetailView = false)),
        Expanded(child: _buildDailyViewBody()),
      ],
    );
  }

  // --- ヘッダー（月・年を選択可能） ---
  Widget _buildCustomHeader({VoidCallback? onBack}) {
    final months = [
      ' 1 ',
      ' 2 ',
      ' 3 ',
      ' 4 ',
      ' 5 ',
      ' 6 ',
      ' 7 ',
      ' 8 ',
      ' 9 ',
      ' 10 ',
      ' 11 ',
      ' 12 ',
    ];
    final years = List.generate(31, (index) => (2000 + index).toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, color: Colors.cyan, size: 28),
                    Text(
                      'Month',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onBack == null)
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          // 1ヶ月前に移動
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                            1,
                          );
                        });
                      },
                    ),
                  const SizedBox(width: 8),

                  // 年の選択ボタン
                  _buildSelectableHeaderButton(
                    label: '${_focusedDay.year} ▼',
                    options: years,
                    onSelected: (String value) {
                      setState(() {
                        _focusedDay = DateTime(
                          int.parse(value),
                          _focusedDay.month,
                          1,
                        );
                      });
                    },
                  ),
                  const Text('　/　'),
                  // 月の選択ボタン
                  _buildSelectableHeaderButton(
                    label: '${months[_focusedDay.month - 1]} ▼',
                    options: months,
                    onSelected: (String value) {
                      final newMonth = months.indexOf(value) + 1;
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, newMonth, 1);
                      });
                    },
                  ),
                  const SizedBox(width: 8),

                  if (onBack == null)
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          // 1ヶ月後に移動
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                            1,
                          );
                        });
                      },
                    ),
                ],
              ),

              if (onBack == null) // カレンダー表示の時だけ
                TextButton(
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromARGB(255, 106, 73, 140),
                      width: 1.5,
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    setState(() {
                      final now = DateTime.now();
                      _focusedDay = now; // 表示を今月に飛ばす
                      _selectedDay = now; // 今日を選択状態にする
                    });
                  },
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: Color.fromARGB(255, 106, 73, 140),

                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // タップして選択できるボタンの定義
  Widget _buildSelectableHeaderButton({
    required String label,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return options.map((String choice) {
          return PopupMenuItem<String>(value: choice, child: Text(choice));
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- カレンダーの装飾 ---
  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        final emoji = _diaryEntries[DateTime(date.year, date.month, date.day)];
        if (emoji != null) {
          return Positioned(
            bottom: 2,
            child: Text(emoji, style: const TextStyle(fontSize: 12)),
          );
        }
        return null;
      },
    );
  }

  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      todayDecoration: BoxDecoration(
        color: Colors.cyan.withOpacity(0.3),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(4),
      ),
      selectedDecoration: BoxDecoration(
        color: Colors.black12,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(4),
      ),
      defaultDecoration: const BoxDecoration(shape: BoxShape.rectangle),
      weekendDecoration: const BoxDecoration(shape: BoxShape.rectangle),
      outsideDecoration: const BoxDecoration(shape: BoxShape.rectangle),
      cellMargin: const EdgeInsets.all(2),
    );
  }

  // --- デイリー詳細のボディ ---
  Widget _buildDailyViewBody() {
    final emoji =
        _diaryEntries[DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        )];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final bool isToday = isSameDay(_selectedDay, now);
    final bool isPast = selectedDate.isBefore(today);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 40),
                onPressed: () => _moveDay(-1),
              ),
              Text(
                '${_selectedDay!.day}',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 40),
                onPressed: () => _moveDay(1),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (emoji != null) ...[
            Text(emoji, style: const TextStyle(fontSize: 80)),
            if (isToday)
              TextButton.icon(
                onPressed: _showEmojiPicker,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('絵文字を変更する'),
                style: TextButton.styleFrom(foregroundColor: Colors.cyan),
              ),
          ] else if (isToday)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.withOpacity(0.5),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showEmojiPicker(),
              child: const Text('今日の思い出絵文字を入力'),
            )
          else if (isPast)
            const Text(
              'この日の記録はありません',
              style: TextStyle(color: Colors.black26, fontSize: 16),
            ),
        ],
      ),
    );
  }

  void _moveDay(int days) {
    setState(() {
      _selectedDay = _selectedDay!.add(Duration(days: days));
      _focusedDay = _selectedDay!;
    });
  }

  void _addEmoji(String emoji) {
    setState(() {
      final key = DateTime(
        _selectedDay!.year,
        _selectedDay!.month,
        _selectedDay!.day,
      );
      _diaryEntries[key] = emoji;
    });
  }

  // --- 絵文字選択シートを表示する関数 ---
  void _showEmojiPicker() {
    // 選択肢となる絵文字リスト
    final List<String> emojis = [
      '😊',
      '🥺',
      '😴',
      '🐱',
      '🍕',
      '🎉',
      '💻',
      '🔥',
      '✨',
      '🌈',
      '🍀',
      '💡',
      '🎵',
      '📘',
      '🏃',
      '💤',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300, // シートの高さ
          child: Column(
            children: [
              const Text(
                '今日の気分は？',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 1行に4つ並べる
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        _addEmoji(emojis[index]); // 絵文字を登録
                        Navigator.pop(context); // シートを閉じる
                      },
                      child: Center(
                        child: Text(
                          emojis[index],
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
