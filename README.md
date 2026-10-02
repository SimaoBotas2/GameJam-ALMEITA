# Virus

A 2D top-down puzzle game set in a hospital, made with [Godot](https://godotengine.org) for the **2026 Coimbra Game Jam**, organized by the IEEE Student Branch and NEI. You play as SIH and solve puzzles room by room.

The game started as a game jam entry, and the goal now is to finish it as a complete game.

## Features

- Top-down movement and an interaction system (doors, chests, books, paintings, scales, buttons)
- Inventory with a HUD
- Inspection popups for chests and paintings
- Weight puzzle with a scale and books
- Main menu, options, music and sound effects
- Room 1 with randomly drawn paintings that are kept when you leave and come back

## Controls

| Action | Key |
|---|---|
| Move | `W` `A` `S` `D` or the arrow keys |
| Interact | `E` |

## Project Structure

```
virus/                 # Godot project (open project.godot)
├── assets/            # sprites, tilesets, fonts, music and sound effects
├── scenes/            # character, levels and rooms, objects, UI
└── scripts/           # GDScript: character, levels, objects, UI and game_state.gd (autoload)
docs/
├── guides/            # how to create rooms/objects, animations and the random paintings
├── bug-fixes/         # write-ups of bugs that were fixed
└── plot/              # story notes
```

`scenes/levels/level_1`, `level_2` and `level_3` are legacy scenes kept only as reference. Current development continues from `room_1` onwards.

The guides and notes in `docs/` are written in Portuguese.

## Tech Stack

Godot 4 · GDScript

## Getting Started

1. Install [Godot 4](https://godotengine.org/download).
2. Clone the repository:
   ```bash
   git clone https://github.com/SimaoBotas2/GameJam-ALMEITA.git
   ```
3. In Godot, import `virus/project.godot` and press **Play** (`F5`).

## Credits

Hospital tileset: see [`virus/assets/tilesetHospital/license/license.txt`](virus/assets/tilesetHospital/license/license.txt).

## Authors

Simão Carvalho, Martim Fonseca, António Oliveira
