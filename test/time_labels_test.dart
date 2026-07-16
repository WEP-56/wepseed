import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wepseed/core/utils/time_labels.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
  });

  test('timelineMonthLabel: 本月 / 上月 / 同年月 / 跨年', () {
    final now = DateTime(2026, 7, 15);

    expect(
      timelineMonthLabel(DateTime(2026, 7, 1), now: now),
      '本月',
    );
    expect(
      timelineMonthLabel(DateTime(2026, 6, 20), now: now),
      '上月',
    );
    expect(
      timelineMonthLabel(DateTime(2026, 3, 1), now: now),
      '3月',
    );
    expect(
      timelineMonthLabel(DateTime(2025, 12, 1), now: now),
      '2025年12月',
    );
  });
}
