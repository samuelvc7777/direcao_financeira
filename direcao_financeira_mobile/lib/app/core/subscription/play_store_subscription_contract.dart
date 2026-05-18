const String playStoreMonthlySubscriptionProductId = 'premium_monthly';

bool isSupportedAndroidSubscriptionCode(String code) {
  return code.trim() == playStoreMonthlySubscriptionProductId;
}
