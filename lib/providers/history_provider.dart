import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset.dart';
import '../models/price_point.dart';
import 'portfolio_provider.dart';

// Fetch symbol lookup — mirrors portfolio_provider.dart
const _fetchSymbols = {
  'SCOF': null,
  'CXC': null,
  'BSC': 'AAPL',
  'HE3': null,
  'DYL': 'GLD',
  'ALB': 'SPY',
  'OGC': null,
};

/// Provides 30 days of price history for a given asset.
/// Uses live API data where available, generated mock history otherwise.
final assetHistoryProvider =
    FutureProvider.family<List<PricePoint>, Asset>((ref, asset) async {
  final fetchSymbol = _fetchSymbols[asset.ticker];

  if (fetchSymbol != null) {
    final service = ref.read(marketServiceProvider);
    final history = await service.fetchHistory(fetchSymbol);
    if (history != null && history.isNotEmpty) return history;
  }

  // Fall back to generated mock history
  return _generateMockHistory(asset.ticker, asset.price);
});

/// Generates a plausible 30-day price history via random walk.
/// Seeded from the ticker so the same asset always gets the same shape.
List<PricePoint> _generateMockHistory(String ticker, double currentPrice) {
  final seed = ticker.codeUnits.fold(0, (a, b) => a + b);
  final rng = Random(seed);

  final points = <PricePoint>[];
  final now = DateTime.now();

  // Work backwards from a price 10-20% different from current
  var price = currentPrice * (0.88 + rng.nextDouble() * 0.24);

  for (var i = 44; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    // Skip weekends — markets are closed
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      continue;
    }
    // Daily random walk: ±1.5%
    final change = (rng.nextDouble() - 0.48) * 0.03;
    price *= (1 + change);
    points.add(PricePoint(date: date, price: price));

    if (points.length == 30) break;
  }

  return points;
}
