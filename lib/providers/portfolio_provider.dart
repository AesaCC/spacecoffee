import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import '../models/asset.dart';
import '../services/market_service.dart';

final marketServiceProvider = Provider<MarketService>(
  (ref) => MarketService(alphaVantageApiKey),
);

// Base asset definitions — prices here are fallback mock data only.
// fetchSymbol: non-null = fetch live from Alpha Vantage; null = use mock.
const _baseAssets = [
  (
    name: 'Space Coffee',
    ticker: 'SCOF',
    realTicker: 'KC',
    fetchSymbol: null, // coffee futures — not on free tier
    price: 8847.00,
    changePercent: 1.23,
  ),
  (
    name: 'Cortex Credits',
    ticker: 'CXC',
    realTicker: 'BTC',
    fetchSymbol: null, // crypto — not on free tier
    price: 42381.50,
    changePercent: 3.24,
  ),
  (
    name: 'Blue Sun Corp.',
    ticker: 'BSC',
    realTicker: 'AAPL',
    fetchSymbol: 'AAPL',
    price: 189.75,
    changePercent: -1.08,
  ),
  (
    name: 'Helium-3 Futures',
    ticker: 'HE3',
    realTicker: 'NG',
    fetchSymbol: null, // commodity futures — not on free tier
    price: 2.43,
    changePercent: 5.61,
  ),
  (
    name: 'Dylinium Ore',
    ticker: 'DYL',
    realTicker: 'GLD',
    fetchSymbol: 'GLD',
    price: 185.40,
    changePercent: -0.43,
  ),
  (
    name: 'Alliance Bonds',
    ticker: 'ALB',
    realTicker: 'SPY',
    fetchSymbol: 'SPY',
    price: 478.22,
    changePercent: 0.87,
  ),
  (
    name: 'Osiris Grain Co.',
    ticker: 'OGC',
    realTicker: 'ZW',
    fetchSymbol: null, // wheat futures — not on free tier
    price: 584.00,
    changePercent: -2.15,
  ),
];

final portfolioProvider = FutureProvider<List<Asset>>((ref) async {
  final service = ref.read(marketServiceProvider);

  final assets = await Future.wait(
    _baseAssets.map((a) async {
      if (a.fetchSymbol == null) {
        return Asset(
          name: a.name,
          ticker: a.ticker,
          realTicker: a.realTicker,
          price: a.price,
          changePercent: a.changePercent,
          isLive: false,
        );
      }

      final quote = await service.fetchQuote(a.fetchSymbol!);

      return Asset(
        name: a.name,
        ticker: a.ticker,
        realTicker: a.realTicker,
        price: quote?.price ?? a.price,
        changePercent: quote?.changePercent ?? a.changePercent,
        isLive: quote != null,
      );
    }),
  );

  return assets;
});
