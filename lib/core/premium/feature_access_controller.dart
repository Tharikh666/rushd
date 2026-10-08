import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rushd_feature.dart';
import 'subscription_tier.dart';

final featureAccessControllerProvider =
Provider<FeatureAccessController>((ref) {
  // For now, default to Free.
  //
  // Later this will come from the user's subscription/account state.
  return FeatureAccessController(
    tier: SubscriptionTier.free,
  );
});

class FeatureAccessController {
  final SubscriptionTier tier;

  const FeatureAccessController({
    required this.tier,
  });

  bool canAccess(RushdFeature feature) {
    // Premium users can access everything.
    if (tier == SubscriptionTier.premium) {
      return true;
    }

    // Free users can access only the features listed here.
    return freeFeatures.contains(feature);
  }

  bool isPremium(RushdFeature feature) {
    return !canAccess(feature);
  }
}

const Set<RushdFeature> freeFeatures = {
  RushdFeature.quran,
  RushdFeature.qibla,
  RushdFeature.salahGuide,
  RushdFeature.duas,
  RushdFeature.dhikr,
  RushdFeature.prayerTimes,
  RushdFeature.dailyAyah,
};