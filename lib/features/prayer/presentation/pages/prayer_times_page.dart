import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../home/domain/entities/prayer_time.dart';
import '../../../home/presentation/providers/home_providers.dart';

class PrayerTimesPage extends ConsumerWidget {
  const PrayerTimesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerStateProvider);
    final todayDate = DateTime.now();
    final todayDayName = DateFormat('EEEE').format(todayDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Luxury slate base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PRAYER TIMINGS',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
          ),
        ),
      ),
      body: prayerState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0F766E)),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ),
        data: (state) {
          final current = state.currentPrayer;
          final next = state.nextPrayer;

          // Get backend sunrise object
          final sunrise = state.today.sunrise;

          // Filter out sunrise from the regular prayer times list to avoid duplication
          final prayersList = state.today.allTimes
              .where((p) => p.name.toLowerCase() != 'sunrise')
              .toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HERO CARD (Next Salah Summary)
                _PrayerHeroCard(
                  currentPrayer: current,
                  nextPrayer: next,
                  timezone: state.today.timezone,
                ),
                const SizedBox(height: 36),

                /// SECTION HEADER WITH DATE & LOCATION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today • $todayDayName (${todayDate.day}/${todayDate.month})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        state.today.timezone.isNotEmpty
                            ? state.today.timezone
                            : 'Local Time',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                /// PRAYER LIST & SUNRISE INSERTED AFTER FAJR
                ...prayersList.expand((prayer) {
                  final active = current?.type == prayer.type;
                  final comingUp = next?.type == prayer.type;
                  final assetData = _getPrayerAssetData(prayer.name);

                  List<Widget> widgets = [
                    _PrayerCard(
                      prayer: prayer,
                      isCurrent: active,
                      isNext: comingUp,
                      gradientColors: assetData['gradient'] as List<Color>,
                      watermarkPath: assetData['watermark'] as String,
                    ),
                  ];

                  // Insert Sunrise card immediately after Fajr using backend data
                  if (prayer.name.toLowerCase() == 'fajr' && sunrise != null) {
                    widgets.add(
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D4A87).withOpacity(0.15),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2D4A87),
                                Color(0xFFF59E0B),
                              ], // Fajr blue to Dhuhr golden light
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -10,
                                top: -10,
                                child: Opacity(
                                  opacity: 0.15,
                                  child: SvgPicture.asset(
                                    'assets/icons/prayer_times/fajr.svg',
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          sunrise.name,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            sunrise.arabicName,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontFamily: 'Amiri',
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            _formatTime(sunrise.time),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'End of Fajr Time: ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          _formatTime(sunrise.time),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return widgets;
                }),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _getPrayerAssetData(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return {
          'gradient': [const Color(0xFF2D4A87), const Color(0xFF6B8DD6)],
          'watermark': 'assets/icons/prayer_times/fajr.svg',
        };
      case 'dhuhr':
        return {
          'gradient': [const Color(0xFFFFF7D6), const Color(0xFFFFFFFF)],
          'watermark': 'assets/icons/prayer_times/dhuhr.svg',
        };
      case 'asr':
        return {
          'gradient': [const Color(0xFFFFE7CC), const Color(0xFFFFFFFF)],
          'watermark': 'assets/icons/prayer_times/asr.svg',
        };
      case 'maghrib':
        return {
          'gradient': [const Color(0xFFFF9F68), const Color(0xFFFFD6A5)],
          'watermark': 'assets/icons/prayer_times/maghrib.svg',
        };
      case 'isha':
      default:
        return {
          'gradient': [const Color(0xFF0F172A), const Color(0xFF1E3A8A)],
          'watermark': 'assets/icons/prayer_times/isha.svg',
        };
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
  }
}

class _PrayerHeroCard extends StatelessWidget {
  const _PrayerHeroCard({
    required this.currentPrayer,
    required this.nextPrayer,
    required this.timezone,
  });

  final PrayerTime? currentPrayer;
  final PrayerTime? nextPrayer;
  final String timezone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D534D), Color(0xFF115E59), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (nextPrayer != null)
            Positioned(
              right: -15,
              bottom: -15,
              child: Opacity(
                opacity: 0.10,
                child: SvgPicture.asset(
                  'assets/icons/prayer_times/${nextPrayer!.name.toLowerCase()}.svg',
                  width: 130,
                  height: 130,
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// TOP BADGE & TIMEZONE ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NEXT SALAH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF2DD4BF),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timezone.isNotEmpty ? timezone : 'Local',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// PRAYER NAME & ARABIC
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    nextPrayer?.name ?? 'Prayer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (nextPrayer?.arabicName != null &&
                      nextPrayer!.arabicName.isNotEmpty)
                    Text(
                      nextPrayer!.arabicName,
                      style: const TextStyle(
                        color: Color(0xFF99F6E4),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Amiri',
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              /// BOTTOM SPECULAR TIME PANEL
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          color: Color(0xFF2DD4BF),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          nextPrayer != null
                              ? _formatTime(nextPrayer!.time)
                              : '--:--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    if (currentPrayer != null)
                      Text(
                        'Now: ${currentPrayer!.name}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.prayer,
    required this.isCurrent,
    required this.isNext,
    required this.gradientColors,
    required this.watermarkPath,
  });

  final PrayerTime prayer;
  final bool isCurrent;
  final bool isNext;
  final List<Color> gradientColors;
  final String watermarkPath;

  @override
  Widget build(BuildContext context) {
    final isDarkCard =
        prayer.name.toLowerCase() == 'fajr' ||
        prayer.name.toLowerCase() == 'isha';

    final textColor = isDarkCard ? Colors.white : const Color(0xFF0F172A);
    final secondaryColor = isDarkCard
        ? Colors.white.withOpacity(0.65)
        : const Color(0xFF0F172A).withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? const Color(0xFF0F766E).withOpacity(0.22)
                : const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: isCurrent
                ? (isDarkCard
                      ? Colors.white.withOpacity(0.4)
                      : const Color(0xFF0F766E).withOpacity(0.4))
                : Colors.white.withOpacity(0.15),
            width: isCurrent ? 2.5 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Opacity(
                opacity: isDarkCard ? 0.15 : 0.09,
                child: SvgPicture.asset(
                  watermarkPath,
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          prayer.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            prayer.arabicName,
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatTime(prayer.time),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkCard
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDarkCard
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Azan Time: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _formatTime(prayer.time),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkCard
                            ? Colors.white.withOpacity(0.15)
                            : const Color(0xFF0F766E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isDarkCard
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF0F766E).withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lens_rounded,
                            size: 8,
                            color: isDarkCard
                                ? Colors.white
                                : const Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Current Prayer',
                            style: TextStyle(
                              color: isDarkCard
                                  ? Colors.white
                                  : const Color(0xFF0F766E),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isNext) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xFFF97316).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: Color(0xFFEA580C),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Coming Up Next',
                            style: TextStyle(
                              color: Color(0xFFEA580C),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final isPm = hour >= 12;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
  }
}
