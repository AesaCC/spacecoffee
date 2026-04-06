import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // Background — ambient amber glow mimicking cockpit instrument light.
          // TODO: Replace with cockpit image asset once sourced.
          _Background(),
          // Dark gradient overlay — keeps text readable over the background.
          _Overlay(),
          // All foreground content
          SafeArea(
            child: Column(
              children: [
                _TopBar(),
                const Spacer(),
                _CenterContent(),
                const Spacer(),
                _BottomSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background ──────────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        'assets/images/splash_bg.jpeg',
        fit: BoxFit.cover,
      ),
    );
  }
}

// ─── Overlay ─────────────────────────────────────────────────────────────────

class _Overlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D0D1A),
            const Color(0xFF0D0D1A).withValues(alpha: 0.75),
            const Color(0xFF0D0D1A).withValues(alpha: 0.75),
            const Color(0xFF0D0D1A),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

// ─── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          'v0.1  ·  EARLY ACCESS',
          style: GoogleFonts.ibmPlexMono(
            color: const Color(0xFF8B6914),
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          color: const Color(0x33D4A843),
        ),
      ],
    );
  }
}

// ─── Center content ───────────────────────────────────────────────────────────

class _CenterContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Square icon frame — hard edge, no soft glow
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF8B6914),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.coffee,
            size: 40,
            color: Color(0xFFD4A843),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'SPACE COFFEE',
          style: GoogleFonts.ibmPlexMono(
            color: const Color(0xFFD4A843),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Coffee.  Credits.  Chaos.',
          style: GoogleFonts.ibmPlexMono(
            color: const Color(0xFF8B8B9E),
            fontSize: 13,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

// ─── Bottom section ───────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          color: const Color(0xFF2A2A4A),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A843),
                foregroundColor: const Color(0xFF0D0D1A),
                elevation: 0,
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(
                "ENTER THE 'VERSE",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'No real money. All real stakes.',
          style: GoogleFonts.ibmPlexMono(
            color: const Color(0xFF8B8B9E),
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}
