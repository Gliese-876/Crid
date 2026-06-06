import 'package:crid/features/settings/data/china_holiday_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'yearly holiday data ignores ordinary weekends and separates adjustments',
    () {
      final schedule = ChinaHolidaySchedule.fromYearlyJson(2026, {
        'code': 0,
        'year': '2026',
        'data': [
          {
            'date': '2026-05-01',
            'type': 2,
            'is_holiday': 1,
            'name': '劳动节（休）',
            'wage': 3,
          },
          {
            'date': '2026-05-03',
            'type': 2,
            'is_holiday': 1,
            'name': '劳动节（休）',
            'wage': 2,
          },
          {
            'date': '2026-05-04',
            'type': 3,
            'is_holiday': 1,
            'name': '劳动节（休）',
            'wage': 2,
          },
          {
            'date': '2026-05-09',
            'type': 4,
            'is_holiday': 0,
            'name': '劳动节（班）',
            'wage': 1,
          },
          {
            'date': '2026-05-10',
            'type': 1,
            'is_holiday': 1,
            'name': '周日',
            'wage': 2,
          },
        ],
      });

      expect(schedule.legalHolidayDates, {'2026-05-01'});
      expect(schedule.adjustedRestDates, {'2026-05-03', '2026-05-04'});
      expect(schedule.makeUpWorkdayDates, {'2026-05-09'});
      expect(schedule.hasData, isTrue);
    },
  );

  test(
    'Timor holiday data separates legal holidays, adjusted rest, and makeup workdays',
    () {
      final schedule = ChinaHolidaySchedule.fromTimorJson(2026, {
        'code': 0,
        'holiday': {
          '05-01': {
            'holiday': true,
            'name': '劳动节',
            'wage': 3,
            'date': '2026-05-01',
          },
          '05-03': {
            'holiday': true,
            'name': '劳动节',
            'wage': 2,
            'date': '2026-05-03',
          },
          '05-09': {
            'holiday': false,
            'name': '劳动节后补班',
            'wage': 1,
            'date': '2026-05-09',
          },
        },
      });

      expect(schedule.legalHolidayDates, contains('2026-05-01'));
      expect(schedule.adjustedRestDates, contains('2026-05-03'));
      expect(schedule.makeUpWorkdayDates, contains('2026-05-09'));
    },
  );

  test('holiday settings hide dates according to adjustment mode', () {
    final schedule = ChinaHolidaySchedule(
      year: 2026,
      legalHolidayDates: {'2026-05-01'},
      adjustedRestDates: {'2026-05-03'},
      makeUpWorkdayDates: {'2026-05-09'},
    );
    const disabled = HolidaySettings(
      hideLegalHolidays: false,
      adjustmentMode: HolidayAdjustmentMode.noAdjustment,
    );
    const noAdjustment = HolidaySettings(
      hideLegalHolidays: true,
      adjustmentMode: HolidayAdjustmentMode.noAdjustment,
    );
    const makeUpWorkdays = HolidaySettings(
      hideLegalHolidays: true,
      adjustmentMode: HolidayAdjustmentMode.makeUpWorkdays,
    );
    const noMakeUpWorkdays = HolidaySettings(
      hideLegalHolidays: true,
      adjustmentMode: HolidayAdjustmentMode.noMakeUpWorkdays,
    );

    expect(schedule.shouldHide(DateTime(2026, 5, 1), disabled), isFalse);
    expect(schedule.shouldHide(DateTime(2026, 5, 1), noAdjustment), isTrue);
    expect(schedule.shouldHide(DateTime(2026, 5, 3), noAdjustment), isFalse);
    expect(schedule.shouldHide(DateTime(2026, 5, 3), makeUpWorkdays), isTrue);
    expect(schedule.shouldHide(DateTime(2026, 5, 9), makeUpWorkdays), isFalse);
    expect(schedule.shouldHide(DateTime(2026, 5, 9), noMakeUpWorkdays), isTrue);
  });

  test(
    'holiday course display modes differ for courses and exams by default',
    () {
      final schedule = ChinaHolidaySchedule(
        year: 2026,
        legalHolidayDates: {'2026-05-01'},
        adjustedRestDates: const {},
        makeUpWorkdayDates: const {},
      );
      final dates = [DateTime(2026, 5, 1)];

      expect(
        holidayCourseDisplayModeForWeekday(
          weekday: 1,
          isExam: false,
          dates: dates,
          settings: HolidaySettings.defaults,
          schedule: schedule,
        ),
        HolidayCourseDisplayMode.muted,
      );
      expect(
        holidayCourseDisplayModeForWeekday(
          weekday: 1,
          isExam: true,
          dates: dates,
          settings: HolidaySettings.defaults,
          schedule: schedule,
        ),
        HolidayCourseDisplayMode.normal,
      );
      expect(
        holidayCourseDisplayModeForWeekday(
          weekday: 1,
          isExam: true,
          dates: dates,
          settings: const HolidaySettings(
            hideLegalHolidays: true,
            adjustmentMode: HolidayAdjustmentMode.noAdjustment,
            examDisplayMode: HolidayCourseDisplayMode.hidden,
          ),
          schedule: schedule,
        ),
        HolidayCourseDisplayMode.hidden,
      );
    },
  );

  test('holiday rest day flags follow adjustment mode', () {
    final schedule = ChinaHolidaySchedule(
      year: 2026,
      legalHolidayDates: {'2026-05-01'},
      adjustedRestDates: {'2026-05-03'},
      makeUpWorkdayDates: {'2026-05-09'},
    );
    final dates = [
      DateTime(2026, 5, 1),
      DateTime(2026, 5, 3),
      DateTime(2026, 5, 9),
    ];

    expect(
      holidayRestDayFlags(
        dates: dates,
        settings: const HolidaySettings(
          hideLegalHolidays: true,
          adjustmentMode: HolidayAdjustmentMode.noAdjustment,
        ),
        schedule: schedule,
      ),
      [true, false, false],
    );
    expect(
      holidayRestDayFlags(
        dates: dates,
        settings: const HolidaySettings(
          hideLegalHolidays: true,
          adjustmentMode: HolidayAdjustmentMode.makeUpWorkdays,
        ),
        schedule: schedule,
      ),
      [true, true, false],
    );
    expect(
      holidayRestDayFlags(
        dates: dates,
        settings: const HolidaySettings(
          hideLegalHolidays: true,
          adjustmentMode: HolidayAdjustmentMode.noMakeUpWorkdays,
        ),
        schedule: schedule,
      ),
      [true, true, true],
    );
  });

  test('service prefers built-in 2026 holiday data', () async {
    SharedPreferences.setMockInitialValues({
      'china_holidays_2026_json': _yearlyHolidayJson(2026),
    });
    var calls = 0;
    final service = ChinaHolidayService(
      retryDelay: Duration.zero,
      fetcher: (uri) async {
        calls++;
        throw const FormatException('online source should not be used');
      },
    );

    final schedule = await service.loadYear(2026);

    expect(calls, 0);
    expect(schedule.legalHolidayDates, contains('2026-05-01'));
    expect(
      schedule.adjustedRestDates,
      containsAll(['2026-05-03', '2026-10-07']),
    );
    expect(
      schedule.makeUpWorkdayDates,
      containsAll(['2026-01-04', '2026-02-14', '2026-10-10']),
    );
    expect(schedule.hasData, isTrue);
  });

  test('service retries a source before falling back', () async {
    SharedPreferences.setMockInitialValues(const {});
    var primaryCalls = 0;
    var fallbackCalls = 0;
    final service = ChinaHolidayService(
      retryDelay: Duration.zero,
      fetcher: (uri) async {
        if (uri.host == 'holiday.ailcc.com') {
          primaryCalls++;
          if (primaryCalls == 1) {
            throw const FormatException('temporary failure');
          }
          return _yearlyHolidayJson(2025);
        }
        fallbackCalls++;
        return _timorHolidayJson(2025);
      },
    );

    final schedule = await service.loadYear(2025);

    expect(primaryCalls, 2);
    expect(fallbackCalls, 0);
    expect(schedule.legalHolidayDates, contains('2025-01-01'));
    expect(schedule.fromCache, isFalse);
  });

  test('service falls back after retrying a failed source', () async {
    SharedPreferences.setMockInitialValues(const {});
    var primaryCalls = 0;
    var fallbackCalls = 0;
    final service = ChinaHolidayService(
      retryDelay: Duration.zero,
      fetcher: (uri) async {
        if (uri.host == 'holiday.ailcc.com') {
          primaryCalls++;
          throw const FormatException('primary unavailable');
        }
        fallbackCalls++;
        return _timorHolidayJson(2025);
      },
    );

    final schedule = await service.loadYear(2025);

    expect(primaryCalls, 2);
    expect(fallbackCalls, 1);
    expect(schedule.legalHolidayDates, contains('2025-01-01'));
    expect(schedule.makeUpWorkdayDates, contains('2025-01-26'));
  });

  test('service uses cached data after all online attempts fail', () async {
    SharedPreferences.setMockInitialValues({
      'china_holidays_2025_json': _yearlyHolidayJson(2025),
      'china_holidays_2025_fetched_at': '2025-01-01T00:00:00.000',
    });
    var calls = 0;
    final service = ChinaHolidayService(
      retryDelay: Duration.zero,
      fetcher: (uri) async {
        calls++;
        throw const FormatException('offline');
      },
    );

    final schedule = await service.loadYear(2025);

    expect(calls, 4);
    expect(schedule.fromCache, isTrue);
    expect(schedule.legalHolidayDates, contains('2025-01-01'));
  });
}

String _yearlyHolidayJson(int year) {
  return '''
{
  "code": 0,
  "year": "$year",
  "data": [
    {
      "date": "$year-01-01",
      "type": 2,
      "is_holiday": 1,
      "name": "元旦",
      "wage": 3
    },
    {
      "date": "$year-01-02",
      "type": 3,
      "is_holiday": 1,
      "name": "元旦调休",
      "wage": 2
    },
    {
      "date": "$year-01-04",
      "type": 4,
      "is_holiday": 0,
      "name": "元旦补班",
      "wage": 1
    }
  ]
}
''';
}

String _timorHolidayJson(int year) {
  return '''
{
  "code": 0,
  "holiday": {
    "01-01": {
      "holiday": true,
      "name": "元旦",
      "wage": 3,
      "date": "$year-01-01"
    },
    "01-26": {
      "holiday": false,
      "name": "春节补班",
      "wage": 1,
      "date": "$year-01-26"
    }
  }
}
''';
}
