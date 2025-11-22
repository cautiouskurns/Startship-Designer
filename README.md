# Starship Designer

A Godot 4.5 puzzle-combat game prototype testing the "design ship → auto-battle → iterate" gameplay loop.

## Overview

You're the chief starship designer for Starfleet Command during wartime - design ships on a grid, launch them into auto-battle, and iterate on failures until your designs win the war.

## Core Features

- **Grid-Based Ship Design**: Place rooms on an 8×6 tile grid with a 30-point budget
- **6 Room Types**: Bridge, Weapons, Shields, Engines, Reactors, and Armor
- **Power Routing System**: Reactors power adjacent rooms - unpowered rooms are inactive
- **Auto-Resolved Combat**: Watch ships fight turn-based battles with transparent math
- **3 Missions**: Progressive difficulty with unique enemy ship designs

## Design Pillars

1. **Engineering Fantasy Over Piloting** - Success from smart layout decisions, not twitch skills
2. **Meaningful Spatial Puzzles** - Room placement matters (weapons forward, engines back)
3. **Clear Feedback Through Simplicity** - Transparent combat, immediate iteration

## Development

**Engine:** Godot 4.5
**Scope:** Weekend prototype (12-16 hours)
**Status:** Phase 1 - Visual Layout (Grid Rendering Complete)

## Documentation

- [Full Design Document](docs/STARSHIP%20DESIGNER%20-%20Prototype%20Design%20D.md)
- [Development Roadmap](docs/DEVELOPMENT_ROADMAP.md)
- [Claude.md](CLAUDE.md) - AI assistant context

## Running the Project

1. Open in Godot 4.5+
2. Run `res://scenes/main/Main.tscn`

## License

This is a prototype project for testing game mechanics.
