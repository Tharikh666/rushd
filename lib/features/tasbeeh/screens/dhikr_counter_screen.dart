import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/rushd_colors.dart';
import '../../duas/data/repositories/dua_repository.dart';
import '../domain/models/dhikr_journey.dart';
import 'dhikr_journeys_screen.dart';

const Color _kRosePrimary = Color(0xFFCF376A);
const Color _kRoseLight = Color(0xFFF472B6);
const Color _kRoseDark = Color(0xFF9D174D);

class DhikrCounterScreen extends ConsumerStatefulWidget {
  const DhikrCounterScreen({required this.journeyId, super.key});

  final String journeyId;

  @override
  ConsumerState<DhikrCounterScreen> createState() => _DhikrCounterScreenState();
}

class _DhikrCounterScreenState extends ConsumerState<DhikrCounterScreen>
    with TickerProviderStateMixin {
  DhikrJourney? _journey;
  bool _loading = true;
  bool _saving = false;
  bool _animateTap = false;
  bool _completionShown = false;

  late final AnimationController _tapController;
  late final Animation<double> _tapScale;

  int get _count => _journey?.currentCount ?? 0;
  int get _target => _journey?.targetCount ?? 1;

  @override
  void initState() {
    super.initState();

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _tapScale = Tween<double>(begin: 1, end: 1.045).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutBack),
    );

    _loadJourney();
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _loadJourney() async {
    try {
      final repository = await ref.read(dhikrJourneyRepositoryProvider.future);
      final journey = await repository.getJourney(widget.journeyId);

      if (!mounted) return;

      setState(() {
        _journey = journey;
        _loading = false;
      });

      if (journey == null) {
        _showMessage('This Dhikr journey could not be found.');
        return;
      }

      if (journey.isCompleted) {
        _completionShown = true;
      }
    } catch (error) {
      if (!mounted) return;

      setState(() => _loading = false);
      _showMessage('Could not load journey: $error');
    }
  }

  Future<void> _persistCount(int nextCount) async {
    final journey = _journey;
    if (journey == null || _saving) return;

    final updated = journey.copyWith(currentCount: nextCount);

    setState(() {
      _journey = updated;
      _saving = true;
    });

    try {
      final repository = await ref.read(dhikrJourneyRepositoryProvider.future);

      await repository.updateJourney(updated);

      if (!mounted) return;

      ref.invalidate(dhikrJourneysProvider);
    } catch (error) {
      if (!mounted) return;

      setState(() => _journey = journey);
      _showMessage('Could not save your count. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _increment() async {
    final journey = _journey;

    if (journey == null || _loading || _saving) return;

    if (journey.isCompleted) {
      if (!_completionShown) {
        _completionShown = true;
        _showCompletionDialog();
      }
      return;
    }

    final nextCount = journey.currentCount + 1;

    setState(() => _animateTap = true);
    _tapController.forward().then((_) {
      if (mounted) _tapController.reverse();
    });

    await _persistCount(nextCount);

    if (!mounted || _journey == null) return;

    if (nextCount == 33 ||
        nextCount == 100 ||
        nextCount == 500 ||
        nextCount == 1000) {
      _showMessage('Alhamdulillah! $nextCount repetitions completed.');
    }

    if (nextCount >= journey.targetCount && !_completionShown) {
      _completionShown = true;
      await _showCompletionDialog();
    }
  }

  Future<void> _decrement() async {
    if (_journey == null || _count == 0 || _saving) return;

    _completionShown = false;
    await _persistCount(_count - 1);
  }

  Future<void> _resetCount() async {
    if (_journey == null || _saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset count?'),
        content: const Text(
          'This will reset this journey to zero. Your target will remain unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kRosePrimary),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    _completionShown = false;
    await _persistCount(0);
  }

  Future<void> _deleteJourney() async {
    final journey = _journey;
    if (journey == null || _saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete journey?'),
        content: Text(
          '“${journey.name}” and all its saved progress will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final repository = await ref.read(dhikrJourneyRepositoryProvider.future);

      await repository.deleteJourney(journey.id);
      ref.invalidate(dhikrJourneysProvider);

      if (mounted) context.go('/tasbeeh');
    } catch (error) {
      if (mounted) _showMessage('Could not delete journey: $error');
    }
  }

  Future<void> _showCompletionDialog() async {
    final journey = _journey;
    if (journey == null || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.verified_rounded,
          color: RushdColors.emerald,
          size: 48,
        ),
        title: const Text('Journey Completed', textAlign: TextAlign.center),
        content: Text(
          'Alhamdulillah! You have completed ${journey.name} '
          'with ${journey.targetCount} repetitions.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kRosePrimary),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  Future<void> _showOptions() async {
    if (_journey == null) return;

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.restart_alt_rounded,
                color: _kRosePrimary,
              ),
              title: const Text('Reset Count'),
              subtitle: const Text('Start this journey again from zero'),
              onTap: () {
                Navigator.pop(sheetContext);
                _resetCount();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              title: const Text('Delete Journey'),
              subtitle: const Text('Permanently remove saved progress'),
              onTap: () {
                Navigator.pop(sheetContext);
                _deleteJourney();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _kRosePrimary)),
      );
    }

    final journey = _journey;

    if (journey == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('TASBEEH')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 48),
                const SizedBox(height: 12),
                const Text('Journey not found'),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _kRosePrimary),
                  onPressed: () => context.go('/tasbeeh'),
                  child: const Text('Back to Journeys'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final progress = journey.progress;
    final remaining = journey.remainingCount;

    return Scaffold(
      backgroundColor: isDark
          ? RushdColors.darkBackground
          : RushdColors.lightBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'TASBEEH',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
        leading: IconButton(
          tooltip: 'Back to journeys',
          onPressed: () => context.go('/tasbeeh'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Journey options',
            onPressed: _showOptions,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final ringSize = math.min(
              330.0,
              math.max(200.0, availableHeight * 0.38),
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _increment,
              onLongPress: _decrement,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: availableHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            // Journey name
                            Container(
                              constraints: const BoxConstraints(maxWidth: 280),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: _kRosePrimary.withValues(
                                  alpha: isDark ? 0.22 : 0.09,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: _kRosePrimary.withValues(alpha: 0.20),
                                ),
                              ),
                              child: Text(
                                journey.name.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isDark ? _kRoseLight : _kRoseDark,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Persistent reading panel
                            if (journey.duaId?.trim().isNotEmpty == true) ...[
                              _InlineDuaReadingPanel(duaId: journey.duaId),
                            ],
                          ],
                        ),

                        // Center Focus: Tasbeeh Ring & Progress
                        Column(
                          children: [
                            SizedBox(
                              width: ringSize,
                              height: ringSize,
                              child: ScaleTransition(
                                scale: _tapScale,
                                child: TasbeehRing(
                                  current: _count,
                                  target: _target,
                                  isDark: isDark,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: _kRosePrimary.withValues(
                                  alpha: isDark ? 0.20 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                '${(progress * 100).round()}% COMPLETED',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark ? _kRoseLight : _kRoseDark,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              journey.isCompleted
                                  ? 'Alhamdulillah — target reached'
                                  : '$remaining repetitions remaining',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Bottom instruction widget & progress
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(
                                    alpha: 0.65,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    color: _kRoseLight,
                                    size: 21,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      'Tap anywhere to Count  ·  Hold to Undo',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (_saving) ...[
                              const SizedBox(height: 10),
                              const LinearProgressIndicator(
                                minHeight: 2,
                                color: _kRosePrimary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InlineDuaReadingPanel extends StatefulWidget {
  const _InlineDuaReadingPanel({required this.duaId});

  final String? duaId;

  @override
  State<_InlineDuaReadingPanel> createState() => _InlineDuaReadingPanelState();
}

class _InlineDuaReadingPanelState extends State<_InlineDuaReadingPanel> {
  late Future<List<Map<String, dynamic>>> _duasFuture;
  final PageController _pageController = PageController();

  bool _expanded = false;
  bool _panelOpen = false;
  int _currentPage = 0;

  static const List<Map<String, dynamic>> _sections = [
    {'key': 'arabic', 'title': 'Arabic', 'subtitle': 'Original text'},
    {
      'key': 'english_transliteration',
      'title': 'English Transliteration',
      'subtitle': 'English pronunciation',
    },
    {
      'key': 'malayalam_transliteration',
      'title': 'Malayalam Transliteration',
      'subtitle': 'Malayalam pronunciation',
    },
    {
      'key': 'english_translation',
      'title': 'English Meaning',
      'subtitle': 'English translation',
    },
    {
      'key': 'malayalam_translation',
      'title': 'Malayalam Meaning',
      'subtitle': 'Malayalam translation',
    },
  ];

  @override
  void initState() {
    super.initState();
    _duasFuture = DuaRepository().getAllDuas();
  }

  @override
  void didUpdateWidget(covariant _InlineDuaReadingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duaId != widget.duaId) {
      _duasFuture = DuaRepository().getAllDuas();
      _currentPage = 0;

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _changePage(int page) {
    if (page < 0 || page >= _sections.length) return;

    setState(() {
      _currentPage = page;
    });

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: !_panelOpen
          ? Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setState(() => _panelOpen = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _kRosePrimary.withValues(alpha: isDark ? 0.28 : 0.16),
                          _kRoseDark.withValues(alpha: isDark ? 0.15 : 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _kRoseLight.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _kRosePrimary.withValues(alpha: 0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kRosePrimary, _kRoseDark],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _kRosePrimary.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'View Recitation Panel',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? _kRoseLight : _kRoseDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: _kRoseLight,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              onLongPress: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              theme.colorScheme.surface.withValues(alpha: 0.92),
                              const Color(0xFF1E1B24).withValues(alpha: 0.95),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.95),
                              const Color(0xFFFFF1F5).withValues(alpha: 0.9),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: _kRoseLight.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kRosePrimary.withValues(
                          alpha: isDark ? 0.25 : 0.12,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_kRosePrimary, _kRoseDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: _kRosePrimary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RECITATION COMPANION',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.3,
                                    color: isDark ? _kRoseLight : _kRoseDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Swipe or use indicators to read',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close panel',
                            style: IconButton.styleFrom(
                              backgroundColor: _kRosePrimary.withValues(
                                alpha: 0.12,
                              ),
                            ),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              setState(() {
                                _panelOpen = false;
                              });
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: _kRosePrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _duasFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: _kRosePrimary,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Unable to load the reading text.',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          final duas = snapshot.data ?? [];
                          Map<String, dynamic>? dua;
                          final duaId = widget.duaId;

                          for (final item in duas) {
                            if (item['id']?.toString() == duaId) {
                              dua = item;
                              break;
                            }
                          }

                          if (dua == null) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'The linked Dua or Dhikr could not be found.',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          final currentSection = _sections[_currentPage];

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _kRosePrimary.withValues(
                                        alpha: isDark ? 0.2 : 0.08,
                                      ),
                                      _kRoseDark.withValues(
                                        alpha: isDark ? 0.1 : 0.03,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _kRosePrimary.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      currentSection['title']!,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? _kRoseLight
                                            : _kRoseDark,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${currentSection['subtitle']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.textTheme.bodySmall?.color
                                            ?.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOutCubic,
                                height: _expanded ? 260 : 130,
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                            const Color(0xFF18151D),
                                            const Color(0xFF221E29),
                                          ]
                                        : [
                                            Colors.white,
                                            const Color(0xFFFFFAFC),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _kRosePrimary.withValues(
                                      alpha: 0.25,
                                    ),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.2 : 0.04,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _sections.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final itemSection = _sections[index];
                                    final itemKey = itemSection['key']!;
                                    final value =
                                        dua![itemKey]?.toString().trim() ?? '';
                                    final isArabic = itemKey == 'arabic';

                                    return SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        child: value.isEmpty
                                            ? Text(
                                                'This text is not available.',
                                                textAlign: TextAlign.center,
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              )
                                            : SelectableText(
                                                value,
                                                textAlign: TextAlign.center,
                                                textDirection: isArabic
                                                    ? TextDirection.rtl
                                                    : TextDirection.ltr,
                                                style: isArabic
                                                    ? theme
                                                          .textTheme
                                                          .headlineSmall
                                                          ?.copyWith(
                                                            fontSize: 26,
                                                            height: 1.95,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isDark
                                                                ? RushdColors
                                                                      .darkTextPrimary
                                                                : _kRoseDark,
                                                          )
                                                    : theme.textTheme.bodyMedium
                                                          ?.copyWith(
                                                            fontSize: 15.5,
                                                            height: 1.7,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: isDark
                                                                ? RushdColors
                                                                      .darkTextPrimary
                                                                : RushdColors
                                                                      .lightTextPrimary,
                                                          ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: List.generate(_sections.length, (
                                      index,
                                    ) {
                                      final isSelected = index == _currentPage;
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        margin: const EdgeInsets.only(right: 4),
                                        width: isSelected ? 18 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? const LinearGradient(
                                                  colors: [
                                                    _kRosePrimary,
                                                    _kRoseLight,
                                                  ],
                                                )
                                              : null,
                                          color: isSelected
                                              ? null
                                              : _kRosePrimary.withValues(
                                                  alpha: 0.2,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: _kRosePrimary,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _expanded = !_expanded;
                                      });
                                    },
                                    icon: Icon(
                                      _expanded
                                          ? Icons.unfold_less_rounded
                                          : Icons.unfold_more_rounded,
                                      size: 16,
                                    ),
                                    label: Text(
                                      _expanded ? 'Show Less' : 'Expand View',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class TasbeehRing extends StatelessWidget {
  const TasbeehRing({
    required this.current,
    required this.target,
    required this.isDark,
    super.key,
  });

  final int current;
  final int target;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    const totalNodes = 33;
    final filledNodes = (progress * totalNodes).floor().clamp(0, totalNodes);

    // Smooth clock-like rotation angle based on progress toward target
    final double targetAngle = target <= 0 ? 0.0 : progress * 2 * math.pi;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final center = size / 2;
        final orbitRadius = size * 0.41;

        const gapAngle = math.pi / 5;
        final arcStart = -math.pi / 2 + gapAngle / 2;
        final arcSweep = 2 * math.pi - gapAngle;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Static Ambient Background Glow Field
              Container(
                width: size * 0.95,
                height: size * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _kRosePrimary.withValues(alpha: isDark ? 0.3 : 0.15),
                      _kRosePrimary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),

              // Animated Clock-like Rotating Ring Container (Track & Beads Overlay Together)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: targetAngle),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, rotationAngle, child) {
                  return Transform.rotate(
                    angle: rotationAngle,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // The Outer Track Ring (Beads sit directly on this path)
                          Container(
                            width: size * 0.82,
                            height: size * 0.82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _kRosePrimary.withValues(
                                  alpha: isDark ? 0.35 : 0.2,
                                ),
                                width: 1.5,
                              ),
                            ),
                          ),

                          // Dynamic Orbital Energy Nodes (Beads)
                          ...List.generate(totalNodes, (index) {
                            final angle =
                                arcStart + arcSweep * index / (totalNodes - 1);
                            final x = center + orbitRadius * math.cos(angle);
                            final y = center + orbitRadius * math.sin(angle);

                            final isLit = index < filledNodes;
                            final isKeyNode =
                                index == 0 ||
                                index == 11 ||
                                index == 22 ||
                                index == 32;
                            final nodeSize = size * (isKeyNode ? 0.048 : 0.032);

                            return Positioned(
                              left: x - nodeSize / 2,
                              top: y - nodeSize / 2,
                              child: Container(
                                width: nodeSize,
                                height: nodeSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: isLit
                                      ? [
                                          BoxShadow(
                                            color: _kRosePrimary.withValues(
                                              alpha: 0.85,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 1.5,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isLit
                                        ? const LinearGradient(
                                            colors: [
                                              _kRoseLight,
                                              _kRosePrimary,
                                              _kRoseDark,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : LinearGradient(
                                            colors: [
                                              isDark
                                                  ? const Color(0xFF2A2333)
                                                  : const Color(0xFFE2E8F0),
                                              isDark
                                                  ? const Color(0xFF16121C)
                                                  : const Color(0xFFCBD5E1),
                                            ],
                                          ),
                                    border: Border.all(
                                      color: isLit
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Celestial Top Beacon (Imam Bead)
                          Positioned(
                            left: center - size * 0.038,
                            top: center - orbitRadius - size * 0.045,
                            child: Container(
                              width: size * 0.076,
                              height: size * 0.096,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    _kRoseLight,
                                    _kRosePrimary,
                                    _kRoseDark,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _kRosePrimary.withValues(
                                      alpha: 0.75,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.spa_outlined,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Static, Perfectly Centered Holographic Glassmorphic Center Core
              Container(
                width: size * 0.58,
                height: size * 0.58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF221929).withValues(alpha: 0.95),
                            const Color(0xFF120E16).withValues(alpha: 0.98),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.95),
                            const Color(0xFFFFF0F5).withValues(alpha: 0.90),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: _kRosePrimary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kRosePrimary.withValues(
                        alpha: isDark ? 0.35 : 0.15,
                      ),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DHIKR COUNT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w900,
                        color: _kRosePrimary.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: FittedBox(
                        key: ValueKey(current),
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$current',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                fontSize: size * 0.16,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                letterSpacing: -1.5,
                                color: isDark ? _kRoseLight : _kRoseDark,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _kRosePrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _kRosePrimary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        'OF $target',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: isDark ? _kRoseLight : _kRoseDark,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
