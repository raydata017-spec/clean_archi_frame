import 'dart:math';

extension DurationExtension on num {
  num promotion(num discountedAmount) {
    if (this <= 0 || discountedAmount <= 0 || discountedAmount >= this) {
      return 0;
    }

    final discount = this - discountedAmount;
    return ((discount / this) * 100).round();
  }

  /// Exponential backoff based on the current retry attempt (`this`).
  ///
  /// attempt 1 → 30s, attempt 2 → 180s, attempt 3 → 1080s (capped at 1h).
  Duration getExponentialDelay({int maxCapSeconds = 3600}) {
    final attempt = toInt();
    if (attempt <= 0) return const Duration(seconds: 5);

    // Formula: 5 * 6^attempt
    int seconds = 5 * pow(6, attempt).toInt();
    if (seconds > maxCapSeconds) seconds = maxCapSeconds;

    return Duration(seconds: seconds);
  }
}
