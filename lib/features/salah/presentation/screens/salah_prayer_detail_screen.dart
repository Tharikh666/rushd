import 'package:flutter/material.dart';
import '../../data/repositories/salah_repository.dart';

class SalahPrayerDetailScreen extends StatefulWidget {
  final String prayerId;

  const SalahPrayerDetailScreen({super.key, required this.prayerId});

  @override
  State<SalahPrayerDetailScreen> createState() =>
      _SalahPrayerDetailScreenState();
}

class _SalahPrayerDetailScreenState extends State<SalahPrayerDetailScreen> {
  final SalahRepository _repository = SalahRepository();

  late Future<Map<String, dynamic>> _bundleFuture;
  int _selectedRakah = 0;
  bool _niyyahExpanded = false;
  int _selectedEidIndex = 0;

  @override
  void initState() {
    super.initState();
    _bundleFuture = _loadBundle();
  }

  Future<Map<String, dynamic>> _loadBundle() async {
    final results = await Future.wait<dynamic>([
      _repository.getPrayerBundle(widget.prayerId),
      _repository.getDailyPrayers(),
      _repository.getSpecialPrayers(),
    ]);

    final bundle = Map<String, dynamic>.from(results[0] as Map);
    bundle['dailyPrayers'] = results[1];
    bundle['specialPrayers'] = results[2];
    return bundle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: _bundleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Prayer Guide')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _GuideError(
            onRetry: () {
              setState(() {
                _bundleFuture = _loadBundle();
              });
            },
          );
        }

        final bundle = snapshot.data!;
        final prayer = Map<String, dynamic>.from(bundle['prayer'] as Map);

        final overviewPrayer =
            _findOverviewPrayer(
              bundle['dailyPrayers'] as List<dynamic>? ?? [],
              bundle['specialPrayers'] as List<dynamic>? ?? [],
              widget.prayerId,
            ) ??
            prayer;

        final recitations = (bundle['recitations'] as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        final positions = Map<String, dynamic>.from(bundle['positions'] as Map);

        final rakahs = (prayer['rakahs'] as List<dynamic>? ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        if (rakahs.isEmpty) {
          return _GuideError(
            message: 'No prayer steps are available for this guide.',
            onRetry: () {
              setState(() {
                _bundleFuture = _loadBundle();
              });
            },
          );
        }

        final selectedIndex = _selectedRakah.clamp(0, rakahs.length - 1);
        final selectedRakah = rakahs[selectedIndex];

        // Retrieve Niyyah options (supports multiple for Eid)
        final niyyahs = _findNiyyahRecitations(recitations, widget.prayerId);

        final gradientColors = _gradientColors(overviewPrayer['gradient']);
        final isDarkGradient = _isDarkGradient(gradientColors);
        final prayerName = _string(prayer, 'name').toUpperCase();
        final titleColor = isDarkGradient
            ? Colors.white
            : const Color(0xFF1E293B);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 1. Dynamic Sliver App Bar with Centered Custom Styled Title
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                backgroundColor: gradientColors.first,
                centerTitle: true,
                iconTheme: IconThemeData(color: titleColor),
                title: Text(
                  prayerName,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _PrayerHero(
                    prayer: overviewPrayer,
                    rakahCount: rakahs.length,
                  ),
                ),
              ),

              // 2. Interactive Niyyah Card with Eid Toggle Support
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    children: [
                      if (_string(prayer, 'description').isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            _string(prayer, 'description'),
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (niyyahs.isNotEmpty)
                        _NiyyahCard(
                          prayerId: widget.prayerId,
                          niyyahs: niyyahs,
                          selectedIndex: _selectedEidIndex,
                          onIndexChanged: (index) {
                            setState(() {
                              _selectedEidIndex = index;
                            });
                          },
                          isExpanded: _niyyahExpanded,
                          onToggle: () {
                            setState(() {
                              _niyyahExpanded = !_niyyahExpanded;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // 3. Rakah Selector Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Follow the Steps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select a rakah to view detailed postures & recitations.',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _RakahSelector(
                        rakahs: rakahs,
                        selectedIndex: selectedIndex,
                        onSelected: (index) {
                          setState(() {
                            _selectedRakah = index;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Step Cards List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _RakahHeading(rakah: selectedRakah),
                    const SizedBox(height: 14),
                    ..._buildSteps(selectedRakah, recitations, positions),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSteps(
    Map<String, dynamic> rakah,
    List<Map<String, dynamic>> recitations,
    Map<String, dynamic> positions,
  ) {
    final steps = (rakah['steps'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    return [
      for (var i = 0; i < steps.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _PrayerStepCard(
            number: i + 1,
            step: steps[i],
            recitation: _findRecitation(
              recitations,
              _string(steps[i], 'recitation_id'),
            ),
            position: _findPosition(positions, steps[i]),
          ),
        ),
    ];
  }
}

// -----------------------------------------------------------------------------
// HERO WIDGET
// -----------------------------------------------------------------------------

class _PrayerHero extends StatelessWidget {
  final Map<String, dynamic> prayer;
  final int rakahCount;

  const _PrayerHero({required this.prayer, required this.rakahCount});

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors(prayer['gradient']);
    final isDark = _isDarkGradient(colors);
    final foreground = isDark ? Colors.white : const Color(0xFF1E293B);

    final name = _string(prayer, 'name');
    final arabic = _string(prayer, 'arabic');
    final malayalam = _string(prayer, 'malayalam');
    final hasQunoot = prayer['hasQunoot'] == true;

    final watermark = _string(prayer, 'watermark');
    final iconName = _string(prayer, 'icon');

    IconData heroIcon = Icons.mosque_rounded;
    if (watermark.isNotEmpty) {
      heroIcon = _dailyIcon(name);
    } else if (iconName.isNotEmpty) {
      heroIcon = _specialIcon(iconName);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              heroIcon,
              size: 130,
              color: foreground.withValues(alpha: 0.08),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (rakahCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: foreground.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: foreground.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          '$rakahCount Rakah Sections',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (hasQunoot)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: foreground.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: foreground.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          'Qunoot Included',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (malayalam.isNotEmpty) ...[
                  Text(
                    malayalam,
                    style: TextStyle(
                      color: foreground.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  arabic,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INTERACTIVE NIYYAH CARD WITH EID TOGGLE
// -----------------------------------------------------------------------------

class _NiyyahCard extends StatelessWidget {
  final String prayerId;
  final List<Map<String, dynamic>> niyyahs;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _NiyyahCard({
    required this.prayerId,
    required this.niyyahs,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeIndex = selectedIndex.clamp(0, niyyahs.length - 1);
    final niyyah = niyyahs[activeIndex];

    final titleText = prayerId == 'eid'
        ? 'Niyyah for Eid Prayer'
        : _string(niyyah, 'name', fallback: 'Prayer Intention');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'NIYYAH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleText,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: colors.onSurface,
                          ),
                        ),
                        if (!isExpanded)
                          Text(
                            'Tap to view intention & meanings',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (niyyahs.length > 1) ...[
                    Row(
                      children: [
                        for (var i = 0; i < niyyahs.length; i++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: i == 0 ? 8 : 0),
                              child: ChoiceChip(
                                selected: activeIndex == i,
                                onSelected: (_) => onIndexChanged(i),
                                label: Text(
                                  i == 0 ? 'Eid-ul-Fitr' : 'Eid-ul-Adha',
                                  textAlign: TextAlign.center,
                                ),
                                selectedColor: colors.primary,
                                labelStyle: TextStyle(
                                  color: activeIndex == i
                                      ? colors.onPrimary
                                      : colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                                backgroundColor: Theme.of(context).cardColor,
                                side: BorderSide(
                                  color: activeIndex == i
                                      ? colors.primary
                                      : colors.outline.withValues(alpha: 0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      _string(niyyah, 'arabic'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 2,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_string(niyyah, 'english_transliteration').isNotEmpty)
                    _LanguageText(
                      label: 'English Transliteration',
                      value: _string(niyyah, 'english_transliteration'),
                    ),
                  if (_string(niyyah, 'malayalam_transliteration').isNotEmpty)
                    _LanguageText(
                      label: 'Malayalam Transliteration',
                      value: _string(niyyah, 'malayalam_transliteration'),
                    ),
                  if (_string(niyyah, 'english_translation').isNotEmpty)
                    _LanguageText(
                      label: 'English Meaning',
                      value: _string(niyyah, 'english_translation'),
                    ),
                  if (_string(niyyah, 'malayalam_translation').isNotEmpty)
                    _LanguageText(
                      label: 'മലയാളം അർത്ഥം',
                      value: _string(niyyah, 'malayalam_translation'),
                    ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RAKAH SELECTOR
// -----------------------------------------------------------------------------

class _RakahSelector extends StatelessWidget {
  final List<Map<String, dynamic>> rakahs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _RakahSelector({
    required this.rakahs,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < rakahs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selectedIndex == i,
                onSelected: (_) => onSelected(i),
                label: Text(
                  'Rakah ${_string(rakahs[i], 'rakah', fallback: '${i + 1}')}',
                ),
                selectedColor: colors.primary,
                labelStyle: TextStyle(
                  color: selectedIndex == i
                      ? colors.onPrimary
                      : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                backgroundColor: Theme.of(context).cardColor,
                side: BorderSide(
                  color: selectedIndex == i
                      ? colors.primary
                      : colors.outline.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RakahHeading extends StatelessWidget {
  final Map<String, dynamic> rakah;

  const _RakahHeading({required this.rakah});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rakah ${_string(rakah, 'rakah')}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _string(rakah, 'type'),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STEP CARD & RECITATION
// -----------------------------------------------------------------------------

class _PrayerStepCard extends StatelessWidget {
  final int number;
  final Map<String, dynamic> step;
  final Map<String, dynamic>? recitation;
  final String position;

  const _PrayerStepCard({
    required this.number,
    required this.step,
    required this.recitation,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final instruction = _string(step, 'instruction');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _humanize(_string(step, 'step_id')),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      if (position.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _PositionBadge(position: position),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (instruction.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                instruction,
                style: TextStyle(
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
            if (recitation != null) ...[
              const SizedBox(height: 14),
              _RecitationCard(recitation: recitation!),
            ],
          ],
        ),
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  final String position;

  const _PositionBadge({required this.position});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.accessibility_new_rounded,
            size: 13,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            position,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecitationCard extends StatelessWidget {
  final Map<String, dynamic> recitation;

  const _RecitationCard({required this.recitation});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final arabic = _string(recitation, 'arabic');
    final englishTransliteration = _firstValue(recitation, [
      'transliteration',
      'english_transliteration',
      'transliteration_en',
    ]);
    final malayalamTransliteration = _firstValue(recitation, [
      'malayalam_transliteration',
      'transliteration_malayalam',
      'malayalamTransliteration',
    ]);
    final englishTranslation = _firstValue(recitation, [
      'english_translation',
      'translation',
      'english',
    ]);
    final malayalamTranslation = _firstValue(recitation, [
      'malayalam_translation',
      'translation_malayalam',
      'malayalam',
    ]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 15, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'RECITATION',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (arabic.isNotEmpty) ...[
            const SizedBox(height: 14),
            Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  arabic,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.9,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
          ],
          if (englishTransliteration.isNotEmpty)
            _LanguageText(
              label: 'English Transliteration',
              value: englishTransliteration,
            ),
          if (malayalamTransliteration.isNotEmpty)
            _LanguageText(
              label: 'Malayalam Transliteration',
              value: malayalamTransliteration,
            ),
          if (englishTranslation.isNotEmpty)
            _LanguageText(label: 'English Meaning', value: englishTranslation),
          if (malayalamTranslation.isNotEmpty)
            _LanguageText(label: 'മലയാളം അർത്ഥം', value: malayalamTranslation),
        ],
      ),
    );
  }
}

class _LanguageText extends StatelessWidget {
  final String label;
  final String value;

  const _LanguageText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              height: 1.5,
              fontSize: 13.5,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SHARED HELPERS & ERROR
// -----------------------------------------------------------------------------

class _GuideError extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const _GuideError({
    required this.onRetry,
    this.message = 'Unable to load this prayer guide.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Guide')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic>? _findOverviewPrayer(
  List<dynamic> dailyPrayers,
  List<dynamic> specialPrayers,
  String prayerId,
) {
  for (final item in [...dailyPrayers, ...specialPrayers]) {
    if (item is Map) {
      final id = item['id']?.toString() ?? item['prayer_id']?.toString() ?? '';
      if (id == prayerId) {
        return Map<String, dynamic>.from(item);
      }
    }
  }
  return null;
}

List<Map<String, dynamic>> _findNiyyahRecitations(
  List<Map<String, dynamic>> recitations,
  String prayerId,
) {
  final list = <Map<String, dynamic>>[];
  if (prayerId == 'eid') {
    for (final item in recitations) {
      final id = item['id']?.toString() ?? '';
      if (id == 'niyyah_eid_ul_fitr' || id == 'niyyah_eid_ul_adha') {
        list.add(item);
      }
    }
  } else {
    final targetId = 'niyyah_$prayerId';
    for (final item in recitations) {
      if (item['id']?.toString() == targetId) {
        list.add(item);
        break;
      }
    }
  }
  return list;
}

Map<String, dynamic>? _findRecitation(
  List<Map<String, dynamic>> recitations,
  String id,
) {
  if (id.isEmpty) return null;
  for (final item in recitations) {
    if (item['id']?.toString() == id) {
      return item;
    }
  }
  return null;
}

String _findPosition(
  Map<String, dynamic> positions,
  Map<String, dynamic> step,
) {
  final recitationId = _string(step, 'recitation_id');
  final stepId = _string(step, 'step_id');
  final value = positions[recitationId] ?? positions[stepId];

  if (value is String) {
    return _humanize(value);
  }
  if (value is Map) {
    final position = value['position'] ?? value['name'] ?? value['label'];
    if (position != null) {
      return _humanize(position.toString());
    }
  }
  return _string(step, 'position').isEmpty
      ? ''
      : _humanize(_string(step, 'position'));
}

String _firstValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key]?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _string(Map<String, dynamic> map, String key, {String fallback = ''}) {
  final value = map[key]?.toString().trim() ?? '';
  return value.isEmpty ? fallback : value;
}

String _humanize(String value) {
  if (value.isEmpty) return '';
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

List<Color> _gradientColors(dynamic value) {
  if (value is List && value.isNotEmpty) {
    final colors = value.map((item) => _parseColor(item.toString())).toList();
    if (colors.length == 1) {
      return [colors.first, colors.first];
    }
    return colors;
  }
  return const [Color(0xFF1E3A8A), Color(0xFF3B82F6)];
}

Color _parseColor(String value) {
  var hex = value.trim().replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  if (hex.length != 8) {
    return const Color(0xFF64748B);
  }
  return Color(int.parse(hex, radix: 16));
}

bool _isDarkGradient(List<Color> colors) {
  final average =
      colors
          .map(
            (color) =>
                (0.299 * color.red) +
                (0.587 * color.green) +
                (0.114 * color.blue),
          )
          .reduce((a, b) => a + b) /
      colors.length;
  return average < 155;
}

IconData _dailyIcon(String name) {
  switch (name.toLowerCase()) {
    case 'fajr':
      return Icons.wb_twilight_rounded;
    case 'dhuhr':
      return Icons.wb_sunny_rounded;
    case 'asr':
      return Icons.light_mode_rounded;
    case 'maghrib':
      return Icons.wb_twilight_rounded;
    case 'isha':
      return Icons.nightlight_round;
    default:
      return Icons.mosque_rounded;
  }
}

IconData _specialIcon(String name) {
  switch (name) {
    case 'mosque_rounded':
      return Icons.mosque_rounded;
    case 'celebration_rounded':
      return Icons.celebration_rounded;
    case 'volunteer_activism_rounded':
      return Icons.volunteer_activism_rounded;
    default:
      return Icons.auto_awesome_rounded;
  }
}
