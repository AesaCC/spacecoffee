# Market Realms — Project Document

> A 16-bit ARPG world where the economy is powered by real market data.
> You are a trader-adventurer navigating a fantasy world whose prices, events,
> and factions are driven by real-world stocks and crypto.

---

## Concept

The **investment simulator is the core**. The game world is the wrapper.

Real market data (stocks, crypto, commodities) is mapped to a fictional fantasy
economy. Price movements become in-game events — market crashes become wars,
bull runs become trade booms, volatility becomes chaos in the kingdom.

The player buys, sells, and invests in-game currency in assets that mirror
real-world instruments — without using real money.

---

## Why Flutter

- The primary goal is **learning Flutter the fun way**, not becoming a game developer
- The project team already uses Flutter professionally
- Everything learned here transfers directly to production app work
- Flutter + Flame covers the game layer while staying in the Dart ecosystem

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Dart |
| Framework | Flutter |
| Game engine | Flame (2D, sits on top of Flutter) |
| State management | Riverpod (recommended for this complexity) |
| Market data | Polygon.io or Alpha Vantage (free tier) |
| Local persistence | Isar or Hive |
| Charts / data viz | fl_chart |

---

## Architecture Overview

```
Real Market API  (Polygon.io / Alpha Vantage)
        |
        v
Price Mapping Layer
  - Translates real % changes into fantasy economy events
  - e.g. -5% S&P = "Trade war in the Eastern Kingdom"
        |
        v
Game Economy Engine
  - Asset prices, supply/demand, portfolio state
        |
        v
 ___________________
|                   |
Flame Game World    Investment UI (Flutter widgets)
  - Character       - Portfolio overview
  - Tilemap         - Price charts
  - Towns/Markets   - Buy/sell interface
  - Events/quests   - Asset history
|___________________|
```

---

## Build Stages

### Stage 1 — Market Data + Portfolio UI (pure Flutter, no game yet)
- [ ] `flutter create market_realms`
- [ ] Set up project folder structure (features-first)
- [ ] Connect to free market API
- [ ] Display live prices in a basic UI
- [ ] Simple portfolio buy/sell logic

### Stage 2 — Economy Mapping Layer
- [ ] Define mapping rules (real % change → fantasy event)
- [ ] Fantasy asset types (grain, iron, magic crystals, land)
- [ ] Price history tracking
- [ ] Event generation engine

### Stage 3 — Basic Game World (Flame)
- [ ] Character on a tilemap
- [ ] Town and market locations
- [ ] Basic movement and exploration
- [ ] 16-bit pixel art assets

### Stage 4 — Merge Both Worlds
- [ ] Visit a market town → open investment UI
- [ ] Prices in-game reflect real-world data
- [ ] Economy events appear as in-game news/quests

### Stage 5 — ARPG Layer
- [ ] Combat system
- [ ] Quests tied to economic events
- [ ] Inventory and progression
- [ ] Save/load game state

---

## Workflow

This project uses a **two-tool approach**:

### This Chat (Claude.ai)
Acts as **tech lead / architect**:
- Architecture decisions before coding
- Explaining concepts as they come up
- Reviewing what Claude Code generates
- Unblocking problems
- Maintaining project memory across sessions

### Claude Code (CLI)
Acts as **pair programmer**:
- Generating files and boilerplate
- Editing and iterating on code
- Running commands
- Implementation details

```
You (idea or problem)
        |
        v
This chat  →  architecture decision + instructions for Claude Code
        |
        v
Claude Code  →  generates actual files
        |
        v
This chat  →  explains output, defines next step
```

---

## Key Decisions Log

| Decision | Choice | Reason |
|---|---|---|
| Platform | Flutter | Already used professionally |
| Game engine | Flame | Stays in Flutter/Dart ecosystem |
| Primary focus | Investment sim | Game world is the wrapper |
| Market data | Real data → fictional economy | More interesting than pure fiction |
| State management | Riverpod | Best fit for this complexity level |
| Starting point | Pure Flutter (no Flame) | Learn Flutter basics first |

---

## Resources

- [Flame engine docs](https://flame-engine.org)
- [Polygon.io API](https://polygon.io) — stocks, free tier available
- [Alpha Vantage](https://www.alphavantage.co) — stocks + crypto, free tier
- [Riverpod docs](https://riverpod.dev)
- [fl_chart](https://pub.dev/packages/fl_chart)
- [Isar database](https://isar.dev)

---

*Document generated from project planning session. Update as decisions evolve.*
