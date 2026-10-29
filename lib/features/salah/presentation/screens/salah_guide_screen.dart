import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/salah_repository.dart';

class SalahGuideScreen extends StatefulWidget {
  const SalahGuideScreen({super.key});

  @override
  State<SalahGuideScreen> createState() => _SalahGuideScreenState();
}

class _SalahGuideScreenState extends State<SalahGuideScreen> {
  final SalahRepository _repository = SalahRepository();

  late Future<_SalahOverviewData> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _overviewFuture = _loadOverview();
  }

  Future<_SalahOverviewData> _loadOverview() async {
    final results = await Future.wait<dynamic>([
      _repository.getDailyPrayers(),
      _repository.getSpecialPrayers(),
      _repository.getPrayerGuides(),
    ]);

    return _SalahOverviewData(
      dailyPrayers: results[0] as List<Map<String, dynamic>>,
      specialPrayers: results[1] as List<Map<String, dynamic>>,
      guides: results[2] as List<Map<String, dynamic>>,
    );
  }

  Future<void> _retry() async {
    setState(() {
      _overviewFuture = _loadOverview();
    });

    try {
      await _overviewFuture;
    } catch (_) {
      // FutureBuilder displays the error state.
    }
  }

  bool _hasGuide(List<Map<String, dynamic>> guides, String prayerId) {
    return guides.any((guide) => guide['prayer_id'] == prayerId);
  }

  void _openGuide(
    Map<String, dynamic> prayer,
    List<Map<String, dynamic>> guides,
  ) {
    final id = prayer['id']?.toString() ?? '';

    if (id.isEmpty || !_hasGuide(guides, id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A guide for this prayer is not available yet.'),
        ),
      );
      return;
    }

    context.push('/salah-guide/$id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SALAH GUIDE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
      ),
      body: FutureBuilder<_SalahOverviewData>(
        future: _overviewFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _ErrorState(onRetry: _retry);
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _retry,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                const _IntroCard(),
                const SizedBox(height: 10),

                _SectionHeader(
                  title: 'Daily Prayers',
                  subtitle: 'The five daily prayers',
                  icon: Icons.wb_twilight_rounded,
                ),
                const SizedBox(height: 12),

                ...data.dailyPrayers.map(
                  (prayer) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _DailyPrayerCard(
                      prayer: prayer,
                      onTap: () => _openGuide(prayer, data.guides),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                _SectionHeader(
                  title: 'Special Prayers',
                  subtitle: 'Guides for special occasions',
                  icon: Icons.auto_awesome_rounded,
                ),
                const SizedBox(height: 12),

                ...data.specialPrayers.map(
                  (prayer) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SpecialPrayerCard(
                      prayer: prayer,
                      onTap: () => _openGuide(prayer, data.guides),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SalahOverviewData {
  final List<Map<String, dynamic>> dailyPrayers;
  final List<Map<String, dynamic>> specialPrayers;
  final List<Map<String, dynamic>> guides;

  const _SalahOverviewData({
    required this.dailyPrayers,
    required this.specialPrayers,
    required this.guides,
  });
}

// -----------------------------------------------------------------------------
// INTRO
// -----------------------------------------------------------------------------

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: isDark ? 0.65 : 0.82),
            colors.primaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background SVG Watermark
            Positioned(
              right: -25,
              bottom: -30,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.12,
                  child: SvgPicture.asset(
                    'assets/icons/worship_icons/salah.svg',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/worship_icons/salah.svg',
                          width: 26,
                          height: 26,
                          fit: BoxFit.contain,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Text(
                          'STEP-BY-STEP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Learn Salah,\nstep by step.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Explore prayer positions, rakahs and recitations.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14.5,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION HEADER
// -----------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: colors.onPrimary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
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
// DAILY PRAYER CARD
// -----------------------------------------------------------------------------

class _DailyPrayerCard extends StatelessWidget {
  final Map<String, dynamic> prayer;
  final VoidCallback onTap;

  const _DailyPrayerCard({required this.prayer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors(prayer['gradient']);
    final isDark = _isDarkGradient(colors);
    final foreground = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedForeground = foreground.withValues(alpha: 0.78);

    final rakaths = _asMap(prayer['rakaths']);
    final name = _value(prayer, 'name');
    final arabic = _value(prayer, 'arabic');
    final malayalam = _value(prayer, 'malayalam');
    final description = _value(prayer, 'description');
    final watermark = _value(prayer, 'watermark');
    final active = prayer['active'] == true;
    final hasQunoot = prayer['hasQunoot'] == true;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: active
                  ? foreground.withValues(alpha: 0.55)
                  : foreground.withValues(alpha: 0.08),
              width: active ? 1.5 : 0.7,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -16,
                top: 10,
                child: Icon(
                  _dailyIcon(name),
                  size: 118,
                  color: foreground.withValues(alpha: 0.07),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: foreground,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (malayalam.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  malayalam,
                                  style: TextStyle(
                                    color: mutedForeground,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                Text(
                                  description,
                                  style: TextStyle(
                                    color: mutedForeground,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              arabic,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: foreground,
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (active) ...[
                              const SizedBox(height: 7),
                              _StatusBadge(
                                label: 'ACTIVE',
                                foreground: foreground,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [..._rakahChips(rakaths, foreground)],
                    ),

                    const SizedBox(height: 17),

                    Container(
                      height: 1,
                      color: foreground.withValues(alpha: 0.14),
                    ),

                    const SizedBox(height: 13),

                    Row(
                      children: [
                        Icon(
                          hasQunoot
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline_rounded,
                          size: 16,
                          color: mutedForeground,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            hasQunoot ? 'Includes Qunoot' : 'Standard prayer',
                            style: TextStyle(
                              color: mutedForeground,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'Learn Salah',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: foreground,
                        ),
                      ],
                    ),

                    // Retain the watermark asset path as dataset metadata.
                    // SVG rendering can be added separately if flutter_svg
                    // is introduced to the project.
                    if (watermark.isNotEmpty) const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color foreground;

  const _StatusBadge({required this.label, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SPECIAL PRAYER CARD
// -----------------------------------------------------------------------------

class _SpecialPrayerCard extends StatelessWidget {
  final Map<String, dynamic> prayer;
  final VoidCallback onTap;

  const _SpecialPrayerCard({required this.prayer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors(prayer['gradient']);
    final foreground = _isDarkGradient(colors)
        ? Colors.white
        : const Color(0xFF17332D);

    final name = _value(prayer, 'name');
    final arabic = _value(prayer, 'arabic');
    final malayalam = _value(prayer, 'malayalam');
    final description = _value(prayer, 'description');
    final icon = _specialIcon(_value(prayer, 'icon'));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 112,
                  color: foreground.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: foreground.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: foreground.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(icon, color: foreground, size: 23),
                        ),
                        const Spacer(),
                        Text(
                          arabic,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: foreground,
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (malayalam.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        malayalam,
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(
                        description,
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.86),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Explore prayer guide',
                          style: TextStyle(
                            color: foreground,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: foreground,
                          size: 17,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DATA HELPERS
// -----------------------------------------------------------------------------

String _value(Map<String, dynamic> map, String key) {
  return map[key]?.toString().trim() ?? '';
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<Color> _gradientColors(dynamic value) {
  if (value is List && value.isNotEmpty) {
    final colors = value.map((item) => _parseColor(item.toString())).toList();

    if (colors.length == 1) {
      return [colors.first, colors.first];
    }

    return colors;
  }

  return const [Color(0xFF0F766E), Color(0xFF14B8A6)];
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

List<Widget> _rakahChips(Map<String, dynamic> rakaths, Color foreground) {
  const labels = <String, String>{
    'sunnahBefore': 'Sunnah before',
    'sunnah': 'Sunnah',
    'fard': 'Fard',
    'sunnahAfter': 'Sunnah after',
    'witr': 'Witr',
  };

  const order = ['sunnahBefore', 'sunnah', 'fard', 'sunnahAfter', 'witr'];

  return order.where((key) => rakaths[key] != null).map((key) {
    final count = rakaths[key];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withValues(alpha: 0.10)),
      ),
      child: Text(
        '${labels[key]}: $count',
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }).toList();
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

// -----------------------------------------------------------------------------
// ERROR STATE
// -----------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load Salah Guide',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 7),
            Text(
              'Check that all five Salah JSON datasets are included '
              'in the assets configuration.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
