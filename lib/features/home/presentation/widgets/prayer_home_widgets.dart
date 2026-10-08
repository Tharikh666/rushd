
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/rushd_colors.dart';
import '../../domain/entities/prayer_time.dart';
import '../providers/home_providers.dart';

class PrayerHomeHeroCard extends ConsumerWidget {
  const PrayerHomeHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerStateProvider);

    return prayerState.when(
      loading: () => const _PrayerLoadingHero(),
      error: (error, _) => _PrayerErrorHero(message: error.toString()),
      data: (state) => _PrayerHeroContent(state: state),
    );
  }
}

class _PrayerHeroContent extends StatelessWidget {
  const _PrayerHeroContent({
    required this.state,
  });

  final PrayerState state;

  @override
  Widget build(BuildContext context) {
    final nextPrayer = state.nextPrayer;

    return _HeroContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'NEXT PRAYER',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            nextPrayer.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nextPrayer.arabicName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(nextPrayer.time),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _formatRemaining(state.remaining),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _HeroPill(
            icon: Icons.notifications_none_rounded,
            label: 'Prayer reminder',
          ),
          const SizedBox(height: 20),
          Row(
            children: state.prayers.map((prayer) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _PrayerMiniTime(
                    prayer: prayer,
                    isNext: prayer.type == nextPrayer.type,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class PrayerHomeTimeline extends ConsumerWidget {
  const PrayerHomeTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerStateProvider);

    return prayerState.when(
      loading: () => const _TimelineLoading(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Unable to load prayer times.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (state) => _PrayerTimelineContent(state: state),
    );
  }
}

class _PrayerTimelineContent extends StatelessWidget {
  const _PrayerTimelineContent({
    required this.state,
  });

  final PrayerState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: state.prayers.map((prayer) {
        final isCurrent = state.currentPrayer?.type == prayer.type;
        final isNext = state.nextPrayer.type == prayer.type;

        return _PrayerTimelineRow(
          prayer: prayer,
          isCurrent: isCurrent,
          isNext: isNext,
        );
      }).toList(),
    );
  }
}

class _PrayerTimelineRow extends StatelessWidget {
  const _PrayerTimelineRow({
    required this.prayer,
    required this.isCurrent,
    required this.isNext,
  });

  final PrayerTime prayer;
  final bool isCurrent;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isCurrent || isNext
        ? RushdColors.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCurrent || isNext
                  ? RushdColors.primary.withValues(alpha: 0.10)
                  : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForPrayer(prayer.type),
              size: 20,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight:
                    isCurrent || isNext ? FontWeight.w700 : null,
                  ),
                ),
                Text(
                  prayer.arabicName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(prayer.time),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight:
              isCurrent || isNext ? FontWeight.w700 : FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerMiniTime extends StatelessWidget {
  const _PrayerMiniTime({
    required this.prayer,
    required this.isNext,
  });

  final PrayerTime prayer;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isNext ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: isNext ? 0.28 : 0.12,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            prayer.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _formatTime(prayer.time),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContainer extends StatelessWidget {
  const _HeroContainer({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RushdColors.primary,
            RushdColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -35,
            top: -35,
            child: _HeroDecoration(),
          ),
          child,
        ],
      ),
    );
  }
}

class _HeroDecoration extends StatelessWidget {
  const _HeroDecoration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 28,
        ),
      ),
    );
  }
}

class _PrayerLoadingHero extends StatelessWidget {
  const _PrayerLoadingHero();

  @override
  Widget build(BuildContext context) {
    return _HeroContainer(
      child: SizedBox(
        height: 230,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

class _PrayerErrorHero extends StatelessWidget {
  const _PrayerErrorHero({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return _HeroContainer(
      child: SizedBox(
        height: 230,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_off_outlined,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(height: 12),
              Text(
                'Prayer times unavailable',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineLoading extends StatelessWidget {
  const _TimelineLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hour = time.hour;
  final minute = time.minute;

  final isPm = hour >= 12;
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;

  return '$displayHour:${minute.toString().padLeft(2, '0')} '
      '${isPm ? 'PM' : 'AM'}';
}

String _formatRemaining(Duration duration) {
  if (duration.isNegative) {
    return 'Now';
  }

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}h '
        '${minutes.toString().padLeft(2, '0')}m';
  }

  return '${minutes.toString().padLeft(2, '0')}m';
}

IconData _iconForPrayer(PrayerType type) {
  switch (type) {
    case PrayerType.fajr:
      return Icons.wb_twilight_rounded;
    case PrayerType.sunrise:
      return Icons.wb_sunny_outlined;
    case PrayerType.dhuhr:
      return Icons.light_mode_outlined;
    case PrayerType.asr:
      return Icons.wb_sunny_outlined;
    case PrayerType.maghrib:
      return Icons.nights_stay_outlined;
    case PrayerType.isha:
      return Icons.dark_mode_outlined;
  }
}