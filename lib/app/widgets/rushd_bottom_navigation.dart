import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/premium/feature_access_controller.dart';

const _navDuration = Duration(milliseconds: 520);
const _navCurve = Curves.easeOutCubic;

Color _accentOf(ColorScheme colors, bool dark) {
  return dark ? Color.lerp(colors.primary, Colors.white, 0.2)! : colors.primary;
}

class RushdBottomNavigation extends ConsumerWidget {
  const RushdBottomNavigation({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium =
        ref.watch(featureAccessControllerProvider).tier.name == 'premium';

    final items = [
      const _NavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItem(
        icon: isPremium
            ? Icons.person_outline_rounded
            : Icons.workspace_premium_outlined,
        selectedIcon: isPremium
            ? Icons.person_rounded
            : Icons.workspace_premium_rounded,
        label: isPremium ? 'You' : 'Premium',
        showBadge: !isPremium,
      ),
      const _NavItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        label: 'Settings',
      ),
      const _NavItem(
        icon: Icons.info_outline_rounded,
        selectedIcon: Icons.info_rounded,
        label: 'RUSHD',
        svgAsset: 'assets/icons/rushd_logo_svg.svg',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          child: _GlassBar(
            items: items,
            currentIndex: navigationShell.currentIndex,
            onSelected: (index) {
              HapticFeedback.selectionClick();
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    this.icon,
    this.selectedIcon,
    required this.label,
    this.svgAsset,
    this.showBadge = false,
  });

  final IconData? icon;
  final IconData? selectedIcon;
  final String label;
  final String? svgAsset;
  final bool showBadge;
}

class _GlassBar extends StatelessWidget {
  const _GlassBar({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const _height = 70.0;
  static const _inset = 7.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final tint = colors.surface.withValues(alpha: dark ? 0.2 : 0.28);
    final glassTop = Color.alphaBlend(
      Colors.white.withValues(alpha: dark ? 0.1 : 0.5),
      tint,
    );
    final glassBottom = Color.alphaBlend(
      Colors.white.withValues(alpha: dark ? 0.02 : 0.12),
      tint,
    );
    final borderStart = dark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.9);
    final borderEnd = dark
        ? Colors.white.withValues(alpha: 0.05)
        : colors.outlineVariant.withValues(alpha: 0.35);

    final accent = _accentOf(colors, dark);
    final accentEnd = Color.lerp(accent, colors.tertiary, 0.35)!;
    const pillHeight = _height - _inset * 2;

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final inner = constraints.maxWidth - _inset * 2;
          final selectedWidth = inner * 0.37;
          final otherWidth = (inner - selectedWidth) / (items.length - 1);
          final pillLeft = _inset + currentIndex * otherWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: const _OuterClipper(),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: const StadiumBorder(),
                      shadows: [
                        BoxShadow(
                          color: colors.shadow.withValues(
                            alpha: dark ? 0.38 : 0.12,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipPath(
                  clipper: const ShapeBorderClipper(shape: StadiumBorder()),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [glassTop, glassBottom],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ClipPath(
                  clipper: const ShapeBorderClipper(shape: StadiumBorder()),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedPositioned(
                        duration: _navDuration,
                        curve: _navCurve,
                        left: pillLeft,
                        top: _inset,
                        width: selectedWidth,
                        height: pillHeight,
                        child: CustomPaint(
                          painter: _PillLightPainter(
                            start: accent,
                            end: accentEnd,
                            intensity: dark ? 1.0 : 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GlassBorderPainter(
                      start: borderStart,
                      end: borderEnd,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _inset,
                right: _inset,
                top: _inset,
                bottom: _inset,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      AnimatedContainer(
                        duration: _navDuration,
                        curve: _navCurve,
                        width: i == currentIndex ? selectedWidth : otherWidth,
                        child: _NavButton(
                          item: items[i],
                          selected: i == currentIndex,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OuterClipper extends CustomClipper<Path> {
  const _OuterClipper();

  @override
  Path getClip(Size size) {
    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRect(Rect.fromLTRB(-90, -90, size.width + 90, size.height + 140)),
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(size.height / 2),
        ),
      ),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _PillLightPainter extends CustomPainter {
  const _PillLightPainter({
    required this.start,
    required this.end,
    required this.intensity,
  });

  final Color start;
  final Color end;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(size.height / 2),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.7),
          radius: 1.1,
          colors: [
            start.withValues(alpha: 0.22 * intensity),
            start.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            start.withValues(alpha: 0.16 * intensity),
            end.withValues(alpha: 0.06 * intensity),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [start.withValues(alpha: 0.95), end.withValues(alpha: 0.35)],
        ).createShader(rect),
    );

    final dot = Offset(size.width / 2, size.height - 9);
    canvas.drawCircle(
      dot,
      5,
      Paint()
        ..color = start.withValues(alpha: 0.3 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(dot, 1.8, Paint()..color = start.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(covariant _PillLightPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.end != end ||
        oldDelegate.intensity != intensity;
  }
}

class _GlassBorderPainter extends CustomPainter {
  const _GlassBorderPainter({required this.start, required this.end});

  final Color start;
  final Color end;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.6),
      Radius.circular(size.height / 2),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          start,
          end,
          start.withValues(alpha: start.a * 0.5),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final foreground = selected
        ? _accentOf(colors, dark)
        : colors.onSurface.withValues(alpha: dark ? 0.72 : 0.62);

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                        child: item.svgAsset != null
                            ? SvgPicture.asset(
                                item.svgAsset!,
                                key: ValueKey(selected),
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                  foreground,
                                  BlendMode.srcIn,
                                ),
                              )
                            : Icon(
                                selected ? item.selectedIcon : item.icon,
                                key: ValueKey(selected),
                                size: 24,
                                color: foreground,
                              ),
                      ),
                      if (item.showBadge && !selected)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: colors.tertiary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.surface,
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: selected ? 1.0 : 0.0),
                    duration: _navDuration,
                    curve: _navCurve,
                    builder: (context, t, child) => ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: t,
                        child: Opacity(opacity: t, child: child),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
