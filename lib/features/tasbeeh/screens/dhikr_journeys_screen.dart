import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../../core/theme/rushd_colors.dart';
import '../data/repositories/dhikr_journey_repository.dart';
import '../domain/models/dhikr_journey.dart';
import '../../duas/data/repositories/dua_repository.dart';

final dhikrJourneyRepositoryProvider = FutureProvider<DhikrJourneyRepository>((
  ref,
) async {
  final preferences = await SharedPreferences.getInstance();
  return DhikrJourneyRepository(SharedPreferencesStorage(preferences));
});

final dhikrJourneysProvider = FutureProvider<List<DhikrJourney>>((ref) async {
  final repository = await ref.watch(dhikrJourneyRepositoryProvider.future);
  return repository.getJourneys();
});

class DhikrJourneysScreen extends ConsumerWidget {
  const DhikrJourneysScreen({super.key});

  Future<void> _openCreateJourneySheet(BuildContext context, WidgetRef ref) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => const _CreateJourneySheet(),
    );

    if (created == true && context.mounted) {
      ref.invalidate(dhikrJourneysProvider);
    }
  }

  Future<void> _createJourney(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.auto_awesome_rounded, size: 32),
        title: const Text('Begin a Dhikr Journey'),
        content: const Text(
          'Would you like to choose a Dua or Dhikr from the collection, '
          'or create your own recitation journey?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('manual'),
            child: const Text('Create Manually'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop('browse'),
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Browse Duas & Dhikr'),
          ),
        ],
      ),
    );

    if (!context.mounted || choice == null) return;

    if (choice == 'browse') {
      context.push('/duas');
      return;
    }

    if (choice == 'manual') {
      await _openCreateJourneySheet(context, ref);
    }
  }

  Future<void> _deleteJourney(
    BuildContext context,
    WidgetRef ref,
    DhikrJourney journey,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete journey?'),
        content: Text(
          '“${journey.name}” and its saved progress will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final repository = await ref.read(dhikrJourneyRepositoryProvider.future);
      await repository.deleteJourney(journey.id);

      if (context.mounted) {
        ref.invalidate(dhikrJourneysProvider);
      }
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete journey: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeysAsync = ref.watch(dhikrJourneysProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'DHIKR JOURNEYS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'New journey',
            onPressed: () => _createJourney(context, ref),
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createJourney(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Journey'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dhikrJourneysProvider);
          await ref.read(dhikrJourneysProvider.future);
        },
        child: journeysAsync.when(
          loading: () => ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 220),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Center(child: Text('Could not load your journeys')),
              Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(dhikrJourneysProvider),
                  child: const Text('Try again'),
                ),
              ),
            ],
          ),
          data: (journeys) {
            final completed = journeys
                .where((journey) => journey.isCompleted)
                .length;
            final active = journeys.length - completed;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                _JourneyHero(activeCount: active, completedCount: completed),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        journeys.isEmpty
                            ? 'Your first journey'
                            : 'Your journeys',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (journeys.isNotEmpty)
                      Text(
                        '${journeys.length} TOTAL',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? RushdColors.darkTextMuted
                              : RushdColors.lightTextMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (journeys.isEmpty)
                  _EmptyJourneys(onCreate: () => _createJourney(context, ref))
                else
                  ...journeys.map(
                    (journey) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _JourneyCard(
                        journey: journey,
                        onTap: () =>
                            context.push('/tasbeeh/counter/${journey.id}'),
                        onDelete: () => _deleteJourney(context, ref, journey),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CreateJourneySheet extends ConsumerStatefulWidget {
  const _CreateJourneySheet();

  @override
  ConsumerState<_CreateJourneySheet> createState() =>
      _CreateJourneySheetState();
}

class _CreateJourneySheetState extends ConsumerState<_CreateJourneySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController(text: '100');

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      final repository = await ref.read(dhikrJourneyRepositoryProvider.future);

      final journey = DhikrJourney(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        currentCount: 0,
        targetCount: int.parse(_targetController.text.trim()),
        createdAt: DateTime.now(),
      );

      await repository.createJourney(journey);

      if (!mounted) return;

      // The parent refreshes its list after this sheet returns true.
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create journey: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start a Dhikr Journey',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set an intention and a target. Your progress will be saved.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Dhikr name',
                hintText: 'e.g. SubhanAllah',
                prefixIcon: Icon(Icons.spa_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return 'Enter a Dhikr name';
                if (name.length > 60) {
                  return 'Keep the name under 60 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target count',
                hintText: '100',
                prefixIcon: Icon(Icons.flag_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final target = int.tryParse(value?.trim() ?? '');
                if (target == null || target < 1) {
                  return 'Enter a target greater than zero';
                }
                if (target > 10000000) {
                  return 'Target must be 10,000,000 or less';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_saving ? 'Creating...' : 'Begin Journey'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyHero extends StatelessWidget {
  const _JourneyHero({required this.activeCount, required this.completedCount});

  final int activeCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RushdColors.primaryDark,
            RushdColors.primary,
            RushdColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -18,
            child: Icon(
              Icons.spa_outlined,
              size: 130,
              color: Colors.white.withValues(alpha: 0.09),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'YOUR DAILY REMEMBRANCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Dhikr\nJourneys',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Make every remembrance count. Continue where you left off.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _HeroStat(label: 'ACTIVE', count: activeCount),
                  const SizedBox(width: 12),
                  _HeroStat(label: 'COMPLETED', count: completedCount),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.journey,
    required this.onTap,
    required this.onDelete,
  });

  final DhikrJourney journey;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = journey.isCompleted;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: RushdColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      completed
                          ? Icons.check_circle_outline
                          : Icons.spa_outlined,
                      color: RushdColors.primaryLight,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journey.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          completed ? 'Journey completed' : 'Tap to continue',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: completed
                                ? RushdColors.emerald
                                : theme.textTheme.bodySmall?.color?.withValues(
                                    alpha: 0.65,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Journey options',
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 10),
                            Text('Delete journey'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${journey.currentCount}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      ' / ${journey.targetCount}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(journey.progress * 100).round()}%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: RushdColors.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: journey.progress,
                  minHeight: 7,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.35),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completed ? RushdColors.emerald : RushdColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    completed ? Icons.verified_outlined : Icons.flag_outlined,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.65,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      completed
                          ? 'Target reached — Alhamdulillah'
                          : '${journey.remainingCount} repetitions remaining',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyJourneys extends StatelessWidget {
  const _EmptyJourneys({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: RushdColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_outlined,
              size: 38,
              color: RushdColors.primaryLight,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Start Your First Journey',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create a personal Dhikr target, count at your own pace, and return whenever you are ready.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create a Journey'),
          ),
        ],
      ),
    );
  }
}
