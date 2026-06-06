import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

typedef HolidayJsonFetcher = Future<String> Function(Uri uri);

enum HolidayAdjustmentMode { noAdjustment, makeUpWorkdays, noMakeUpWorkdays }

enum HolidayCourseDisplayMode { normal, muted, hidden }

class HolidaySettings {
  const HolidaySettings({
    required this.hideLegalHolidays,
    required this.adjustmentMode,
    this.courseDisplayMode = HolidayCourseDisplayMode.muted,
    this.examDisplayMode = HolidayCourseDisplayMode.normal,
  });

  static const defaults = HolidaySettings(
    hideLegalHolidays: true,
    adjustmentMode: HolidayAdjustmentMode.noAdjustment,
    courseDisplayMode: HolidayCourseDisplayMode.muted,
    examDisplayMode: HolidayCourseDisplayMode.normal,
  );

  final bool hideLegalHolidays;
  final HolidayAdjustmentMode adjustmentMode;
  final HolidayCourseDisplayMode courseDisplayMode;
  final HolidayCourseDisplayMode examDisplayMode;

  HolidaySettings copyWith({
    bool? hideLegalHolidays,
    HolidayAdjustmentMode? adjustmentMode,
    HolidayCourseDisplayMode? courseDisplayMode,
    HolidayCourseDisplayMode? examDisplayMode,
  }) {
    return HolidaySettings(
      hideLegalHolidays: hideLegalHolidays ?? this.hideLegalHolidays,
      adjustmentMode: adjustmentMode ?? this.adjustmentMode,
      courseDisplayMode: courseDisplayMode ?? this.courseDisplayMode,
      examDisplayMode: examDisplayMode ?? this.examDisplayMode,
    );
  }
}

class ChinaHolidaySchedule {
  const ChinaHolidaySchedule({
    required this.year,
    required this.legalHolidayDates,
    required this.adjustedRestDates,
    required this.makeUpWorkdayDates,
    this.fetchedAt,
    this.fromCache = false,
  });

  factory ChinaHolidaySchedule.empty(int year) {
    return ChinaHolidaySchedule(
      year: year,
      legalHolidayDates: const {},
      adjustedRestDates: const {},
      makeUpWorkdayDates: const {},
    );
  }

  factory ChinaHolidaySchedule.fromTimorJson(
    int year,
    Map<String, Object?> json, {
    DateTime? fetchedAt,
    bool fromCache = false,
  }) {
    final legal = <String>{};
    final adjustedRest = <String>{};
    final makeUpWorkdays = <String>{};
    final holiday = json['holiday'];
    if (holiday is Map<String, Object?>) {
      for (final entry in holiday.entries) {
        final value = entry.value;
        if (value is! Map<String, Object?>) {
          continue;
        }
        final date = _normalizedDate(year, value['date'], fallback: entry.key);
        if (date == null) {
          continue;
        }
        final isHoliday = value['holiday'] == true;
        final wageValue = _intValue(value['wage']) ?? 0;
        if (isHoliday && wageValue >= 3) {
          legal.add(date);
        } else if (isHoliday) {
          adjustedRest.add(date);
        } else {
          makeUpWorkdays.add(date);
        }
      }
    }
    return ChinaHolidaySchedule(
      year: year,
      legalHolidayDates: legal,
      adjustedRestDates: adjustedRest,
      makeUpWorkdayDates: makeUpWorkdays,
      fetchedAt: fetchedAt,
      fromCache: fromCache,
    );
  }

  factory ChinaHolidaySchedule.fromYearlyJson(
    int year,
    Map<String, Object?> json, {
    DateTime? fetchedAt,
    bool fromCache = false,
  }) {
    final data = json['data'];
    if (data is! List<Object?>) {
      return ChinaHolidaySchedule.fromTimorJson(
        year,
        json,
        fetchedAt: fetchedAt,
        fromCache: fromCache,
      );
    }

    final legal = <String>{};
    final adjustedRest = <String>{};
    final makeUpWorkdays = <String>{};
    for (final value in data) {
      if (value is! Map<String, Object?>) {
        continue;
      }
      final date = _normalizedDate(year, value['date']);
      if (date == null) {
        continue;
      }
      final type = _intValue(value['type']);
      final isHoliday = value['is_holiday'] == 1 || value['is_holiday'] == true;
      final wageValue = _intValue(value['wage']);

      if (type == 2 && isHoliday) {
        if (wageValue == null || wageValue >= 3) {
          legal.add(date);
        } else {
          adjustedRest.add(date);
        }
      } else if (type == 3 && isHoliday) {
        adjustedRest.add(date);
      } else if (type == 4) {
        makeUpWorkdays.add(date);
      }
    }

    return ChinaHolidaySchedule(
      year: year,
      legalHolidayDates: legal,
      adjustedRestDates: adjustedRest,
      makeUpWorkdayDates: makeUpWorkdays,
      fetchedAt: fetchedAt,
      fromCache: fromCache,
    );
  }

