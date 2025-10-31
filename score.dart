class Score {
  int current = 0;
  int best = 0;

  void reset() => current = 0;

  void increase() {
    current += 1;
    if (current > best) best = current;
  }
}
