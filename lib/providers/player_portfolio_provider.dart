import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/holding.dart';

/// The player's full financial state — credits on hand and all holdings.
class PlayerPortfolio {
  final double credits;
  final Map<String, Holding> holdings; // keyed by ticker

  const PlayerPortfolio({
    required this.credits,
    required this.holdings,
  });

  /// Total value of all holdings at current market prices.
  double totalHoldingsValue(Map<String, double> marketPrices) =>
      holdings.values.fold(0.0, (sum, h) {
        final price = marketPrices[h.ticker] ?? h.avgBuyPrice;
        return sum + h.currentValue(price);
      });

  /// Net worth = credits + value of all holdings.
  double netWorth(Map<String, double> marketPrices) =>
      credits + totalHoldingsValue(marketPrices);
}

class PlayerPortfolioNotifier extends Notifier<PlayerPortfolio> {
  @override
  PlayerPortfolio build() => const PlayerPortfolio(
        credits: 10000.0, // starting credits
        holdings: {},
      );

  /// Buy [quantity] units of [ticker] at [price] each.
  /// Returns true if the purchase succeeded, false if insufficient credits.
  bool buy(String ticker, double quantity, double price) {
    final cost = quantity * price;
    if (cost > state.credits) return false;

    final existing = state.holdings[ticker];
    final updated = existing != null
        ? existing.withAdditionalPurchase(quantity, price)
        : Holding(ticker: ticker, quantity: quantity, avgBuyPrice: price);

    state = PlayerPortfolio(
      credits: state.credits - cost,
      holdings: {...state.holdings, ticker: updated},
    );
    return true;
  }

  /// Sell [quantity] units of [ticker] at [price] each.
  /// Returns true if the sale succeeded, false if not enough units held.
  bool sell(String ticker, double quantity, double price) {
    final holding = state.holdings[ticker];
    if (holding == null || holding.quantity < quantity) return false;

    final proceeds = quantity * price;
    final updatedHoldings = Map<String, Holding>.from(state.holdings);

    if (holding.quantity - quantity < 0.00001) {
      // Sold all — remove the holding entirely
      updatedHoldings.remove(ticker);
    } else {
      updatedHoldings[ticker] = holding.withSale(quantity);
    }

    state = PlayerPortfolio(
      credits: state.credits + proceeds,
      holdings: updatedHoldings,
    );
    return true;
  }
}

final playerPortfolioProvider =
    NotifierProvider<PlayerPortfolioNotifier, PlayerPortfolio>(
  PlayerPortfolioNotifier.new,
);
