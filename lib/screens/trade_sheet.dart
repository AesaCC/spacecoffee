import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset.dart';
import '../providers/player_portfolio_provider.dart';

/// Shows a modal bottom sheet for buying or selling [asset].
Future<void> showTradeSheet(
  BuildContext context,
  Asset asset, {
  bool startOnSell = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TradeSheet(asset: asset, startOnSell: startOnSell),
  );
}

class TradeSheet extends ConsumerStatefulWidget {
  final Asset asset;
  final bool startOnSell;

  const TradeSheet({super.key, required this.asset, this.startOnSell = false});

  @override
  ConsumerState<TradeSheet> createState() => _TradeSheetState();
}

class _TradeSheetState extends ConsumerState<TradeSheet> {
  late bool _isSelling;
  final _controller = TextEditingController();
  double _quantity = 0;

  @override
  void initState() {
    super.initState();
    _isSelling = widget.startOnSell;
    _controller.addListener(() {
      setState(() {
        _quantity = double.tryParse(_controller.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(playerPortfolioProvider);
    final holding = portfolio.holdings[widget.asset.ticker];
    final totalCost = _quantity * widget.asset.price;
    final canAfford = totalCost <= portfolio.credits && _quantity > 0;
    final canSell =
        holding != null && _quantity > 0 && _quantity <= holding.quantity;
    final isValid = _isSelling ? canSell : canAfford;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          border: Border(
            top: BorderSide(color: Color(0xFF2A2A4A), width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A4A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.asset.name,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE0D5B8),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₡ ${widget.asset.price.toStringAsFixed(2)} per unit',
                        style: GoogleFonts.ibmPlexMono(
                          color: const Color(0xFF8B8B9E),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8B8B9E)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // BUY / SELL tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _TabButton(
                    label: 'BUY',
                    selected: !_isSelling,
                    color: const Color(0xFF4CAF50),
                    onTap: () => setState(() {
                      _isSelling = false;
                      _controller.clear();
                    }),
                  ),
                  const SizedBox(width: 8),
                  _TabButton(
                    label: 'SELL',
                    selected: _isSelling,
                    color: const Color(0xFFE53935),
                    onTap: holding != null
                        ? () => setState(() {
                              _isSelling = true;
                              _controller.clear();
                            })
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quantity input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUANTITY',
                    style: GoogleFonts.ibmPlexMono(
                      color: const Color(0xFF8B6914),
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*'),
                      ),
                    ],
                    style: GoogleFonts.ibmPlexMono(
                      color: const Color(0xFFE0D5B8),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: GoogleFonts.ibmPlexMono(
                        color: const Color(0xFF2A2A4A),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      suffix: Text(
                        widget.asset.ticker,
                        style: GoogleFonts.ibmPlexMono(
                          color: const Color(0xFF8B8B9E),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const Divider(color: Color(0xFF2A2A4A)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Summary row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _SummaryRow(
                    label: _isSelling ? 'You receive' : 'Total cost',
                    value:
                        '₡ ${totalCost.toStringAsFixed(2)}',
                    highlight: true,
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Credits available',
                    value: '₡ ${portfolio.credits.toStringAsFixed(2)}',
                  ),
                  if (holding != null) ...[
                    const SizedBox(height: 6),
                    _SummaryRow(
                      label: 'Currently holding',
                      value:
                          '${holding.quantity.toStringAsFixed(4)} ${widget.asset.ticker}',
                    ),
                  ],
                  if (_isSelling && holding != null) ...[
                    const SizedBox(height: 6),
                    _SummaryRow(
                      label: 'After sale',
                      value:
                          '${(holding.quantity - _quantity).clamp(0, double.infinity).toStringAsFixed(4)} ${widget.asset.ticker}',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Confirm button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isValid ? () => _confirm(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSelling
                        ? const Color(0xFFE53935)
                        : const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF2A2A4A),
                    disabledForegroundColor: const Color(0xFF8B8B9E),
                    shape: const RoundedRectangleBorder(),
                    elevation: 0,
                  ),
                  child: Text(
                    _isSelling
                        ? 'CONFIRM SELL'
                        : 'CONFIRM BUY',
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    final notifier = ref.read(playerPortfolioProvider.notifier);
    final success = _isSelling
        ? notifier.sell(widget.asset.ticker, _quantity, widget.asset.price)
        : notifier.buy(widget.asset.ticker, _quantity, widget.asset.price);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            success ? const Color(0xFF1A1A2E) : const Color(0xFF1A1A2E),
        content: Text(
          success
              ? _isSelling
                  ? 'Sold $_quantity ${widget.asset.ticker} — ₡ ${(_quantity * widget.asset.price).toStringAsFixed(2)} received.'
                  : 'Bought $_quantity ${widget.asset.ticker} for ₡ ${(_quantity * widget.asset.price).toStringAsFixed(2)}.'
              : _isSelling
                  ? 'Not enough ${widget.asset.ticker} to sell.'
                  : 'Not enough credits.',
          style: GoogleFonts.ibmPlexMono(
            color: success ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
            fontSize: 12,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? color : const Color(0xFF2A2A4A),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: selected ? color : const Color(0xFF8B8B9E),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF8B8B9E),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            color: highlight
                ? const Color(0xFFE0D5B8)
                : const Color(0xFF8B8B9E),
            fontSize: 13,
            fontWeight:
                highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
