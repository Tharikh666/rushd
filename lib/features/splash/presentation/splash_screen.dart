import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RushdSplashScreen extends StatefulWidget {
  const RushdSplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<RushdSplashScreen> createState() => _RushdSplashScreenState();
}

class _RushdSplashScreenState extends State<RushdSplashScreen>
    with TickerProviderStateMixin {
  static const Color emerald = Color(0xFF064E3B);
  static const Color gold = Color(0xFFC7A96B);

  late final AnimationController _revealController;
  late final AnimationController _orbitController;
  late final AnimationController _lightController;
  late final AnimationController _progressController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.08, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.05, 0.55, curve: Curves.easeIn),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _revealController,
            curve: const Interval(0.05, 0.75, curve: Curves.easeOutCubic),
          ),
        );

    _taglineOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.48, 0.90, curve: Curves.easeIn),
    );

    _revealController.forward();
    _lightController.forward();
    _progressController.forward();

    // Allow branding animation to complete before transitioning into the app.
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _orbitController.dispose();
    _lightController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).scaffoldBackgroundColor;

    final ambientColor = isDark ? const Color(0xFF10B981) : emerald;
    final taglineColor = isDark ? const Color(0xFFE5E7EB) : emerald;
    final doodleColor = isDark ? Colors.white : emerald;

    // Appropriate logo asset for current theme mode
    final logoAsset = isDark
        ? 'assets/images/rushd_text_darkmode.png'
        : 'assets/images/rushd_text_lightmode.png';

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Random Scattered Doodle Watermarks in Background
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? 0.085 : 0.065,
                child: Stack(
                  children: [
                    _buildDoodleItem(
                      path: 'assets/icons/worship_icons/quran.svg',
                      left: size.width * 0.12,
                      top: size.height * 0.14,
                      size: 64,
                      angle: -0.25,
                      color: doodleColor,
                    ),
                    _buildDoodleItem(
                      path: 'assets/icons/worship_icons/yaseen.svg',
                      right: size.width * 0.12,
                      top: size.height * 0.12,
                      size: 64,
                      angle: 0.30,
                      color: doodleColor,
                    ),
                    _buildDoodleItem(
                      path: 'assets/icons/worship_icons/qibla.svg',
                      left: size.width * 0.15,
                      bottom: size.height * 0.32,
                      size: 72,
                      angle: 0.35,
                      color: doodleColor,
                    ),
                    _buildDoodleItem(
                      path: 'assets/icons/worship_icons/salah.svg',
                      right: size.width * 0.08,
                      top: size.height * 0.38,
                      size: 80,
                      angle: 0.15,
                      color: doodleColor,
                    ),
                    _buildDoodleItem(
                      path: 'assets/icons/worship_icons/tasbeeh.svg',
                      right: size.width * 0.12,
                      bottom: size.height * 0.22,
                      size: 70,
                      angle: -0.4,
                      color: doodleColor,
                    ),
                    _buildDoodleItem(
                      path: 'assets/icons/worship_icons/dua.svg',
                      left: size.width * 0.18,
                      bottom: size.height * 0.14,
                      size: 56,
                      angle: 0.2,
                      color: doodleColor,
                    ),
                    _buildDoodleItem(
                      path: 'assets/icons/worship_icons/worship.svg',
                      right: size.width * 0.35,
                      top: size.height * 0.08,
                      size: 65,
                      angle: -0.15,
                      color: doodleColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Soft breathing ambient background glow
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, child) {
              final pulse = math.sin(_orbitController.value * math.pi * 2) * 20;

              return Positioned(
                left: size.width * 0.5 - 200 + (pulse * 0.5),
                top: size.height * 0.42 - 200,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ambientColor.withValues(alpha: isDark ? 0.14 : 0.08),
                        ambientColor.withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Slow rotating ornamental geometry rings
          Center(
            child: AnimatedBuilder(
              animation: _orbitController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _orbitController.value * math.pi * 2,
                  child: CustomPaint(
                    size: const Size(320, 320),
                    painter: _OrbitPainter(
                      color: (isDark ? Colors.white : emerald).withValues(
                        alpha: 0.07,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Organic shimmering sparkle particles
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SparklePainter(
                  progress: _lightController.value,
                  color: gold,
                ),
              ),
            ),
          ),

          // 5. Central Brand Identity & Logo Reveal with Light-Sweep
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: AnimatedBuilder(
                          animation: _lightController,
                          builder: (context, child) {
                            return ShaderMask(
                              blendMode: BlendMode.dstIn,
                              shaderCallback: (bounds) {
                                final x = -1.5 + (_lightController.value * 3.5);

                                return LinearGradient(
                                  begin: Alignment(x - 0.35, 0),
                                  end: Alignment(x + 0.35, 0),
                                  colors: const [
                                    Colors.white,
                                    Colors.white,
                                    Colors.white,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ).createShader(bounds);
                              },
                              child: child,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: isDark
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.18),
                                        blurRadius: 48,
                                        spreadRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Image.asset(
                              logoAsset,
                              width: size.width * 0.76,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Tagline with gold accent divider
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'A LITTLE CLOSER TO WHAT MATTERS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: taglineColor.withValues(alpha: 0.70),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Bottom Loading Indicator & Footer Note
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Column(
              children: [
                SizedBox(
                  width: 96,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 2,
                          backgroundColor: (isDark ? Colors.white : emerald)
                              .withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? gold : emerald,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'MADE FOR YOUR JOURNEY',
                  style: TextStyle(
                    color: taglineColor.withValues(alpha: 0.40),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoodleItem({
    required String path,
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required double angle,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle,
        child: SvgPicture.asset(
          path,
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawCircle(center, size.width * 0.40, paint);
    canvas.drawCircle(center, size.width * 0.48, paint);

    final accentPaint = Paint()
      ..color = const Color(0xFFC7A96B).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.48),
      2.2,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const positions = [
      Offset(0.18, 0.26),
      Offset(0.80, 0.30),
      Offset(0.24, 0.65),
      Offset(0.76, 0.74),
      Offset(0.50, 0.18),
      Offset(0.85, 0.52),
    ];

    for (var i = 0; i < positions.length; i++) {
      final position = positions[i];
      final phase = (progress * 2 * math.pi + i * 1.2);
      final opacity = (0.15 + 0.65 * (0.5 + 0.5 * math.sin(phase))).clamp(
        0.0,
        1.0,
      );

      paint.color = color.withValues(alpha: opacity * 0.70);

      final center = Offset(
        position.dx * size.width,
        position.dy * size.height,
      );

      final radius = 1.1 + (i % 3) * 0.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
