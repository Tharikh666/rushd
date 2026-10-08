import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feature_access_controller.dart';
import 'rushd_feature.dart';

class PremiumGate extends ConsumerWidget {
  final RushdFeature feature;
  final Widget child;
  final VoidCallback? onLocked;

  const PremiumGate({
    super.key,
    required this.feature,
    required this.child,
    this.onLocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(featureAccessControllerProvider);

    final allowed = access.canAccess(feature);

    return GestureDetector(
      onTap: allowed
          ? null
          : onLocked ??
                () {
                  _showPremiumSheet(context);
                },
      child: Stack(
        children: [
          child,

          if (!allowed) Positioned(top: 10, right: 10, child: _PremiumBadge()),
        ],
      ),
    );
  }

  void _showPremiumSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded, size: 42),
                SizedBox(height: 16),
                Text(
                  'RUSHD Premium',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Unlock the complete spiritual experience.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Icon(Icons.lock_rounded, size: 12, color: Colors.white),
    );
  }
}
