class Asset {
  final String name;           // space fiction name, e.g. "Helium-3"
  final String ticker;         // short code, e.g. "HE3"
  final String realTicker;     // real-world ticker for API, e.g. "NG"
  final double price;          // current price in credits
  final double changePercent;  // % change today, positive = up, negative = down

  const Asset({
    required this.name,
    required this.ticker,
    required this.realTicker,
    required this.price,
    required this.changePercent,
  });
}
