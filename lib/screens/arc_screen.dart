import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ArcScreen extends StatefulWidget {
  // 本来は共通のデータソースから読み込みますが、
  // 今は CalScreen にあるデータをコンストラクタで受け取る形にします
  final Map<DateTime, String> diaryEntries;

  const ArcScreen({super.key, required this.diaryEntries});

  @override
  State<ArcScreen> createState() => _ArcScreenState();
}

class _ArcScreenState extends State<ArcScreen> {
  // アーカイブなので、最新の月から表示するためにカウントを調整
  final int _itemCount = 24; // 過去2年分を表示

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アーカイブ'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _itemCount,
        itemBuilder: (context, index) {
          // 現在の月から index 分だけ遡った月を計算
          final now = DateTime.now();
          final month = DateTime(now.year, now.month - index, 1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 月のラベル（例：2026年 4月）
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  '${month.year}年 ${month.month}月',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // その月のカレンダーを表示
              TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: month,
                calendarFormat: CalendarFormat.month,
                headerVisible: false, // ヘッダーは上のTextで自作したので不要
                daysOfWeekVisible: true,
                // アーカイブなのでページ移動はさせない（スクロールで見るため）
                availableGestures: AvailableGestures.none,
                calendarBuilders: _buildArcCalendarBuilders(),
                // 曜日の高さなどを詰めてコンパクトに
                rowHeight: 45,
              ),
              const Divider(height: 40), // 月ごとの区切り線
            ],
          );
        },
      ),
    );
  }

  // 絵文字を表示するためのビルダー（CalScreenのものをベースに調整）
  CalendarBuilders _buildArcCalendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        // 日付の時・分・秒をリセットして比較
        final dayKey = DateTime(date.year, date.month, date.day);
        final emoji = widget.diaryEntries[dayKey];

        if (emoji != null) {
          return Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20), // リスト用なので少し小さめに
            ),
          );
        }
        return null;
      },
    );
  }
}
