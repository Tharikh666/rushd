import 'package:flutter/material.dart';

import '../../../core/theme/rushd_colors.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('RUSHD Premium')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF00564B), Color(0xFF07816D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFFFD875),
                  size: 58,
                ),
                SizedBox(height: 20),
                Text(
                  'Go beyond the essentials',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Unlock the complete RUSHD worship experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Your Premium experience',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const _PremiumFeature(
            icon: Icons.menu_book_rounded,
            title: 'Enhanced Quran experience',
            subtitle: 'Explore advanced reading features.',
          ),
          const _PremiumFeature(
            icon: Icons.graphic_eq_rounded,
            title: 'Deeper worship tools',
            subtitle: 'Access additional worship features as they launch.',
          ),
          const _PremiumFeature(
            icon: Icons.favorite_rounded,
            title: 'Support RUSHD',
            subtitle: 'Help us continue building meaningful tools.',
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: null,
            child: const Text('Subscriptions coming soon'),
          ),
          const SizedBox(height: 12),
          Text(
            'Your available features depend on your subscription plan.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RushdColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
