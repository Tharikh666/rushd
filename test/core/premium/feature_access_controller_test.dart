import 'package:flutter_test/flutter_test.dart';
import 'package:rushd/core/premium/feature_access_controller.dart';
import 'package:rushd/core/premium/rushd_feature.dart';
import 'package:rushd/core/premium/subscription_tier.dart';

void main() {
  group('FeatureAccessController', () {
    test('Free tier enables ads', () {
      const access = FeatureAccessController(tier: SubscriptionTier.free);

      expect(access.shouldShowAds, isTrue);
      expect(access.canAccess(RushdFeature.ads), isTrue);
    });

    test('Premium tier disables ads', () {
      const access = FeatureAccessController(tier: SubscriptionTier.premium);

      expect(access.shouldShowAds, isFalse);
      expect(access.canAccess(RushdFeature.ads), isFalse);
    });

    test('Free tier retains essential worship features', () {
      const access = FeatureAccessController(tier: SubscriptionTier.free);

      expect(access.canAccess(RushdFeature.quran), isTrue);
      expect(access.canAccess(RushdFeature.qibla), isTrue);
      expect(access.canAccess(RushdFeature.prayerTimes), isTrue);
      expect(access.canAccess(RushdFeature.duas), isTrue);
    });

    test('Premium tier can access premium features', () {
      const access = FeatureAccessController(tier: SubscriptionTier.premium);

      expect(access.canAccess(RushdFeature.advancedQuranProgress), isTrue);
      expect(access.canAccess(RushdFeature.advancedDhikrJourneys), isTrue);
    });
  });
}