  final int year;
  final Set<String> legalHolidayDates;
  final Set<String> adjustedRestDates;
  final Set<String> makeUpWorkdayDates;
  final DateTime? fetchedAt;
  final bool fromCache;

  bool get hasData =>
      legalHolidayDates.isNotEmpty ||
      adjustedRestDates.isNotEmpty ||
      makeUpWorkdayDates.isNotEmpty;

  bool shouldHide(DateTime date, HolidaySettings settings) {
    if (!settings.hideLegalHolidays || date.year != year) {
      return false;
    }
    final key = _dateKey(date);
    if (legalHolidayDates.contains(key)) {
      return true;
    }
    return switch (settings.adjustmentMode) {
      HolidayAdjustmentMode.noAdjustment => false,
      HolidayAdjustmentMode.makeUpWorkdays => adjustedRestDates.contains(key),
      HolidayAdjustmentMode.noMakeUpWorkdays =>
        adjustedRestDates.contains(key) || makeUpWorkdayDates.contains(key),
    };
  }
}

List<bool> holidayRestDayFlags({
  required List<DateTime> dates,
  required HolidaySettings settings,
  required ChinaHolidaySchedule schedule,
}) {
  return [for (final date in dates) schedule.shouldHide(date, settings)];
}

HolidayCourseDisplayMode holidayCourseDisplayModeForWeekday({
  required int weekday,
  required bool isExam,
  required List<DateTime> dates,
  required HolidaySettings settings,
  required ChinaHolidaySchedule schedule,
}) {
  if (weekday < 1 || weekday > dates.length) {
    return HolidayCourseDisplayMode.normal;
  }
  if (!schedule.shouldHide(dates[weekday - 1], settings)) {
    return HolidayCourseDisplayMode.normal;
  }
  return isExam ? settings.examDisplayMode : settings.courseDisplayMode;
}

class ChinaHolidayService {
  const ChinaHolidayService({
    this.timeout = const Duration(seconds: 5),
    this.maxAttemptsPerSource = 2,
    this.retryDelay = const Duration(milliseconds: 300),
    HolidayJsonFetcher? fetcher,
  }) : _fetcher = fetcher;

  final Duration timeout;
  final int maxAttemptsPerSource;
  final Duration retryDelay;
  final HolidayJsonFetcher? _fetcher;

  Future<ChinaHolidaySchedule> loadYear(int year) async {
    final builtin = _builtinSchedule(year);
    if (builtin != null) {
      return builtin;
    }

    final preferences = await SharedPreferences.getInstance();
    final jsonKey = _cacheJsonKey(year);
    final fetchedAtKey = _cacheFetchedAtKey(year);

    try {
      final raw = await _fetchYearJson(year);
      final fetchedAt = DateTime.now();
      final schedule = _parseSchedule(year, raw, fetchedAt: fetchedAt);
      if (!schedule.hasData) {
        throw const FormatException('Holiday source returned no yearly data.');
      }
      await preferences.setString(jsonKey, raw);
      await preferences.setString(fetchedAtKey, fetchedAt.toIso8601String());
      return schedule;
    } on Object {
      final cached = preferences.getString(jsonKey);
      if (cached != null && cached.isNotEmpty) {
        return _parseSchedule(
          year,
          cached,
          fetchedAt: DateTime.tryParse(
            preferences.getString(fetchedAtKey) ?? '',
          ),
          fromCache: true,
        );
      }
      return ChinaHolidaySchedule.empty(year);
    }
  }

