import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rushd/features/home/domain/entities/prayer_time.dart';

import '../../../../core/location/location_models.dart';
import '../../../../core/location/location_providers.dart';
import '../../../../core/network/grpc_channel_provider.dart';
import '../../../../core/result/app_result.dart';
import '../../../../generated/prayer/v1/prayer.pbgrpc.dart' hide PrayerTime;
import '../../data/datasources/prayer_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/prayer_calculation_settings.dart';
import '../../domain/repositories/prayer_repository.dart';

final prayerCalculationSettingsProvider =
Provider<PrayerCalculationSettings>(
      (ref) {
    return PrayerCalculationSettings.defaultSettings;
  },
);

final prayerRemoteDataSourceProvider =
Provider<PrayerRemoteDataSource>(
      (ref) {
    final channel =
    ref.watch(grpcChannelProvider);

    return PrayerRemoteDataSource(
      PrayerServiceClient(channel),
    );
  },
);

final prayerRepositoryProvider =
Provider<PrayerRepository>(
      (ref) {
    return PrayerRepositoryImpl(
      ref.watch(
        prayerRemoteDataSourceProvider,
      ),
    );
  },
);

class PrayerState {
  const PrayerState({
    required this.today,
    required this.tomorrow,
    required this.now,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.remaining,
  });

  final PrayerSchedule today;
  final PrayerSchedule tomorrow;

  final DateTime now;

  final PrayerTime? currentPrayer;
  final PrayerTime nextPrayer;

  final Duration remaining;

  List<PrayerTime> get prayers =>
      today.obligatoryPrayers;
}

final prayerStateProvider =
StreamProvider.autoDispose<PrayerState>(
      (ref) async* {
    final location =
    await ref.watch(
      currentLocationProvider.future,
    );

    final timezone =
    await ref.watch(
      localTimezoneProvider.future,
    );

    final settings =
    ref.watch(
      prayerCalculationSettingsProvider,
    );

    final repository =
    ref.watch(
      prayerRepositoryProvider,
    );

    var now = DateTime.now();

    var today = await _loadSchedule(
      repository: repository,
      location: location,
      timezone: timezone,
      date: now,
      settings: settings,
    );

    var tomorrow = await _loadSchedule(
      repository: repository,
      location: location,
      timezone: timezone,
      date: now.add(
        const Duration(days: 1),
      ),
      settings: settings,
    );

    var loadedDay = _dateOnly(now);

    while (true) {
      now = DateTime.now();

      final currentDay = _dateOnly(now);

      if (currentDay != loadedDay) {
        today = tomorrow;

        tomorrow = await _loadSchedule(
          repository: repository,
          location: location,
          timezone: timezone,
          date: now.add(
            const Duration(days: 1),
          ),
          settings: settings,
        );

        loadedDay = currentDay;
      }

      yield _buildPrayerState(
        now: now,
        today: today,
        tomorrow: tomorrow,
      );

      await Future<void>.delayed(
        const Duration(seconds: 1),
      );
    }
  },
);

Future<PrayerSchedule> _loadSchedule({
  required PrayerRepository repository,
  required LocationCoordinates location,
  required String timezone,
  required DateTime date,
  required PrayerCalculationSettings settings,
}) async {
  final result =
  await repository.getPrayerSchedule(
    date: date,
    latitude: location.latitude,
    longitude: location.longitude,
    timezone: timezone,
    settings: settings,
  );

  if (result is AppSuccess<PrayerSchedule>) {
    return result.value;
  }

  if (result is AppFailure<PrayerSchedule>) {
    throw Exception(result.message);
  }

  throw StateError(
    'Unknown prayer repository result.',
  );
}

PrayerState _buildPrayerState({
  required DateTime now,
  required PrayerSchedule today,
  required PrayerSchedule tomorrow,
}) {
  final prayers = today.obligatoryPrayers;

  for (var index = 0;
  index < prayers.length;
  index++) {
    final prayer = prayers[index];

    if (now.isBefore(prayer.time)) {
      return PrayerState(
        today: today,
        tomorrow: tomorrow,
        now: now,
        currentPrayer:
        index == 0
            ? null
            : prayers[index - 1],
        nextPrayer: prayer,
        remaining:
        prayer.time.difference(now),
      );
    }
  }

  return PrayerState(
    today: today,
    tomorrow: tomorrow,
    now: now,
    currentPrayer: today.isha,
    nextPrayer: tomorrow.fajr,
    remaining:
    tomorrow.fajr.time.difference(now),
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(
    value.year,
    value.month,
    value.day,
  );
}