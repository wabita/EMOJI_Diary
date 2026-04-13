import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// DateTimeの利便性を上げるための拡張
extension DateTimeExtension on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
}

class CalScreen extends StatefulWidget {
  final bool showDates;
  final bool autoOpenPicker;
  const CalScreen({
    super.key,
    required this.showDates,
    this.autoOpenPicker = false,
  });

  @override
  State<CalScreen> createState() => CalScreenState();
}

class CalScreenState extends State<CalScreen> {
  bool _isDetailView = false; //日付タップで詳細画面を表示するか
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // 日記データ
  final Map<DateTime, String> _diaryEntries = {
    DateTime(2025, 9, 1): '🎂',
    DateTime(2025, 9, 2): '💻',
    DateTime(2025, 9, 15): '🥺',
  };

  @override
  void initState() {
    super.initState();
    if (widget.autoOpenPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _isDetailView = true); // 詳細画面に切り替え
        _showEmojiPicker(); // ピッカー表示
      });
    }
  }

  // NaviRoot呼び出し
  void triggerTodayAction() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _selectedDay = now;
      _focusedDay = now;
      _isDetailView = true; // 詳細画面に切り替え
    });

    // 今日の絵文字がまだ登録されていないか
    if (!_diaryEntries.containsKey(today)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showEmojiPicker();
      });
    }
  }

  void _moveDay(int days) {
    setState(() {
      _selectedDay = _selectedDay!.add(Duration(days: days));
      _focusedDay = _selectedDay!;
    });
  }

  void _addEmoji(String emoji) {
    setState(() {
      _diaryEntries[_selectedDay!.dateOnly] = emoji;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 理由：外側の NaviRoot がすでにそれらを用意してくれているから
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isDetailView ? _buildDailyViewBody() : _buildCalendarGrid(),
          ),
        ),
      ],
    );
  }

  // ヘッダー部分
  Widget _buildHeader() {
    return _buildCustomHeader(
      onBack: _isDetailView
          ? () => setState(() => _isDetailView = false)
          : null,
    );
  }

  // カレンダー画面
  Widget _buildCalendarGrid() {
    return TableCalendar(
      key: const ValueKey('CalendarGrid'),
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      headerVisible: false,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          if (isSameDay(_selectedDay, selectedDay)) {
            _isDetailView = true;
          } else {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          }
        });
      },
      rowHeight: 80.0,
      calendarBuilders: _buildCalendarBuilders(),
      calendarStyle: _buildCalendarStyle(),
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
    );
  }

  // --- ヘッダー（月・年を選択可能） ---
  Widget _buildCustomHeader({VoidCallback? onBack}) {
    final months = List.generate(12, (i) => (i + 1).toString());
    final currentYear = DateTime.now().year;
    final years = List.generate(21, (i) => (currentYear - 10 + i).toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onBack,
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.cyan,
                  size: 28,
                ),
                label: const Text(
                  'Month',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          _buildHeaderCenter(onBack == null, years, months),
        ],
      ),
    );
  }

  Widget _buildHeaderCenter(
    bool isCalendarMode,
    List<String> years,
    List<String> months,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCalendarMode)
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
            _buildDropdown(
              label: '${_focusedDay.year}',
              options: years,
              onSelected: (v) => setState(
                () =>
                    _focusedDay = DateTime(int.parse(v), _focusedDay.month, 1),
              ),
            ),
            const Text(' / '),
            _buildDropdown(
              label: '${_focusedDay.month}',
              options: months,
              onSelected: (v) => setState(
                () => _focusedDay = DateTime(_focusedDay.year, int.parse(v), 1),
              ),
            ),
            if (isCalendarMode)
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
          ],
        ),
        if (isCalendarMode)
          TextButton(
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
            child: const Text(
              'Today',
              style: TextStyle(
                color: Color(0xFF6A498C),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  void _changeMonth(int delta) {
    setState(
      () => _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + delta,
        1,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (ctx) =>
          options.map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$label ▼',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /////////////////////

  // --- カレンダーの装飾 ---
  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        final emoji = _diaryEntries[date.dateOnly];
        if (emoji == null) return null;
        return Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: widget.showDates ? 28 : 36),
          ), // 縦幅を広げたので少し大きくしてもOK
        );
      },
    );
  }

  //メインのカレンダー表示
  CalendarStyle _buildCalendarStyle() {
    final color = widget.showDates ? Colors.black : Colors.transparent;
    return CalendarStyle(
      cellAlignment: Alignment.topCenter,
      defaultTextStyle: TextStyle(color: color),
      weekendTextStyle: TextStyle(
        color: widget.showDates ? Colors.red : Colors.transparent,
      ),
      outsideTextStyle: TextStyle(
        color: widget.showDates ? Colors.black26 : Colors.transparent,
      ),
      todayDecoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      selectedDecoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // --- デイリー詳細のボディ ---
  Widget _buildDailyViewBody() {
    final emoji = _diaryEntries[_selectedDay!.dateOnly];
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final isPast = _selectedDay!.isBefore(DateTime.now().dateOnly);

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
                backgroundColor: Colors.cyan.withValues(alpha: 0.5),
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

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: EmojiPicker(
          onEmojiSelected: (cat, emoji) {
            _addEmoji(emoji.emoji);
            Navigator.pop(context);
          },
          config: const Config(
            emojiViewConfig: EmojiViewConfig(columns: 7, emojiSizeMax: 28),
          ),
        ),
      ),
    );
  }
}
