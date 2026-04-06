import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import '../models/asset.dart';
import '../services/market_service.dart';

// Provides a single shared instance of MarketService
final marketServiceProvider = Provider<MarketService>(
  (ref) => MarketService(alphaVantageApiKey),
);

// Base asset definitions — prices here are fallback mock data only.
// Assets with a non-null fetchSymbol will get live prices from Alpha Vantage.
// Free tier supports stocks + ETFs only (not crypto or commodity futures).
const _baseAssets = [
  (
    name: 'Cortex Credits',
    ticker: 'CXC',
    realTicker: 'BTC',
    fetchSymbol: null, // crypto — not on free tier, uses mock
    price: 42381.50,
    changePercent: 3.24,
  ),
  (
    name: 'Blue Sun Corp.',
    ticker: 'BSC',
    realTicker: 'AAPL',
    fetchSymbol: 'AAPL', // live
    price: 189.75,
    changePercent: -1.08,
  ),
  (
    name: 'Helium-3 Futures',
    ticker: 'HE3',
    realTicker: 'NG',
    fetchSymbol: null, // commodity futures — not on free tier, uses mock
    price: 2.43,
    changePercent: 5.61,
  ),
  (
    name: 'Dylinium Ore',
    ticker: 'DYL',
    realTicker: 'GLD', // using GLD (gold ETF) as proxy for gold price
    fetchSymbol: 'GLD', // live
    price: 2034.10,
    changePercent: -0.43,
  ),
  (
    name: 'Alliance Bonds',
    ticker: 'ALB',
    realTicker: 'SPY',
    fetchSymbol: 'SPY', // live
    price: 478.22,
    changePercent: 0.87,
  ),
  (
    name: 'Osiris Grain Co.',
    ticker: 'OGC',
    realTicker: 'ZW',
    fetchSymbol: null, // wheat futures — not on free tier, uses mock
    price: 584.00,
    changePercent: -2.15,
  ),
];

// FutureProvider fetches live prices and merges them with mock fallbacks.
// The UI reads this provider and handles loading / error / data states.
final portfolioProvider = FutureProvider<List<Asset>>((ref) async {
  final service = ref.read(marketServiceProvider);

  final assets = await Future.wait(
    _baseAssets.map((a) async {
      if (a.fetchSymbol == null) {
        // No live data available — return mock values
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
