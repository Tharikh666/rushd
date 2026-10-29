import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Coordinates one Mobile Ads SDK initialization for the whole app.
///
/// Call this from app startup without awaiting it, so the first Flutter frame
/// is not blocked. Ad widgets can await the same future before loading ads.
class RushdMobileAds {
  RushdMobileAds._();

  static Future<InitializationStatus>? _initialization;

  static Future<InitializationStatus> initialize() {
    return _initialization ??= MobileAds.instance.initialize();
  }
}
