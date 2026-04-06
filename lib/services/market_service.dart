import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price_point.dart';

/// Fetches live market data from Alpha Vantage.
/// Free tier: 25 requests/day, 5 requests/minute.
class MarketService {
  static const _baseUrl = 'https://www.alphavantage.co/query';
  final String _apiKey;

  MarketService(this._apiKey);

  /// Current price + daily % change for a stock or ETF.
  /// Returns null on failure — caller falls back to mock data.
  Future<({double price, double changePercent})?> fetchQuote(
    String symbol,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final quote = data['Global Quote'] as Map<String, dynamic>?;
      if (quote == null || quote.isEmpty) return null;

      final price = double.tryParse(quote['05. price'] ?? '');
      final changeStr =
          (quote['10. change percent'] ?? '').replaceAll('%', '').trim();
      final changePercent = double.tryParse(changeStr);

      if (price == null || changePercent == null) return null;
      return (price: price, changePercent: changePercent);
    } catch (_) {
      return null;
    }
  }

  /// Last 30 trading days of closing prices for a stock or ETF.
  /// Returns null on failure — caller falls back to generated mock history.
  Future<List<PricePoint>?> fetchHistory(String symbol) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?function=TIME_SERIES_DAILY&symbol=$symbol&outputsize=compact&apikey=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final series =
          data['Time Series (Daily)'] as Map<String, dynamic>?;
      if (series == null || series.isEmpty) return null;

      // Sort dates descending, take last 30, then reverse to chronological
      final sorted = series.keys.toList()..sort((a, b) => b.compareTo(a));
      final recent = sorted.take(30).toList().reversed;

      return recent.map((dateStr) {
        final day = series[dateStr] as Map<String, dynamic>;
        final close = double.tryParse(day['4. close'] ?? '') ?? 0;
        return PricePoint(date: DateTime.parse(dateStr), price: close);
      }).toList();
    } catch (_) {
      return null;
    }
  }
}
