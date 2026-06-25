import 'dart:math';

extension DurationExtension on num {
  num promotion(num discountedAmount) {
    if (this <= 0 || discountedAmount <= 0 || discountedAmount >= this) {
      return 0;
    }

    final discount = this - discountedAmount;
    return ((discount / this) * 100).round();
  }

  // Exponential Delay Calculation
  Duration getExponentialDelay(int retries) {
    if (retries <= 0) return const Duration(seconds: 5); // 1st failure: 5s

    // Formula: 5 * 6^retries (ဥပမာ- retries=1 ဖြစ်လျှင် 5 * 6^1 = 30s)
    // retries=2 ဖြစ်လျှင် 5 * 6^2 = 180s (3 မိနစ်)
    int seconds = 5 * pow(6, retries).toInt();

    // Max Delay ကို ၁ နာရီ (၃၆၀၀ စက္ကန့်) ထက် မကျော်အောင် ကန့်သတ်ခြင်း
    const int maxSeconds = 3600;
    if (seconds > maxSeconds) seconds = maxSeconds;

    return Duration(seconds: seconds);
  }
}
