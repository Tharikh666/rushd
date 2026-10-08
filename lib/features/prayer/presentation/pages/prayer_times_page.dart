import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/domain/entities/prayer_time.dart';

import '../../../home/presentation/providers/home_providers.dart';

class PrayerTimesPage extends ConsumerWidget {
  const PrayerTimesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
      ),
      body: prayerState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                _formatDate(state.today.date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.today.timezone,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              ...state.today.allTimes.map(
                    (prayer) => _PrayerTimeTile(
                  prayer: prayer,
                  isCurrent:
                  state.currentPrayer?.type == prayer.type,
                  isNext:
                  state.nextPrayer.type == prayer.type,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _PrayerTimeTile extends StatelessWidget {
  const _PrayerTimeTile({
    required this.prayer,
    required this.isCurrent,
    required this.isNext,
  });

  final PrayerTime prayer;
  final bool isCurrent;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final highlighted = isCurrent || isNext;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.08)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: highlighted
            ? Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.20),
        )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight:
                    highlighted ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  prayer.arabicName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (isCurrent)
            const _StatusBadge(label: 'NOW')
          else if (isNext)
            const _StatusBadge(label: 'NEXT'),
          const SizedBox(width: 12),
          Text(
            _formatTime(prayer.time),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
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

    return '$displayHour:${minute.toString().padLeft(2, '0')} '
        '${isPm ? 'PM' : 'AM'}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}