  Future<String> _fetchYearJson(int year) async {
    Object? lastError;
    final attemptLimit = maxAttemptsPerSource < 1 ? 1 : maxAttemptsPerSource;
    for (final source in _holidaySources) {
      for (var attempt = 1; attempt <= attemptLimit; attempt++) {
        try {
          final raw = await _fetchUri(source.uriForYear(year));
          final schedule = _parseSchedule(year, raw);
          if (schedule.hasData) {
            return raw;
          }
          lastError = FormatException(
            '${source.name} returned no yearly data.',
          );
        } on Object catch (error) {
          lastError = error;
        }
        if (attempt < attemptLimit && retryDelay > Duration.zero) {
          await Future<void>.delayed(_retryDelay(attempt));
        }
      }
    }
    throw HttpException('Holiday sources unavailable: $lastError');
  }

  Future<String> _fetchUri(Uri uri) async {
    final fetcher = _fetcher;
    if (fetcher != null) {
      return fetcher(uri).timeout(timeout);
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri).timeout(timeout);
      final response = await request.close().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        throw const HttpException('Holiday server returned non-200 response.');
      }
      return response.transform(utf8.decoder).join().timeout(timeout);
    } finally {
      client.close(force: true);
    }
  }

  Duration _retryDelay(int completedAttempts) {
    return Duration(
      microseconds: retryDelay.inMicroseconds * completedAttempts,
    );
  }

  ChinaHolidaySchedule _parseSchedule(
    int year,
    String raw, {
    DateTime? fetchedAt,
    bool fromCache = false,
  }) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?> || decoded['code'] != 0) {
      return ChinaHolidaySchedule.empty(year);
    }
    return ChinaHolidaySchedule.fromYearlyJson(
      year,
      decoded,
      fetchedAt: fetchedAt,
      fromCache: fromCache,
    );
  }
}

class _HolidaySource {
  const _HolidaySource({required this.name, required this.uriForYear});

  final String name;
  final Uri Function(int year) uriForYear;
}

final _holidaySources = [
  _HolidaySource(
    name: 'holiday.ailcc.com',
    uriForYear: (year) =>
        Uri.https('holiday.ailcc.com', '/api/holiday/allyear/$year'),
  ),
  _HolidaySource(
    name: 'timor.tech',
    uriForYear: (year) => Uri.https('timor.tech', '/api/holiday/year/$year/', {
      'type': 'Y',
      'week': 'N',
    }),
  ),
];

String _cacheJsonKey(int year) => 'china_holidays_${year}_json';

String _cacheFetchedAtKey(int year) => 'china_holidays_${year}_fetched_at';

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String? _normalizedDate(int year, Object? rawDate, {String? fallback}) {
  final value = rawDate is String && rawDate.trim().isNotEmpty
      ? rawDate.trim()
      : fallback;
  if (value == null || value.isEmpty) {
    return null;
  }
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    return value;
  }
  final parts = value.split('-');
  if (parts.length != 2) {
    return null;
  }
  final month = int.tryParse(parts[0]);
  final day = int.tryParse(parts[1]);
  if (month == null || day == null) {
    return null;
  }
  final monthText = month.toString().padLeft(2, '0');
  final dayText = day.toString().padLeft(2, '0');
  return '$year-$monthText-$dayText';
}

int? _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

ChinaHolidaySchedule? _builtinSchedule(int year) {
  return switch (year) {
    2026 => const ChinaHolidaySchedule(
      year: 2026,
      legalHolidayDates: {
        '2026-01-01',
        '2026-02-16',
        '2026-02-17',
        '2026-02-18',
        '2026-02-19',
        '2026-04-05',
        '2026-05-01',
        '2026-05-02',
        '2026-06-19',
        '2026-09-25',
        '2026-10-01',
        '2026-10-02',
        '2026-10-03',
      },
      adjustedRestDates: {
        '2026-01-02',
        '2026-01-03',
        '2026-02-15',
        '2026-02-20',
        '2026-02-21',
        '2026-02-22',
        '2026-02-23',
        '2026-04-04',
        '2026-04-06',
        '2026-05-03',
        '2026-05-04',
        '2026-05-05',
        '2026-06-20',
        '2026-06-21',
        '2026-09-26',
        '2026-09-27',
        '2026-10-04',
        '2026-10-05',
        '2026-10-06',
        '2026-10-07',
      },
      makeUpWorkdayDates: {
        '2026-01-04',
        '2026-02-14',
        '2026-02-28',
        '2026-05-09',
        '2026-09-20',
        '2026-10-10',
      },
    ),
    _ => null,
  };
}
