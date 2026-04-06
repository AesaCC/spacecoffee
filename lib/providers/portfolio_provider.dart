import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset.dart';

// Mock data — each space asset maps to a real-world instrument for later
final portfolioProvider = Provider<List<Asset>>((ref) {
  return const [
    Asset(
      name: 'Cortex Credits',
      ticker: 'CXC',
      realTicker: 'BTC',
      price: 42381.50,
      changePercent: 3.24,
    ),
    Asset(
      name: 'Blue Sun Corp.',
      ticker: 'BSC',
      realTicker: 'AAPL',
      price: 189.75,
      changePercent: -1.08,
    ),
    Asset(
      name: 'Helium-3 Futures',
      ticker: 'HE3',
      realTicker: 'NG',
      price: 2.43,
      changePercent: 5.61,
    ),
    Asset(
      name: 'Dylinium Ore',
      ticker: 'DYL',
      realTicker: 'GC',
      price: 2034.10,
      changePercent: -0.43,
    ),
    Asset(
      name: 'Alliance Bonds',
      ticker: 'ALB',
      realTicker: 'SPY',
      price: 478.22,
      changePercent: 0.87,
    ),
    Asset(
      name: 'Osiris Grain Co.',
      ticker: 'OGC',
      realTicker: 'ZW',
      price: 584.00,
      changePercent: -2.15,
    ),
  ];
});
