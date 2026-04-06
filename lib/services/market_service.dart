import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fetches live market data from Alpha Vantage.
/// Free tier: 25 requests/day, 5 requests/minute.
class MarketService {
  static const _baseUrl = 'https://www.alphavantage.co/query';
  final String _apiKey;

  MarketService(this._apiKey);

  /// Returns the current price and daily % change for a stock or ETF symbol.
  /// Returns null if the request fails or the symbol isn't supported.
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
      return null; // network error, bad JSON, etc. — fall back to mock
    }
  }
}
