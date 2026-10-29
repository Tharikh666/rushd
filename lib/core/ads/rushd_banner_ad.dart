import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../premium/feature_access_controller.dart';

/// Shows a Google test banner to Free users on Android and iOS only.
///
/// This deliberately uses Google's sample ad unit IDs. Replace them with
/// Rushd's own AdMob banner IDs only after creating the app in AdMob.
class RushdBannerAd extends ConsumerWidget {
  const RushdBannerAd({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowAds =
        ref.watch(featureAccessControllerProvider).shouldShowAds;

    final supportedPlatform =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (!shouldShowAds || !supportedPlatform) {
      return const SizedBox.shrink();
    }

    return const _RushdBannerAdSlot();
  }
}

class _RushdBannerAdSlot extends StatefulWidget {
  const _RushdBannerAdSlot();

  @override
  State<_RushdBannerAdSlot> createState() => _RushdBannerAdSlotState();
}

class _RushdBannerAdSlotState extends State<_RushdBannerAdSlot> {
  BannerAd? _bannerAd;

  // Official Google sample banner ad units. These return test ads only.
  String get _testBannerAdUnitId {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? 'ca-app-pub-3940256099942544/2435281174'
        : 'ca-app-pub-3940256099942544/9214589741';
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final banner = BannerAd(
      adUnitId: _testBannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('RUSHD test banner failed to load: $error');
        },
      ),
    );

    _bannerAd = null;
    banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _bannerAd;
    if (banner == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              'ADVERTISEMENT',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: banner.size.width.toDouble(),
            height: banner.size.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ),
      ],
    );
  }
}
