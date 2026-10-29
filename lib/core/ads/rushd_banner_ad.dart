import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../premium/feature_access_controller.dart';
import 'rushd_mobile_ads.dart';

/// Displays Google's official sample banner ad to Free users on Android/iOS.
///
/// The IDs are Google's Flutter sample banner units for development only.
/// Replace them with Rushd's own AdMob banner IDs before release.
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

  // Official Google Mobile Ads Flutter sample banner IDs.
  String get _testBannerAdUnitId {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? 'ca-app-pub-3940256099942544/2934735716'
        : 'ca-app-pub-3940256099942544/6300978111';
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    try {
      await RushdMobileAds.initialize();
      if (!mounted) return;

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
            if (mounted) {
              setState(() {
                _bannerAd = null;
              });
            }
          },
        ),
      );

      banner.load();
    } catch (error, stackTrace) {
      debugPrint('RUSHD: Could not initialize/request banner ad: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _bannerAd = null;
        });
      }
    }
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
      // Keep the production UI clean if an ad cannot load. During debugging,
      // the failure reason is printed to the Flutter console.
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final adSize = banner.size;

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
            width: adSize.width.toDouble(),
            height: adSize.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ),
      ],
    );
  }
}
