import 'package:intl/intl.dart';

String relativeTime(DateTime time, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final diff = n.difference(time);

  if (diff.inSeconds < 60) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
  if (diff.inHours < 24) return '${diff.inHours} 小时前';
  if (diff.inDays == 1) return '昨天';
  if (diff.inDays < 7) return '${diff.inDays} 天前';
  return DateFormat('M月d日').format(time);
}

String timelineDayLabel(DateTime time, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final day = DateTime(time.year, time.month, time.day);
  final diff = today.difference(day).inDays;

  if (diff == 0) return '今天';
  if (diff == 1) return '昨天';
  if (diff < 7) return DateFormat('EEEE', 'zh_CN').format(time);
  return DateFormat('M月d日').format(time);
}

/// New 流时间轴：按自然月（本地），近期用「本月/上月」。
String timelineMonthLabel(DateTime time, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final thisMonth = DateTime(n.year, n.month);
  final month = DateTime(time.year, time.month);
  final diffMonths =
      (thisMonth.year - month.year) * 12 + (thisMonth.month - month.month);

  if (diffMonths == 0) return '本月';
  if (diffMonths == 1) return '上月';
  if (month.year == n.year) return DateFormat('M月', 'zh_CN').format(time);
  return DateFormat('yyyy年M月', 'zh_CN').format(time);
}

String clockLabel(DateTime time) => DateFormat('HH:mm').format(time);
