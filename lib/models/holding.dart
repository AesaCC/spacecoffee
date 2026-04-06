/// Represents the player's ownership of a single asset.
class Holding {
  final String ticker;
  final double quantity;       // how many units owned
  final double avgBuyPrice;    // weighted average price paid per unit

  const Holding({
    required this.ticker,
    required this.quantity,
    required this.avgBuyPrice,
  });

  /// Current value of this holding at the given market price.
  double currentValue(double marketPrice) => quantity * marketPrice;

  /// Profit or loss vs what was paid.
  double pnl(double marketPrice) =>
      currentValue(marketPrice) - (quantity * avgBuyPrice);

  /// P&L as a percentage of the original cost.
  double pnlPercent(double marketPrice) =>
      ((marketPrice - avgBuyPrice) / avgBuyPrice) * 100;

  /// Returns a new Holding after buying more units.
  Holding withAdditionalPurchase(double qty, double price) {
    final totalQty = quantity + qty;
    final totalCost = (quantity * avgBuyPrice) + (qty * price);
    return Holding(
      ticker: ticker,
      quantity: totalQty,
      avgBuyPrice: totalCost / totalQty,
    );
  }

  /// Returns a new Holding after selling some units (avg price unchanged).
  Holding withSale(double qty) => Holding(
        ticker: ticker,
        quantity: quantity - qty,
        avgBuyPrice: avgBuyPrice,
      );
}
