import 'dart:math' as math;

import 'package:flutter/material.dart';

class QiblaInfoCard extends StatelessWidget {
  const QiblaInfoCard({
    super.key,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.qiblaBearing,
  });

  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final double qiblaBearing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? const [Color(0xFF123D38), Color(0xFF0B2928)]
        : const [Color(0xFF176B5B), Color(0xFF10483F)];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10483F).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Subtle decorative background pattern.
            Positioned(
              right: -38,
              top: -45,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: math.pi / 8,
                  child: Icon(
                    Icons.grid_4x4_rounded,
                    size: 190,
                    color: Colors.white.withValues(alpha: 0.035),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 18,
              top: 18,
              child: Icon(
                Icons.explore_outlined,
                size: 78,
                color: const Color(0xFFD6C18A).withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location heading.
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFFE3D19F),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              city.isNotEmpty ? city : 'Current location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFB9DCC7,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFFB9DCC7,
                            ).withValues(alpha: 0.22),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9BE0B2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'GPS',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFFD6F2DF),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Qibla bearing highlight.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.075),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD6C18A,
                            ).withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.navigation_rounded,
                            color: Color(0xFFE5D29A),
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
                                  fontWeight: FontWeight.w600,
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
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
                                              alpha: 0.68,
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

                  // Coordinates.
                  Row(
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        size: 16,
                        color: const Color(0xFFD6C18A).withValues(alpha: 0.95),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'LAT  ${latitude.toStringAsFixed(4)}°'
                          '     LNG  ${longitude.toStringAsFixed(4)}°',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.25,
                            fontFeatures: const [],
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
    );
  }
}
