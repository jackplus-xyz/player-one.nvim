# player-one.nvim

A Neovim plugin that adds retro gaming charm to your coding experience with 8-bit sound effects on keystrokes.

<img width="1280" alt="banner" src="https://github.com/user-attachments/assets/dae84cd4-a031-43a2-9f42-c3ef494c1af0" />

## Demo

> [!NOTE]
> Make sure you have sounds on!

https://github.com/user-attachments/assets/f72a038f-507c-49cc-9506-37494cbf8ed8

## Overview

`player-one.nvim` is a plugin that generates 8-bit sound effects using sfxr synthesis. It enhances your editing experience with retro-style audio feedback for various Neovim events, without requiring external audio files.

## Features

- Built-in sound themes
- Event-based sound triggers
- Performance focused
- Extensive customization

## Requirements

- [Neovim](https://neovim.io/) >= 0.9.0

### System Support Status

| Operating System | Status | Notes                        |
| ---------------- | ------ | ---------------------------- |
| macOS            | ✅     | Tested on macOS Sequoia 15.2 |
| Linux            | ⚠️     | Not tested                   |
| Windows          | ⚠️     | Not tested                   |

## Quickstart

1. Install with a plugin manager of your choice.

2. Restart NeoVim and you should now hear:

   - A startup melody when Neovim launches
   - Typing sounds in insert mode
   - Save confirmation sounds
   - And more!

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "jackplus-xyz/player-one.nvim",
  ---@type PlayerOne.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
}
```

## Configuration

`player-one.nvim` comes with the following default configuration:

```lua
---@class PlayerOne.Config
{
  ---@type boolean Whether the sound theme is enabled
  is_enabled = true,

  ---@type number Minimum interval between sounds in seconds
  ---Prevents sound overlapping and potential audio flooding when
  ---multiple keystrokes happen in rapid succession
  min_interval = 0.05,

  ---@type PlayerOne.Theme|string Either a preset name or custom sounds table
  ---Available presets: "chiptune", "crystal", "synth"
  theme = "chiptune",
}
```

Example:

```lua
{
  "jackplus-xyz/player-one.nvim",
  opts = {
  is_enabled = false, -- Start with sounds disabled until explicitly enabled
  min_interval = 0.1, -- Increase delay between sounds to 100ms
  theme = "synth",    -- Use the synthesizer sound theme
  }
}
```

For advanced configuration, see [Wiki](https://github.com/jackplus-xyz/player-one.nvim/wiki).

### Theme

The plugin comes with three built-in themes:

- `chiptune`: Classic 8-bit game sounds (default)
- `crystal`: Clear, crystalline sounds with sparkling tones
- `synth`: Modern synthesizer sounds with smooth tones

To create your own theme, see [Theme](https://github.com/jackplus-xyz/player-one.nvim/wiki/Theme).

## Usage

### Commands

| Command                  | Description                           |
| ------------------------ | ------------------------------------- |
| `:PlayerOneEnable`       | Enable sound theme                    |
| `:PlayerOneDisable`      | Disable sound theme                   |
| `:PlayerOneToggle`       | Toggle sound theme                    |
| `:PlayerOneLoad {theme}` | Load a theme (chiptune/crystal/synth) |

## Credits

- [sfxr](https://www.drpetter.se/project_sfxr.html): The original sfxr by DrPetter.
- [jsfxr](https://sfxr.me/): An online 8 bit sound maker and sfx generator.

Libraries used:

- [mlua-rs/mlua](https://github.com/mlua-rs/mlua): High level Lua 5.4/5.3/5.2/5.1 (including LuaJIT) and Roblox Luau bindings to Rust with async/await support.
- [bzar/sfxr-rs](https://github.com/bzar/sfxr-rs): Reimplementation of DrPetter's "sfxr" sound effect generator as a Rust library.

Inspired by:

- [Klack](https://tryklack.com/): A MacOS app that adds mechanical keyboard sounds to every keystroke.
- [EggbertFluffle/beepboop.nvim](https://github.com/EggbertFluffle/beepboop.nvim): A Neovim plugin that incorporate audio cues.
- [jackplus-xyz/love2jump](https://github.com/jackplus-xyz/love2jump): A 2D platformer game built with [LÖVE](https://www.love2d.org/) framework in Lua. This is my personal project to learn the fundamentals of game development. I got the idea of generating 8 bits notes and melody with [love.audio](https://love2d.org/wiki/love.audio), making this game free of audio file.
