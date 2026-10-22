import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../widgets/qibla_info_card.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  double _heading = 0;
  double _qiblaDirection = 0;

  Position? _position;
  String _currentCity = 'Finding location...';
  String _currentCountry = '';

  String? _errorMessage;
  bool _isLoading = true;
  bool _alignmentFeedbackGiven = false;

  StreamSubscription<CompassEvent>? _compassSubscription;

  double get _relativeQibla =>
      ((_qiblaDirection - _heading + 360) % 360) * pi / 180;

  double get _headingDifference =>
      ((_qiblaDirection - _heading + 540) % 360) - 180;

  bool get _isAligned => _headingDifference.abs() < 8;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showError(
          'Location services are turned off. '
          'Enable location to find the Qibla direction.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showError(
          'Location permission is required to calculate '
          'the Qibla direction.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Location permission is permanently denied. '
          'Enable it in your device settings.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final qibla = _calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      String city = 'Unknown location';
      String country = '';

      try {
        final geocoding = Geocoding();

        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          city = place.locality?.isNotEmpty == true
              ? place.locality!
              : place.subAdministrativeArea?.isNotEmpty == true
              ? place.subAdministrativeArea!
              : 'Unknown location';
          country = place.country ?? '';
        }
      } catch (_) {
        // Coordinates and compass can still work without geocoding.
      }

      if (!mounted) return;

      setState(() {
        _position = position;
        _qiblaDirection = qibla;
        _currentCity = city;
        _currentCountry = country;
        _isLoading = false;
        _errorMessage = null;
      });

      final stream = FlutterCompass.events;

      if (stream == null) {
        setState(() {
          _errorMessage = 'The compass sensor is not available on this device.';
        });
        return;
      }

      _compassSubscription = stream.listen(
        (event) {
          if (!mounted) return;

          final heading = event.heading;

          if (heading == null || !heading.isFinite) return;

          setState(() {
            _heading = (heading + 360) % 360;
          });

          _handleAlignmentHaptic(_isAligned);
        },
        onError: (_) {
          if (!mounted) return;

          setState(() {
            _errorMessage = 'Unable to read the compass sensor.';
          });
        },
      );
    } catch (error) {
      _showError(
        'Unable to initialize the Qibla compass. '
        'Please check location permissions and try again.',
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _handleAlignmentHaptic(bool isAligned) {
    if (isAligned && !_alignmentFeedbackGiven) {
      HapticFeedback.selectionClick();
      _alignmentFeedbackGiven = true;
    } else if (!isAligned) {
      _alignmentFeedbackGiven = false;
    }
  }

  double _calculateQiblaDirection(double latitude, double longitude) {
    final userLat = _toRadians(latitude);
    final userLng = _toRadians(longitude);
    final kaabaLat = _toRadians(_kaabaLatitude);
    final kaabaLng = _toRadians(_kaabaLongitude);

    final y = sin(kaabaLng - userLng);
    final x =
        cos(userLat) * tan(kaabaLat) - sin(userLat) * cos(kaabaLng - userLng);

    final bearing = atan2(y, x);

    return (_toDegrees(bearing) + 360) % 360;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  double _toDegrees(double radians) => radians * 180 / pi;

  Future<void> _retry() async {
    await _compassSubscription?.cancel();
    _compassSubscription = null;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _alignmentFeedbackGiven = false;
    });

    await _initialize();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState(context)
          : _buildCompassContent(context),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off_rounded, size: 58, color: colors.primary),
            const SizedBox(height: 20),
            Text(
              'Compass unavailable',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
            if (_errorMessage!.contains('permanently denied'))
              TextButton(
                onPressed: Geolocator.openAppSettings,
                child: const Text('Open app settings'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassContent(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compassSize = min(constraints.maxWidth - 36, 380.0);

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            QiblaInfoCard(
              city: _currentCity ?? '',
              country: _currentCountry ?? '',
              latitude: _position!.latitude,
              longitude: _position!.longitude,
              qiblaBearing: _qiblaDirection,
            ),
            const SizedBox(height: 20),

            Center(
              child: Text(
                _isAligned
                    ? 'You are facing the Qibla'
                    : 'Turn your phone to find the Qibla',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _isAligned ? colors.primary : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: SizedBox(
                width: compassSize,
                height: compassSize,
                child: _buildCompassDial(compassSize),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _isAligned
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAligned
                          ? Icons.check_circle_rounded
                          : Icons.navigation_rounded,
                      color: _isAligned
                          ? colors.onPrimaryContainer
                          : colors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isAligned
                          ? 'Qibla aligned'
                          : 'Qibla ${_qiblaDirection.toStringAsFixed(0)}°',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _isAligned
                            ? colors.onPrimaryContainer
                            : colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                'Device heading: ${_heading.toStringAsFixed(0)}°',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _coordinateValue(
    BuildContext context, {
    required String label,
    required double value,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceVariant,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${value.toStringAsFixed(6)}°',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildCompassDial(double size) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: size * 0.9,
          height: size * 0.9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (_isAligned)
                BoxShadow(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
            ],
          ),
        ),

        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Color(0xFF0F766E),
                Color(0xFF115E59),
                Color(0xFF2DD4BF),
                Color(0xFF042F2E),
                Color(0xFF0F766E),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
        ),

        Container(
          width: size * 0.91,
          height: size * 0.91,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF042F2E), Color(0xFF115E59)],
            ),
            border: Border.all(color: const Color(0xFF2DD4BF), width: 1.2),
          ),
        ),

        Container(
          width: size * 0.895,
          height: size * 0.895,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0xFFFFFFFA), Color(0xFFF5FAF9), Color(0xFFD1E2DD)],
            ),
          ),
        ),

        Transform.rotate(
          angle: -_heading * pi / 180,
          child: SizedBox(
            width: size * 0.895,
            height: size * 0.895,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(size * 0.895),
                  painter: CompassFacePainter(),
                ),
                _buildDirectionLabel('N', 180, const Color(0xFFDC2626), size),
                _buildDirectionLabel('E', 270, const Color(0xFF475569), size),
                _buildDirectionLabel('S', 0, const Color(0xFF475569), size),
                _buildDirectionLabel('W', 90, const Color(0xFF475569), size),
                _buildDirectionLabel(
                  'NE',
                  225,
                  const Color(0xFF94A3B8),
                  size,
                  ordinal: true,
                ),
                _buildDirectionLabel(
                  'SE',
                  315,
                  const Color(0xFF94A3B8),
                  size,
                  ordinal: true,
                ),
                _buildDirectionLabel(
                  'SW',
                  45,
                  const Color(0xFF94A3B8),
                  size,
                  ordinal: true,
                ),
                _buildDirectionLabel(
                  'NW',
                  135,
                  const Color(0xFF94A3B8),
                  size,
                  ordinal: true,
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: size * 0.005,
          child: Container(
            width: size * 0.11,
            height: size * 0.11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isAligned ? const Color(0xFF0D9488) : Colors.white,
              border: Border.all(color: const Color(0xFF0F766E), width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.navigation_rounded,
              size: size * 0.045,
              color: _isAligned ? Colors.white : const Color(0xFF0F766E),
            ),
          ),
        ),

        Transform.rotate(
          angle: _relativeQibla,
          child: CustomPaint(
            size: Size.square(size * 0.74),
            painter: PremiumCompassNeedlePainter(isAligned: _isAligned),
          ),
        ),

        Container(
          width: size * 0.2,
          height: size * 0.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.7),
            border: Border.all(color: const Color(0xFFB5C9C5), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text('🕋', style: TextStyle(fontSize: size * 0.09)),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionLabel(
    String text,
    double baseAngleDegrees,
    Color color,
    double size, {
    bool ordinal = false,
  }) {
    final screenAngle = (baseAngleDegrees - _heading) * pi / 180;
    final radius = size * 0.29;

    return Transform.translate(
      offset: Offset(radius * sin(screenAngle), -radius * cos(screenAngle)),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: ordinal ? size * 0.037 : size * 0.063,
          fontWeight: ordinal ? FontWeight.w500 : FontWeight.w800,
          fontFamily: 'Courier',
        ),
      ),
    );
  }
}

