import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/asset.dart';
import '../models/price_point.dart';
import '../providers/history_provider.dart';
import '../providers/player_portfolio_provider.dart';
import 'trade_sheet.dart';

class AssetDetailScreen extends ConsumerWidget {
  final Asset asset;
  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(assetHistoryProvider(asset));
    final isUp = asset.changePercent >= 0;
    final changeColor =
        isUp ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final changePrefix = isUp ? '+' : '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Color(0xFFD4A843)),
        title: Text(
          asset.ticker,
          style: const TextStyle(
            color: Color(0xFFD4A843),
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset name + live indicator
            Row(
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    color: Color(0xFFE0D5B8),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: asset.isLive
                        ? const Color(0xFFD4A843).withValues(alpha: 0.15)
                        : const Color(0xFF4A4A5A).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    asset.isLive ? 'LIVE' : 'MOCK',
                    style: TextStyle(
                      color: asset.isLive
                          ? const Color(0xFFD4A843)
                          : const Color(0xFF8B8B9E),
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Price + change
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₡ ${asset.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFE0D5B8),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '$changePrefix${asset.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              asset.realTicker,
              style: const TextStyle(color: Color(0xFF8B8B9E), fontSize: 13),
            ),

            const SizedBox(height: 16),

            // Holding info (if player owns any)
            Builder(builder: (context) {
              final holding = ref
                  .watch(playerPortfolioProvider)
                  .holdings[asset.ticker];
              if (holding == null) return const SizedBox.shrink();
              final pnl = holding.pnl(asset.price);
              final pnlColor = pnl >= 0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE53935);
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  border: Border.all(color: const Color(0xFF2A2A4A)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR HOLDING',
                            style: GoogleFonts.ibmPlexMono(
                                color: const Color(0xFF8B6914),
                                fontSize: 10,
                                letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text(
                          '${holding.quantity.toStringAsFixed(4)} ${asset.ticker}',
                          style: GoogleFonts.ibmPlexMono(
                              color: const Color(0xFFE0D5B8),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('P&L',
                            style: GoogleFonts.ibmPlexMono(
                                color: const Color(0xFF8B6914),
                                fontSize: 10,
                                letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text(
                          '${pnl >= 0 ? '+' : ''}₡ ${pnl.toStringAsFixed(2)}',
                          style: GoogleFonts.ibmPlexMono(
                              color: pnlColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Chart label
            const Text(
              '30-DAY HISTORY',
              style: TextStyle(
                color: Color(0xFF8B6914),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),

            // Chart
            Expanded(
              child: asyncHistory.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4A843),
                  ),
                ),
                error: (error, stack) => const Center(
                  child: Text(
                    'No signal.',
                    style: TextStyle(color: Color(0xFF8B8B9E)),
                  ),
                ),
                data: (points) => _PriceChart(
                  points: points,
                  isUp: isUp,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BUY / SELL buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () =>
                          showTradeSheet(context, asset),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(),
                        elevation: 0,
                      ),
                      child: Text('BUY',
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () =>
                          showTradeSheet(context, asset, startOnSell: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        foregroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              color: Color(0xFFE53935), width: 1),
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 0,
                      ),
                      child: Text('SELL',
                          style: GoogleFonts.ibmPlexMono(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PriceChart extends StatelessWidget {
  final List<PricePoint> points;
  final bool isUp;

  const _PriceChart({required this.points, required this.isUp});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(
        child: Text('No data.', style: TextStyle(color: Color(0xFF8B8B9E))),
      );
    }

    final lineColor =
        isUp ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.price))
        .toList();

    final prices = points.map((p) => p.price).toList();
    final minY = prices.reduce((a, b) => a < b ? a : b);
    final maxY = prices.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: Color(0xFF2A2A4A),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  _formatPrice(value),
                  style: const TextStyle(
                    color: Color(0xFF8B8B9E),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (points.length / 4).floorToDouble(),
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox();
                final date = points[i].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(
                      color: Color(0xFF8B8B9E),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1A1A2E),
            getTooltipItems: (spots) => spots.map((s) {
              final i = s.x.toInt();
              final date = points[i].date;
              return LineTooltipItem(
                '₡ ${s.y.toStringAsFixed(2)}\n${date.month}/${date.day}',
                TextStyle(color: lineColor, fontSize: 12),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: lineColor,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.2),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    if (value >= 1000) return '₡${(value / 1000).toStringAsFixed(1)}k';
    return '₡${value.toStringAsFixed(0)}';
  }
}
