import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QiblaInfoCard extends StatelessWidget {
  const QiblaInfoCard({
    super.key,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.qiblaBearing,
    required this.isAligned,
  });

  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final double qiblaBearing;
  final bool isAligned;

  // Royal Obsidian & Desert Gold Palette
  static const _gold = Color(0xFFE6CA78);
  static const _brightGold = Color(0xFFFFF1B0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Distinct Royal Obsidian Gradient
    final gradientColors = isDark
        ? const [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F1423)]
        : const [Color(0xFF1E293B), Color(0xFF2D3748)];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isAligned
              ? _gold
              : _gold.withValues(alpha: isDark ? 0.35 : 0.25),
          width: isAligned ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isAligned
                ? _gold.withValues(alpha: 0.35)
                : const Color(
                    0xFF0F172A,
                  ).withValues(alpha: isDark ? 0.45 : 0.20),
            blurRadius: isAligned ? 32 : 24,
            spreadRadius: isAligned ? 2 : 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Decorative background pattern
            Positioned(
              right: -38,
              top: -45,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: math.pi / 8,
                  child: Icon(
                    Icons.grid_4x4_rounded,
                    size: 190,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ),

            // GLOWING SVG WATERMARK
            Positioned(
              right: 15,
              top: 15,
              child: IgnorePointer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient radial glow behind the SVG when aligned
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: isAligned ? 1.0 : 0.0,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: 0.65),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SVG Watermark itself with dynamic color & opacity transition
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: isAligned ? 0.90 : 0.16,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        child: SvgPicture.asset(
                          'assets/icons/worship_icons/qibla.svg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            isAligned ? _brightGold : _gold,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location heading
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _gold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: _gold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR LOCATION',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.65),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              city.isNotEmpty ? city : 'Current location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (country.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                country,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Qibla bearing highlight box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withValues(alpha: 0.20)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.navigation_rounded,
                            color: _gold,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QIBLA DIRECTION',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${qiblaBearing.round()}°',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          color: _gold,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1.1,
                                          height: 1.1,
                                        ),
                                  ),
                                  const SizedBox(width: 9),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'from North',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.75,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Coordinates and GPS Chip row at the bottom
                  Row(
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        size: 16,
                        color: _gold.withValues(alpha: 0.90),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'LAT  ${latitude.toStringAsFixed(4)}°'
                          '     LNG  ${longitude.toStringAsFixed(4)}°',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // GPS Chip at bottom right
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF38BDF8,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFF38BDF8,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF38BDF8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'GPS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFE0F2FE),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
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
          ],
        ),
      ),
    );
  }
}
