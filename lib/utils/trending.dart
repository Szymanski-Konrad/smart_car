import 'package:flutter/material.dart';

enum Trending {
  up,
  constant,
  down,
}

extension TrendingExtension on Trending {
  IconData get icon {
    switch (this) {
      case Trending.up:
        return Icons.trending_up;
      case Trending.constant:
        return Icons.trending_neutral;
      case Trending.down:
        return Icons.trending_down;
    }
  }
}
