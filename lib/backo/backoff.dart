import 'dart:math';

class Backoff {
  int ms = 100;
  int max = 10000;
  int factor = 2;
  double jitter;
  int attempts;

  Backoff() {}

  int duration() {
    BigInt ms = BigInt.from(this.ms) * (BigInt.from(this.factor).pow(this.attempts++));
    if (jitter != 0.0) {
      double rand = new Random().nextDouble();
      BigInt deviation = BigInt.from(rand * jitter * ms.toDouble());
      ms = ((rand*10).floor() & 1) == 0 ? ms -= deviation : ms += deviation;
    }
    return min(ms.toInt(), this.max);
  }

  void reset() {
    this.attempts = 0;
  }

  Backoff setMin(int min) {
    this.ms = min;
    return this;
  }

  Backoff setMax(int max) {
    this.max = max;
    return this;
  }

  Backoff setFactor(int factor) {
    this.factor = factor;
    return this;
  }

  Backoff setJitter(double jitter) {
    this.jitter = jitter;
    return this;
  }

  int getAttempts() {
    return this.attempts;
  }
}