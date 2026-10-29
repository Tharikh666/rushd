import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _emerald = Color(0xFF064E3B);
  static const Color _gold = Color(0xFFC7A96B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    final primaryText = colors.onSurface;
    final secondaryText = colors.onSurface.withValues(alpha: 0.68);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'About RUSHD',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            // BRAND IDENTITY
            _buildBrandCard(
              isDark: isDark,
              theme: theme,
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),

            const SizedBox(height: 28),

            // DICTIONARY-STYLE MEANING
            Text(
              'THE MEANING BEHIND THE NAME',
              style: theme.textTheme.labelSmall?.copyWith(
                color: secondaryText,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.7,
              ),
            ),

            const SizedBox(height: 12),

            _buildMeaningCard(
              context,
              isDark: isDark,
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),

            const SizedBox(height: 28),

            // PRONUNCIATION
            Text(
              'SAY IT RIGHT',
              style: theme.textTheme.labelSmall?.copyWith(
                color: secondaryText,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.7,
              ),
            ),

            const SizedBox(height: 12),

            _buildPronunciationCard(
              context,
              isDark: isDark,
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),

            const SizedBox(height: 28),

            // OUR PURPOSE
            _buildPurposeSection(
              context,
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),

            const SizedBox(height: 28),

            // CLOSING BRAND STATEMENT
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? _emerald.withValues(alpha: 0.20)
                    : _emerald.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _emerald.withValues(alpha: 0.18)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: _gold,
                    size: 25,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'A little closer to what matters.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'May every step bring you closer to guidance, '
                    'purpose and a more mindful life.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: secondaryText,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Text(
                    'RUSHD',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: secondaryText,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryText.withValues(alpha: 0.75),
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

  Widget _buildBrandCard({
    required bool isDark,
    required ThemeData theme,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0F3229), Color(0xFF0A1F1A), Color(0xFF071411)]
              : const [Color(0xFFEDF5F0), Color(0xFFF7FAF8), Color(0xFFFAFAF7)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: _emerald.withValues(alpha: isDark ? 0.30 : 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.45)
                : _emerald.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          /// LOGO EMBEDDED IN A GLASS DOCK WITH AMBIENT GLOW
          Stack(
            alignment: Alignment.center,
            children: [
              // Ambient background glow behind logo
              Container(
                width: 160,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _emerald.withValues(alpha: isDark ? 0.35 : 0.15),
                      blurRadius: 36,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Logo Container
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF163E33).withValues(alpha: 0.85)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : _emerald.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.06,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  isDark
                      ? 'assets/images/rushd_text_darkmode.png'
                      : 'assets/images/rushd_text_lightmode.png',
                  height: 60,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          /// SUBTLE DECORATIVE DIVIDER ACCENT
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 1,
                color: _gold.withValues(alpha: 0.4),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.star_rounded,
                  size: 10,
                  color: _gold.withValues(alpha: 0.7),
                ),
              ),
              Container(
                width: 24,
                height: 1,
                color: _gold.withValues(alpha: 0.4),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// HEADLINE
          Text(
            'More than a name.',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: 'Cinzel', // Or your custom serif like 'Playfair Display' / 'Cinzel'
              color: primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              height: 1.25,
              shadows: [
                Shadow(
                  color: primaryText.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// SUBTITLE / BODY
          Text(
            'A reminder of the path we strive to follow.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: secondaryText.withValues(alpha: 0.85),
              fontFamily: 'serif',
              height: 1.6,
              fontSize: 14.5,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningCard(
    BuildContext context, {
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: isDark ? const Color(0xFF8DD6B4) : _emerald,
                size: 20,
              ),
              const SizedBox(width: 9),
              Text(
                'ARABIC • رُشْد',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: secondaryText,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'رُشْد',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 48,
              height: 1.25,
              color: _gold,
              fontWeight: FontWeight.w600,
              shadows: [
                // 1. Soft ambient golden glow behind the text
                Shadow(
                  color: _gold.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 0),
                ),
                // 2. Deep warm shadow below for 3D depth and elevation
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'rushd  /  noun',
            style: theme.textTheme.titleMedium?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 18),

          Divider(color: theme.dividerColor.withValues(alpha: 0.5)),

          const SizedBox(height: 14),

          Text(
            'Meaning',
            style: theme.textTheme.labelLarge?.copyWith(
              color: secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Right guidance. The right path. Sound judgment.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: primaryText,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'In Arabic, Rushd expresses the idea of being rightly '
            'guided, following a sound course and exercising good '
            'judgment. It can also convey maturity and good sense.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: secondaryText,
              height: 1.75,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? _emerald.withValues(alpha: 0.20)
                  : _emerald.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: _gold,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'That meaning inspires our vision: helping you '
                    'stay connected to your worship and your purpose.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primaryText,
                      height: 1.65,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPronunciationCard(
    BuildContext context, {
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark
                      ? _emerald.withValues(alpha: 0.25)
                      : _emerald.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  color: isDark ? const Color(0xFF8DD6B4) : _emerald,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rushd',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '/ruʃd/',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondaryText,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252B28) : const Color(0xFFF5F5F1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOT “RUSHED”',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFC16A52),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The ending matters.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Finish with the “sh” sound followed immediately '
                  'by “d” — not the “sht” ending of the English word '
                  '“rushed”.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryText,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'A little Arabic, a meaningful name, a different ending.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryText,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeSection(
    BuildContext context, {
    required Color primaryText,
    required Color secondaryText,
  }) {
    final theme = Theme.of(context);

    final features = [
      (
        icon: Icons.access_time_rounded,
        title: 'Prayer',
        description: 'Keep prayer times within reach.',
      ),
      (
        icon: Icons.menu_book_rounded,
        title: 'Quran',
        description: 'Make time for recitation and reflection.',
      ),
      (
        icon: Icons.explore_rounded,
        title: 'Qibla',
        description: 'Find the direction for your salah.',
      ),
      (
        icon: Icons.favorite_outline_rounded,
        title: 'Duas & Dhikr',
        description: 'Build small, meaningful daily habits.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OUR PURPOSE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: secondaryText,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.7,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Worship, woven into everyday life.',
          style: theme.textTheme.titleLarge?.copyWith(
            color: primaryText,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          'RUSHD brings essential worship tools together in one '
          'calm, thoughtful space — helping make your daily '
          'connection with Allah more accessible.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: secondaryText,
            height: 1.75,
          ),
        ),

        const SizedBox(height: 20),

        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _emerald.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.24 : 0.07,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    feature.icon,
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF8DD6B4)
                        : _emerald,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: primaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
