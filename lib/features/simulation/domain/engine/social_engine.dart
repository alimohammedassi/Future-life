class SocialEngine {
  /// Calculate social balance (0-100) based on family and networking vs social media.
  double calculateBalanceScore({
    required double socialMediaHours,
    required double familyHours,
    required double networkingHours,
  }) {
    // Good hours vs Bad hours (simplified logic)
    final positiveHours = familyHours + networkingHours;
    final negativeHours = socialMediaHours;

    final balance = 50 + (positiveHours * 2) - (negativeHours * 3);
    return balance.clamp(0, 100);
  }

  /// Calculate isolation risk (0-100%)
  double calculateIsolationRisk({
    required double socialMediaHours,
    required double familyHours,
    required double networkingHours,
  }) {
    // High social media and low real-world interaction = high isolation
    final realWorldHours = familyHours + networkingHours;
    final risk = (socialMediaHours * 4) - (realWorldHours * 2);
    return risk.clamp(0, 100);
  }
}
