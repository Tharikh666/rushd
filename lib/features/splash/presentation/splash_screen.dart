import 'dart:math' as math;

import 'package:flutter/material.dart';

class RushdSplashScreen extends StatefulWidget {
  const RushdSplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<RushdSplashScreen> createState() => _RushdSplashScreenState();
}

class _RushdSplashScreenState extends State<RushdSplashScreen>
    with TickerProviderStateMixin {
  static const Color emerald = Color(0xFF064E3B);
  static const Color deepEmerald = Color(0xFF022C22);
  static const Color gold = Color(0xFFC7A96B);
  static const Color canvas = Color(0xFFFCFCFA);

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
      duration: const Duration(seconds: 12),
    )..repeat();

    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoScale = Tween<double>(begin: 0.78, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.08, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _revealController,
      curve: const Interval(0.05, 0.55, curve: Curves.easeIn),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
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

    // Allow the branding animation to finish before entering the app.
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

    final ambientColor = isDark
        ? const Color(0xFF10B981)
        : const Color(0xFF064E3B);

    final taglineColor = isDark
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF022C22);

    return Scaffold(
      backgroundColor: background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Soft emerald ambient light.
          AnimatedBuilder(
            animation: _orbitController,
            builder: (context, child) {
              final movement = math.sin(_orbitController.value * math.pi * 2);

              return Positioned(
                left: size.width * 0.5 - 190 + movement * 16,
                top: size.height * 0.40 - 190,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ambientColor.withValues(alpha: 0.10),
                        ambientColor.withValues(alpha: 0.035),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Subtle animated ornamental rings.
          Center(
            child: AnimatedBuilder(
              animation: _orbitController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _orbitController.value * math.pi * 2,
                  child: CustomPaint(
                    size: const Size(310, 310),
                    painter: _OrbitPainter(
                      color: emerald.withValues(alpha: 0.10),
                    ),
                  ),
                );
              },
            ),
          ),

          // Small glints of light.
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

          // Main brand reveal.
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
                                  begin: Alignment(x - 0.4, 0),
                                  end: Alignment(x + 0.4, 0),
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
                            padding: EdgeInsets.all(isDark ? 18 : 0),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isDark
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.12),
                                        blurRadius: 40,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/rushd_text_lightmode.png',
                                width: size.width * (isDark ? 0.72 : 0.82),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: Column(
                      children: [
                        Container(
                          width: 34,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'A LITTLE CLOSER TO WHAT MATTERS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: taglineColor.withValues(alpha: 0.75),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom loading indicator.
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: Column(
              children: [
                SizedBox(
                  width: 92,
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 2,
                          backgroundColor: emerald.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            emerald,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'MADE FOR YOUR JOURNEY',
                  style: TextStyle(
                    color: deepEmerald.withValues(alpha: 0.45),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.1,
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

    canvas.drawCircle(center, size.width * 0.39, paint);
    canvas.drawCircle(center, size.width * 0.47, paint);

    final accentPaint = Paint()
      ..color = const Color(0xFFC7A96B).withValues(alpha: 0.48)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.47),
      2.1,
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
      Offset(0.16, 0.28),
      Offset(0.82, 0.32),
      Offset(0.22, 0.67),
      Offset(0.78, 0.72),
      Offset(0.50, 0.20),
      Offset(0.88, 0.53),
    ];

    for (var i = 0; i < positions.length; i++) {
      final position = positions[i];
      final phase = (progress * 2 * math.pi + i * 1.1);
      final opacity = (0.15 + 0.65 * (0.5 + 0.5 * math.sin(phase))).clamp(
        0.0,
        1.0,
      );

      paint.color = color.withValues(alpha: opacity * 0.65);

      final center = Offset(
        position.dx * size.width,
        position.dy * size.height,
      );

      final radius = 1.0 + (i % 3) * 0.45;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
