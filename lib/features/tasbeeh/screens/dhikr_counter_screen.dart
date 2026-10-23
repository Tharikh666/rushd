import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/rushd_colors.dart';
import '../../duas/data/repositories/dua_repository.dart';
import '../domain/models/dhikr_journey.dart';
import 'dhikr_journeys_screen.dart';

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

      // Restore the previous in-memory value if persistence failed.
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

    // Allow undoing a completed target as well.
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
              leading: const Icon(Icons.restart_alt_rounded),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            fontSize: 13,
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
              310.0,
              math.max(185.0, availableHeight * 0.36),
            );

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availableHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  child: Column(
                    children: [
                      // Journey name
                      Container(
                        constraints: const BoxConstraints(maxWidth: 280),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: RushdColors.primary.withValues(
                            alpha: isDark ? 0.22 : 0.09,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: RushdColors.primary.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Text(
                          journey.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark
                                ? RushdColors.primaryLight
                                : RushdColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Persistent reading panel
                      if (journey.duaId?.trim().isNotEmpty == true) ...[
                        _InlineDuaReadingPanel(duaId: journey.duaId),
                        const SizedBox(height: 12),
                      ],

                      // Only this area increments or undoes the count.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _increment,
                        onLongPress: _decrement,
                        child: SizedBox(
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
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: RushdColors.primary.withValues(
                            alpha: isDark ? 0.20 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${(progress * 100).round()}% COMPLETED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? RushdColors.primaryLight
                                : RushdColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        journey.isCompleted
                            ? 'Alhamdulillah — target reached'
                            : '$remaining repetitions remaining',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.75,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 14),

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
                            color: theme.dividerColor.withValues(alpha: 0.65),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              color: RushdColors.primaryLight,
                              size: 21,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Tap to Count  ·  Hold to Undo',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_saving) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(minHeight: 2),
                      ],
                    ],
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

  static const List<Map<String, String>> _sections = [
    {'key': 'arabic', 'title': 'Arabic', 'subtitle': 'Original Arabic text'},
    {
      'key': 'english_transliteration',
      'title': 'English Transliteration',
      'subtitle': 'Pronunciation in English letters',
    },
    {
      'key': 'malayalam_transliteration',
      'title': 'Malayalam Transliteration',
      'subtitle': 'Pronunciation in Malayalam letters',
    },
    {
      'key': 'english_translation',
      'title': 'English Translation',
      'subtitle': 'Meaning in English',
    },
    {
      'key': 'malayalam_translation',
      'title': 'Malayalam Translation',
      'subtitle': 'Meaning in Malayalam',
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

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: !_panelOpen
          ? Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: 'Open Dua and Dhikr reading',
                child: Material(
                  color: RushdColors.primary.withValues(
                    alpha: isDark ? 0.18 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _panelOpen = true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            color: RushdColors.primaryLight,
                            size: 21,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'View Recitation',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : _buildOpenPanel(context, theme, isDark),
    );
  }

  Widget _buildOpenPanel(BuildContext context, ThemeData theme, bool isDark) {
    final duaId = widget.duaId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: RushdColors.primary.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Panel header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: RushdColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: RushdColors.primaryLight,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'READING PANEL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: isDark
                            ? RushdColors.primaryLight
                            : RushdColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Read while you count',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close reading panel',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  setState(() {
                    _panelOpen = false;
                  });
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Load the linked Dua or Dhikr
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _duasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
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

              final section = _sections[_currentPage];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected language and page number
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          section['title']!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${_currentPage + 1} / ${_sections.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: RushdColors.primaryLight,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Scrollable reading area
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    height: _expanded ? 250 : 112,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? RushdColors.darkSurfaceElevated
                          : RushdColors.primary.withValues(alpha: 0.045),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: RushdColors.primary.withValues(alpha: 0.12),
                      ),
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
                        final value = dua![itemKey]?.toString().trim() ?? '';
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
                                    style: theme.textTheme.bodyMedium,
                                  )
                                : SelectableText(
                                    value,
                                    textAlign: TextAlign.center,
                                    textDirection: isArabic
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    style: isArabic
                                        ? theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                fontSize: 25,
                                                height: 1.9,
                                                color: isDark
                                                    ? RushdColors
                                                          .darkTextPrimary
                                                    : RushdColors.primaryDark,
                                              )
                                        : theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: 15,
                                            height: 1.7,
                                            color: isDark
                                                ? RushdColors.darkTextPrimary
                                                : RushdColors.lightTextPrimary,
                                          ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Expand/collapse the reading area's height
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      icon: Icon(
                        _expanded
                            ? Icons.unfold_less_rounded
                            : Icons.unfold_more_rounded,
                        size: 18,
                      ),
                      label: Text(_expanded ? 'Show less' : 'Read more'),
                    ),
                  ),

                  // Language page indicators and navigation
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Previous language',
                        visualDensity: VisualDensity.compact,
                        onPressed: _currentPage == 0
                            ? null
                            : () => _changePage(_currentPage - 1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_sections.length, (index) {
                            final selected = index == _currentPage;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: selected ? 18 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: selected
                                    ? RushdColors.primaryLight
                                    : theme.dividerColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next language',
                        visualDensity: VisualDensity.compact,
                        onPressed: _currentPage == _sections.length - 1
                            ? null
                            : () => _changePage(_currentPage + 1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
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

    final filledBeads = (progress * 33).floor().clamp(0, 33);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);

        final center = size / 2;
        final ringRadius = size * 0.405;

        // Reserve a clear gap around the top imam bead.
        // The 32 regular beads occupy the remaining 330-degree arc.
        const gapAngle = math.pi / 6; // 30 degrees
        const regularBeadCount = 32;
        final arcStart = -math.pi / 2 + gapAngle / 2;
        final arcSweep = 2 * math.pi - gapAngle;

        final regularBeadColor = isDark
            ? RushdColors.darkSurfaceElevated
            : const Color(0xFFE2E8F0);

        final regularBorderColor = isDark
            ? RushdColors.darkBorder
            : const Color(0xFFCBD5E1);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer decorative ring.
            Container(
              width: size * 0.86,
              height: size * 0.86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: RushdColors.primary.withValues(
                    alpha: isDark ? 0.13 : 0.10,
                  ),
                  width: 1,
                ),
              ),
            ),

            // The 32 regular beads.
            ...List.generate(regularBeadCount, (index) {
              final angle =
                  arcStart + arcSweep * index / (regularBeadCount - 1);

              final x = center + ringRadius * math.cos(angle);
              final y = center + ringRadius * math.sin(angle);

              // Progress is mapped onto all 33 beads.
              // Index 0 is reserved for the imam bead.
              final beadProgressIndex = index + 1;
              final isFilled = beadProgressIndex < filledBeads;

              // Slightly larger milestone beads, matching the original design.
              final isMilestone = index == 9 || index == 20 || index == 31;

              final beadSize = size * (isMilestone ? 0.048 : 0.031);

              return Positioned(
                left: x - beadSize / 2,
                top: y - beadSize / 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: beadSize,
                  height: beadSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? RushdColors.primaryLight
                        : regularBeadColor,
                    border: Border.all(
                      color: isFilled
                          ? RushdColors.primary
                          : regularBorderColor,
                      width: isMilestone ? 1.5 : 0.8,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: RushdColors.primary.withValues(
                                alpha: 0.20,
                              ),
                              blurRadius: 5,
                              spreadRadius: 0.5,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),

            // Dedicated imam bead at 12 o'clock.
            Positioned(
              left: center - size * 0.032,
              top: center - ringRadius - size * 0.032,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: size * 0.064,
                height: size * 0.064,
                transform: Matrix4.identity()..rotateZ(math.pi / 4),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  color: filledBeads > 0
                      ? RushdColors.primaryLight
                      : regularBeadColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: filledBeads > 0
                        ? RushdColors.primary
                        : regularBorderColor,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: RushdColors.primary.withValues(alpha: 0.12),
                      blurRadius: 5,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),

            // Central counter.
            Container(
              width: size * 0.68,
              height: size * 0.68,
              decoration: BoxDecoration(
                color: isDark ? RushdColors.darkSurface : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: RushdColors.primary.withValues(
                    alpha: isDark ? 0.22 : 0.15,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.12 : 0.045,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DHIKR COUNT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.7,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.60),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 130),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
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
                              fontWeight: FontWeight.w800,
                              height: 1,
                              letterSpacing: -1.5,
                              color: isDark
                                  ? RushdColors.primaryLight
                                  : RushdColors.primaryDark,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'OF $target',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
