import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/premium/feature_access_controller.dart';

class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final access = ref.watch(featureAccessControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 42,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_rounded,
              size: 42,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your RUSHD account',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your profile and membership information',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_rounded),
              title: const Text('Membership'),
              subtitle: Text(
                access.tier.name == 'premium' ? 'RUSHD Premium' : 'Free plan',
              ),
              trailing: const Icon(Icons.verified_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Personal information'),
                  subtitle: const Text(
                    'Connect your account to view your details.',
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Subscription'),
                  subtitle: const Text('View membership and billing details'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