class PremiumCompassNeedlePainter extends CustomPainter {
  final bool isAligned;

  const PremiumCompassNeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final northPath = Path()
      ..moveTo(center.dx, 8)
      ..lineTo(center.dx - size.width * 0.08, center.dy - size.height * 0.12)
      ..lineTo(center.dx, center.dy - size.height * 0.025)
      ..lineTo(center.dx + size.width * 0.08, center.dy - size.height * 0.12)
      ..close();

    final northPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isAligned
            ? const [Color(0xFF2DD4BF), Color(0xFF0D9488)]
            : const [Color(0xFF14B8A6), Color(0xFF0F766E)],
      ).createShader(Offset.zero & size);

    canvas.drawShadow(
      northPath,
      Colors.black.withValues(alpha: 0.25),
      8,
      false,
    );
    canvas.drawPath(northPath, northPaint);

    final southPath = Path()
      ..moveTo(center.dx, size.height - 8)
      ..lineTo(center.dx - size.width * 0.06, center.dy + size.height * 0.12)
      ..lineTo(center.dx, center.dy + size.height * 0.025)
      ..lineTo(center.dx + size.width * 0.06, center.dy + size.height * 0.12)
      ..close();

    final southPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF9CA3AF), Color(0xFF4B5563)],
      ).createShader(Offset.zero & size);

    canvas.drawPath(southPath, southPaint);

    canvas.drawCircle(
      center,
      size.width * 0.035,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Colors.white, Color(0xFF9CA3AF)],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * 0.035),
            ),
    );
  }

  @override
  bool shouldRepaint(covariant PremiumCompassNeedlePainter oldDelegate) {
    return oldDelegate.isAligned != isAligned;
  }
}

class CompassFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius - 10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFFB5C9C5).withValues(alpha: 0.7),
    );

    for (var degree = 0; degree < 360; degree += 5) {
      final angle = (degree - 90) * pi / 180;
      final isMajor = degree % 30 == 0;
      final isMedium = degree % 15 == 0 && !isMajor;

      final tickLength = isMajor
          ? 20.0
          : isMedium
          ? 15.0
          : 9.0;
      final startRadius = radius - 10 - tickLength;
      final endRadius = radius - 10;

      final start = Offset(
        center.dx + cos(angle) * startRadius,
        center.dy + sin(angle) * startRadius,
      );

      final end = Offset(
        center.dx + cos(angle) * endRadius,
        center.dy + sin(angle) * endRadius,
      );

      final color = isMajor
          ? const Color(0xFF115E59)
          : isMedium
          ? const Color(0xFF718096)
          : const Color(0xFFA0AEC0);

      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = isMajor
              ? 2
              : isMedium
              ? 1.2
              : 0.8
          ..color = color,
      );
    }

    canvas.drawCircle(
      center,
      radius * 0.52,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFFB5C9C5).withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(covariant CompassFacePainter oldDelegate) => false;
}
