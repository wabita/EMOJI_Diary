import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalScreen extends StatefulWidget {
  final bool showDates;
  const CalScreen({super.key, required this.showDates});
  @override
  State<CalScreen> createState() => _CalScreenState();
}

class _CalScreenState extends State<CalScreen> {
  bool _isDetailView = false; //日付をタップしたときに詳細画面を表示するかどうか

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // 日記データ
  final Map<DateTime, String> _diaryEntries = {
    DateTime(2025, 9, 1): '🎂',
    DateTime(2025, 9, 2): '💻',
    DateTime(2025, 9, 15): '🥺',
  };
  /*
  @override
  void initState() {
    super.initState();
    // 12ヶ月分（初期位置）にスクロールを合わせるためのコントローラー
    _scrollController = ScrollController(
      initialScrollOffset: 12 * _monthItemHeight,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isScrollMode || !_scrollController.hasClients) return;

    // 現在のスクロール位置から「何番目の月か」を計算
    //(offset + 20) / height
    const double approxMonthHeight = 320.0;
    int index = ((_scrollController.offset + 200) / approxMonthHeight).floor();
    DateTime newMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month - 12 + index,
    );

    // 月が変わった時だけ setState してヘッダーを更新
    if (newMonth.month != _focusedDay.month ||
        newMonth.year != _focusedDay.year) {
      setState(() {
        _focusedDay = newMonth;
      });
    }
  }
    */
  @override
  Widget build(BuildContext context) {
    // 理由：外側の NaviRoot がすでにそれらを用意してくれているから
    return Column(
      children: [
        _buildCustomHeader(
          onBack: _isDetailView
              ? () => setState(() => _isDetailView = false)
              : null,
        ),
        //if (!_isDetailView) _buildDaysOfWeekHeader(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isDetailView ? _buildDailyViewPage() : _buildCalendarGrid(),
          ),
        ),
      ],
    );
  }

  // --- カレンダー画面の構築 ---
  Widget _buildCalendarGrid() {
    return TableCalendar(
      key: const ValueKey('CalendarGrid'),
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      headerVisible: false,
      daysOfWeekVisible: true,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: _onDaySelected,
      rowHeight: 80.0,
      calendarBuilders: _buildCalendarBuilders(),
      calendarStyle: _buildCalendarStyle(),
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
    );
  }

  // --- 詳細画面の構築 ---
  Widget _buildDailyViewPage() {
    return _buildDailyViewBody();
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
  /*
  //カレンダー縦スクロールオプション
  Widget _buildVerticalCalendarList() {
    return ListView.builder(
      key: const ValueKey('VerticalList'),
      controller: _scrollController,
      itemCount: 36,
      itemBuilder: (context, index) {
        final month = DateTime(
          DateTime.now().year,
          DateTime.now().month - 12 + index,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: month,
                calendarFormat: CalendarFormat.month,
                headerVisible: false,
                daysOfWeekVisible: false,
                sixWeekMonthsEnforced: false, // 高さを一定にするため true がおすすめ
                rowHeight: 52,
                availableGestures: AvailableGestures.none,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selected, focused) {
                  if (isSameDay(_selectedDay, selected)) {
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
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }*/

  //固定される曜日ヘッダー
  Widget _buildDaysOfWeekHeader() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: days.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  // 日曜は赤、土曜は青、平日はグレーにするなど
                  color: day == 'Sun'
                      ? Colors.red
                      : (day == 'Sat' ? Colors.blue : Colors.black54),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- カレンダーの装飾 ---
  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        final emoji = _diaryEntries[DateTime(date.year, date.month, date.day)];
        if (emoji != null) {
          if (widget.showDates) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 28), // 縦幅を広げたので少し大きくしてもOK
                ),
              ),
            );
          } else {
            return Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 30), // ★ サイズを思い切って大きく（例：36）
              ),
            );
          }
        }
        return null;
      },
    );
  }

  //メインのカレンダー表示
  CalendarStyle _buildCalendarStyle() {
    //今月の日付の色制御
    final dateTextStyle = TextStyle(
      color: widget.showDates ? Colors.black : Colors.transparent, // オフの時は透明に
    );
    //前後の月の日付制御
    final outDateTextStyle = TextStyle(
      // ONの時は薄いグレー(black26)、OFFの時は透明に
      color: widget.showDates ? Colors.black26 : Colors.transparent,
    );
    return CalendarStyle(
      cellAlignment: Alignment.topCenter,
      cellPadding: const EdgeInsets.only(top: 2),

      defaultTextStyle: TextStyle(
        color: widget.showDates ? Colors.black : Colors.transparent,
      ),
      weekendTextStyle: TextStyle(
        color: widget.showDates ? Colors.red : Colors.transparent,
      ),
      todayTextStyle: TextStyle(
        color: widget.showDates ? Colors.black : Colors.transparent,
        fontWeight: FontWeight.bold,
      ),
      selectedTextStyle: TextStyle(
        color: widget.showDates ? Colors.black : Colors.transparent,
        fontWeight: FontWeight.bold,
      ),

      outsideTextStyle: outDateTextStyle, //前後の月の日付も非表示できるように

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
    double emojiSize = 28;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            bottom: true,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(31, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _addEmoji(emoji.emoji);
                      Navigator.pop(context);
                    },
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        columns: 7,
                        emojiSizeMax: emojiSize,
                      ),
                      checkPlatformCompatibility: true,
                      // 操作バー（青い部分）の見た目を調整したい場合はここ
                      bottomActionBarConfig: const BottomActionBarConfig(
                        backgroundColor: Colors.white, // 背景を白くしてスッキリさせることも可能
                        buttonColor: Colors.transparent,
                        buttonIconColor: Colors.black45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      // 1. すでに選択されている日を再度タップしたなら詳細画面へ
      if (isSameDay(_selectedDay, selectedDay)) {
        _isDetailView = true;
      } else {
        // 2. 違う日をタップしたなら、その日を選択状態にする
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      }
    });
  }
}
