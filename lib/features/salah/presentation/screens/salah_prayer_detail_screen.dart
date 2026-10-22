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

  @override
  void initState() {
    super.initState();
    _bundleFuture = _repository.getPrayerBundle(widget.prayerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bundleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _GuideError(
              onRetry: () {
                setState(() {
                  _bundleFuture = _repository.getPrayerBundle(widget.prayerId);
                });
              },
            );
          }

          final bundle = snapshot.data!;
          final prayer = Map<String, dynamic>.from(bundle['prayer'] as Map);
          final recitations = (bundle['recitations'] as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          final positions = Map<String, dynamic>.from(
            bundle['positions'] as Map,
          );

          final rakahs = (prayer['rakahs'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

          if (rakahs.isEmpty) {
            return _GuideError(
              message: 'No prayer steps are available for this guide.',
              onRetry: () {
                setState(() {
                  _bundleFuture = _repository.getPrayerBundle(widget.prayerId);
                });
              },
            );
          }

          final selectedIndex = _selectedRakah.clamp(0, rakahs.length - 1);
          final selectedRakah = rakahs[selectedIndex];
          final niyyahRecitation = _findRecitation(
            recitations,
            'niyyah_${widget.prayerId}',
          );

          return CustomScrollView(
            slivers: [
              // 1. Sleek Gradient App Bar / Hero Header
              SliverAppBar(
                pinned: true,
                expandedHeight: 220,
                backgroundColor: const Color(0xFF1E3A8A),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: _PrayerHero(prayer: prayer),
                ),
              ),

              // 2. Overview & Interactive Niyyah Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    children: [
                      _OverviewCard(prayer: prayer),
                      if (niyyahRecitation != null) ...[
                        const SizedBox(height: 16),
                        _NiyyahCard(
                          niyyah: niyyahRecitation,
                          isExpanded: _niyyahExpanded,
                          onToggle: () {
                            setState(() {
                              _niyyahExpanded = !_niyyahExpanded;
                            });
                          },
                        ),
                      ],
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
                      const Text(
                        'Follow the Steps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select a rakah to view detailed postures & recitations.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
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
          );
        },
      ),
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

  const _PrayerHero({required this.prayer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 72, 22, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.mosque_rounded,
              size: 130,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _string(prayer, 'name'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _string(prayer, 'malayalam'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _string(prayer, 'arabic'),
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
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
// OVERVIEW CARD
// -----------------------------------------------------------------------------

class _OverviewCard extends StatelessWidget {
  final Map<String, dynamic> prayer;

  const _OverviewCard({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final rakahs = (prayer['rakahs'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _string(prayer, 'description'),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.format_list_numbered_rounded,
                label: '${rakahs.length} Rakah Sections',
              ),
              if (prayer['hasQunoot'] == true)
                const _InfoChip(
                  icon: Icons.menu_book_rounded,
                  label: 'Qunoot Included',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INTERACTIVE NIYYAH CARD
// -----------------------------------------------------------------------------

class _NiyyahCard extends StatelessWidget {
  final Map<String, dynamic> niyyah;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _NiyyahCard({
    required this.niyyah,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NIYYAH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.teal,
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
                          _string(niyyah, 'name', fallback: 'Prayer Intention'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        if (!isExpanded)
                          Text(
                            'Tap to view intention & meanings',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _string(niyyah, 'arabic'),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 2,
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
                selectedColor: const Color(0xFF1E3A8A),
                labelStyle: TextStyle(
                  color: selectedIndex == i
                      ? Colors.white
                      : Colors.blueGrey.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: selectedIndex == i
                      ? const Color(0xFF1E3A8A)
                      : Colors.grey.shade300,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Color(0xFF1E3A8A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rakah ${_string(rakah, 'rakah')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _string(rakah, 'type'),
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
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
    final instruction = _string(step, 'instruction');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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
                  color: Colors.grey.shade700,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.accessibility_new_rounded,
            size: 13,
            color: Colors.blueGrey,
          ),
          const SizedBox(width: 5),
          Text(
            position,
            style: const TextStyle(
              color: Colors.blueGrey,
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
        color: const Color(0xFF1E3A8A).withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 15,
                color: Color(0xFF1E3A8A),
              ),
              const SizedBox(width: 6),
              const Text(
                'RECITATION',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
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
                  style: const TextStyle(
                    fontSize: 26,
                    height: 1.9,
                    fontWeight: FontWeight.w500,
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
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
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
              color: Colors.grey.shade800,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

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
