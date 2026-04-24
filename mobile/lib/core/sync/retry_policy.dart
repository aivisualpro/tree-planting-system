import 'dart:math';

class RetryPolicy {
  static const int maxAttempts = 10;

  Duration nextRetryDelay(int attempts) {
    // exponential backoff starting at 30s, up to 1h
    return Duration(seconds: min(pow(2, attempts).toInt() * 30, 3600));
  }
}
