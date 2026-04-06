class Asset {
  final String name;           // space fiction name, e.g. "Helium-3"
  final String ticker;         // short code, e.g. "HE3"
  final String realTicker;     // real-world ticker for API, e.g. "SPY"
  final double price;          // current price in credits
  final double changePercent;  // % change today, positive = up, negative = down
  final bool isLive;           // true = price came from API, false = mock data

  const Asset({
    required this.name,
    required this.ticker,
    required this.realTicker,
    required this.price,
    required this.changePercent,
    this.isLive = false,
  });

  // Ticker is unique — used as identity for Riverpod family providers
  @override
  bool operator ==(Object other) => other is Asset && other.ticker == ticker;

  @override
  int get hashCode => ticker.hashCode;
}
