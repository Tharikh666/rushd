import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../premium/feature_access_controller.dart';
import 'rushd_mobile_ads.dart';

/// Shows a Google test banner to Free users on Android and iOS only.
///
/// Inline adaptive banners are used because this widget is placed inside the
/// Home screen's scrollable content. The sample IDs below serve test ads only.
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.truncate()
            : MediaQuery.sizeOf(context).width.truncate();

        if (width <= 0) {
          return const SizedBox.shrink();
        }

        return _RushdBannerAdSlot(width: width);
      },
    );
  }
}

class _RushdBannerAdSlot extends StatefulWidget {
  const _RushdBannerAdSlot({required this.width});

  final int width;

  @override
  State<_RushdBannerAdSlot> createState() => _RushdBannerAdSlotState();
}

class _RushdBannerAdSlotState extends State<_RushdBannerAdSlot> {
  BannerAd? _bannerAd;
  AdSize? _loadedAdSize;

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

  Future<void> _loadBannerAd() async {
    try {
      // Do not request an ad until the shared SDK initialization completes.
      await RushdMobileAds.initialize();
      if (!mounted) return;

      final adSize =
          AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(widget.width);

      final banner = BannerAd(
      adUnitId: _testBannerAdUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          final loadedBanner = ad as BannerAd;

          // Inline adaptive banner height is known only after the platform
          // returns the loaded ad's actual size.
          final actualSize = await loadedBanner.getPlatformAdSize();

          if (!mounted || actualSize == null) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = loadedBanner;
            _loadedAdSize = actualSize;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('RUSHD test banner failed to load: $error');
        },
      ),
    );

      banner.load();
    } catch (error, stackTrace) {
      debugPrint('RUSHD: Could not initialize/request banner ad: $error');
      debugPrintStack(stackTrace: stackTrace);
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
    final adSize = _loadedAdSize;

    if (banner == null || adSize == null) {
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
            width: adSize.width.toDouble(),
            height: adSize.height.toDouble(),
            child: AdWidget(ad: banner),
          ),
        ),
      ],
    );
  }
}
