import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/asset.dart';
import '../providers/portfolio_provider.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAssets = ref.watch(portfolioProvider);

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
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4A843)),
            onPressed: () => ref.invalidate(portfolioProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2A2A4A), height: 1),
        ),
      ),
      body: asyncAssets.when(
        // While fetching: show a spinner
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFD4A843)),
              SizedBox(height: 16),
              Text(
                'Tuning into the Cortex...',
                style: TextStyle(color: Color(0xFF8B8B9E)),
              ),
            ],
          ),
        ),
        // On error: show message with retry
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Color(0xFF8B8B9E), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Signal lost.',
                style: TextStyle(color: Color(0xFFD4A843), fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Showing last known data.',
                style: TextStyle(color: Color(0xFF8B8B9E)),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => ref.invalidate(portfolioProvider),
                child: const Text(
                  'Try again',
                  style: TextStyle(color: Color(0xFFD4A843)),
                ),
              ),
            ],
          ),
        ),
        // Data loaded: show the list
        data: (assets) => Column(
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
    final changeColor =
        isUp ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final changePrefix = isUp ? '+' : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          Text(
            asset.name,
            style: const TextStyle(
              color: Color(0xFFE0D5B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          // Small dot: gold = live data, grey = mock data
          Tooltip(
            message: asset.isLive ? 'Live price' : 'Mock data',
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: asset.isLive
                    ? const Color(0xFFD4A843)
                    : const Color(0xFF4A4A5A),
              ),
            ),
          ),
        ],
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
