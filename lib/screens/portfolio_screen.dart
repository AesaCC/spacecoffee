import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset.dart';
import '../providers/portfolio_provider.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'SPACE COFFEE',
          style: TextStyle(
            color: Color(0xFFD4A843),
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2A2A4A), height: 1),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              'GALACTIC MARKETS',
              style: TextStyle(
                color: Color(0xFF8B6914),
                fontSize: 11,
                letterSpacing: 3,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: assets.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFF2A2A4A),
                height: 1,
              ),
              itemBuilder: (context, index) {
                return AssetTile(asset: assets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AssetTile extends StatelessWidget {
  final Asset asset;
  const AssetTile({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final isUp = asset.changePercent >= 0;
    final changeColor = isUp ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final changePrefix = isUp ? '+' : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        asset.name,
        style: const TextStyle(
          color: Color(0xFFE0D5B8),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        asset.ticker,
        style: const TextStyle(
          color: Color(0xFF8B8B9E),
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₡ ${asset.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFFE0D5B8),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          child: Text(
              '$changePrefix${asset.changePercent.toStringAsFixed(2)}%',
              style: TextStyle(
                color: changeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
