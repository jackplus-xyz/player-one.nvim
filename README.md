# player-one.nvim

A Neovim plugin that adds retro gaming charm to your coding experience with 8-bit sound effects on keystrokes.

<img width="1280" alt="banner" src="https://github.com/user-attachments/assets/dae84cd4-a031-43a2-9f42-c3ef494c1af0" />

## Demo

## Overview

`player-one.nvim` brings audio feedback to your editing experience by playing retro-style sound effects on Neovim events. Built with sfxr sound synthesis, it generates 8-bit sounds without on the fly without any audio files.

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

1. Install with your favorite package manager:

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
  min_interval = 0.05,

  ---@type PlayerOne.Theme|string Either a preset name or custom sounds table
  theme = "chiptune",
}
```

### Theme

A Theme is a collection of sounds. Just like how colorschemes map colors to text objects, themes map sound effects to Neovim events.

The plugin comes with three built-in themes:

- `chiptune`: Classic 8-bit game sounds (default)
- `crystal`: Clear, crystalline sounds with sparkling tones
- `synth`: Modern synthesizer sounds with smooth tones

When an event occurs (like saving a file or moving the cursor), the theme plays its corresponding sound effect.

And of course, you can create your own theme to customize exactly how your editor sounds.

#### Creating a Theme

```lua
---@type PlayerOne.Theme
local my_theme = {
  -- Play a welcome jingle when Vim startup
  ---@type PlayerOne.Sound
  {
    event = "VimEnter",
    sound = {
      { wave_type = 1, base_freq = 523.25, env_decay = 0.15 },
      { wave_type = 1, base_freq = 659.25, env_decay = 0.15 },
      { wave_type = 1, base_freq = 783.99, env_decay = 0.15 },
    },
    callback = "append" -- Play notes sequentially
  },

  -- Trigger a Short blip while typing
  {
    event = "TextChangedI",
    sound = {
      wave_type = 1,
      base_freq = 880.0,
      env_attack = 0.0,
      env_sustain = 0.001,
      env_decay = 0.05,
    },
    callback = "play"   -- Play immediately
  },

  -- Play a goodbye chime when exiting Vim
  {
    event = "VimLeavePre",
    sound = {
      { wave_type = 2, base_freq = 587.33, env_decay = 0.15 },
      { wave_type = 2, base_freq = 880.00, env_decay = 0.15 },
    },
    callback = "play_async" -- Play and wait for completion
  }
}

-- Apply the theme
require("player-one").setup({
  theme = my_theme
})

-- Or switch themes at runtime
require("player-one").load_theme(my_theme)

```

### Sound

A sound is consist of `event`, `sound` and `callback`

```lua
---@class PlayerOne.Sound
{
  ---@type string Event name that triggers the sound (see `:h events`)
  event = "",

  ---@type PlayerOne.SoundParams|PlayerOne.SoundParams[] Sound parameters
  sound = {},

  ---@type string|function Callback to execute when sound plays
  ---@default "play"
  callback = "play",
}
```

You can create sounds in two ways:

1. Using a Lua table with real units
2. Using a JSON string from [jsfxr](https://sfxr.me/)

#### Using Lua Table

```lua
local coin = {
    wave_type = 1,        -- Sawtooth wave
    env_sustain = 0.001,  -- 1ms sustain
    env_punch = 45.72,    -- 45.72% punch
    env_decay = 0.26,     -- 260ms decay
    base_freq = 1071.0,   -- 1071Hz (approximately C6)
    arp_mod = 1.343,      -- Frequency multiplier for arpeggio
    arp_speed = 0.044,    -- Arpeggio speed in seconds
    duty = 50.0,          -- Square wave duty cycle
    lpf_ramp = 1.0,       -- Linear increase in filter cutoff
    lpf_resonance = 45.0, -- Filter resonance percentage
}

require("player-one").play(coin)
```

#### Using JSON

```lua
local coin = [[{
    "oldParams": true,
    "wave_type": 1,
    "p_env_attack": 0,
    "p_env_sustain": 0.024,
    "p_env_punch": 0.457,
    "p_env_decay": 0.342,
    "p_base_freq": 0.550,
    "p_arp_mod": 0.532,
    "p_arp_speed": 0.689,
    "sound_vol": 0.25
}]]

require("player-one").play(coin)
```

#### Sound Parameters

> [!NOTE]
>
> 1. The `json` params has a prefix of `p_`
> 2. The table uses real units while json uses normalized values (0.0-1.0)

| Parameter     | Unit     | Description                                            | Default |
| ------------- | -------- | ------------------------------------------------------ | ------- |
| wave_type     | int      | 0: Square, 1: Sawtooth, 2: Sine, 3: Noise, 4: Triangle | 0       |
| env_attack    | sec      | Time to reach peak volume                              | 0.3628  |
| env_sustain   | sec      | Time to hold peak volume                               | 0.0227  |
| env_punch     | +%       | Additional volume boost at the start                   | 0.0     |
| env_decay     | sec      | Time to fade to silence                                | 0.5669  |
| base_freq     | Hz       | Base frequency of the sound                            | 321.0   |
| freq_limit    | Hz       | Minimum frequency during slides                        | 0.0     |
| freq_ramp     | 8va/sec  | Frequency change over time (octaves per second)        | 0.0     |
| freq_dramp    | 8va/s^2  | Change in frequency slide (octaves per second^2)       | 0.0     |
| vib_strength  | ± %      | Vibrato depth                                          | 0.0     |
| vib_speed     | Hz       | Vibrato frequency                                      | 0.0     |
| arp_mod       | mult     | Frequency multiplier for arpeggio                      | 0.0     |
| arp_speed     | sec      | Time between arpeggio notes                            | 0.0     |
| duty          | %        | Square wave duty cycle (wave_type = 0 only)            | 50.0    |
| duty_ramp     | %/sec    | Change in duty cycle over time                         | 0.0     |
| repeat_speed  | Hz       | Sound repeat frequency                                 | 0.0     |
| pha_offset    | msec     | Phaser offset                                          | 0.0     |
| pha_ramp      | msec/sec | Change in phaser offset over time                      | 0.0     |
| lpf_freq      | Hz       | Low-pass filter cutoff frequency                       | 0.0     |
| lpf_ramp      | ^sec     | Change in filter cutoff over time                      | 0.0     |
| lpf_resonance | %        | Filter resonance                                       | 45.0    |
| hpf_freq      | Hz       | High-pass filter cutoff frequency                      | 0.0     |
| hpf_ramp      | ^sec     | Change in high-pass filter cutoff over time            | 0.0     |

#### Callbacks

`player-one.nvim` provides three different ways to play sounds, each suited for different use cases.

##### Play Modes Overview

```lua
local PlayerOne = require("player-one")

-- Play immediately
PlayerOne.play(sound)

-- Queue sound
PlayerOne.append(sound)

-- Play and wait
PlayerOne.play_async(sound)
```

##### `play(sound)`

Plays the sound immediately, interrupting any currently playing sounds. Best for immediate feedback.

```lua
-- Simple beep when typing
{
  event = "TextChangedI",
  sound = {
    wave_type = 1,
    base_freq = 440.0,
    env_decay = 0.05,
  },
  callback = "play"  -- Immediate feedback
}
```

```lua
-- Play a C major chord (C4, E4, G4)
{
  event = "InsertEnter",
  sound = {
    -- C4 (261.63 Hz)
    {
      wave_type = 1,
      base_freq = 261.63,
      env_decay = 0.1,
    },
    -- E4 (329.63 Hz)
    {
      wave_type = 1,
      base_freq = 329.63,
      env_decay = 0.1,
    },
    -- G4 (392.00 Hz)
    {
      wave_type = 1,
      base_freq = 392.00,
      env_decay = 0.1,
    }
  },
  callback = "play"  -- All notes play simultaneously
}
```

##### `append(sound)`

Queues sounds to play sequentially. Perfect for creating melodies or sequences.

```lua
-- Startup melody with multiple notes
{
  event = "VimEnter",
  sound = {
    { wave_type = 1, base_freq = 523.25 },
    { wave_type = 1, base_freq = 659.25 },
    { wave_type = 1, base_freq = 783.99 },
  },
  callback = "append"  -- Notes play in sequence
}
```

##### `play_async(sound)`

Plays the sound and waits for it to complete before continuing. Useful for confirmations or alerts.

```lua
-- Save confirmation with chord
{
  event = "BufWritePost",
  sound = {
    { wave_type = 1, base_freq = 587.33 },
    { wave_type = 1, base_freq = 880.00 },
  },
  callback = "play_async"  -- Wait for completion
}
```

##### Comparison

| Mode         | Interrupts Current | Queues Sounds | Blocks Execution |
| ------------ | ------------------ | ------------- | ---------------- |
| `play`       | ✅                 | ❌            | ❌               |
| `append`     | ❌                 | ✅            | ❌               |
| `play_async` | ✅                 | ✅            | ✅               |

##### Use Cases

- Use `play` for:

  - Immediate feedback (typing, cursor movement)
  - Single sound effects
  - Overriding current sounds

- Use `append` for:

  - Musical sequences
  - Multi-note melodies
  - Sound effect combinations

- Use `play_async` for:
  - Confirmation sounds
  - Operation completion alerts
  - Synchronized audio feedback

##### Example

```lua
local theme = {
  -- Immediate feedback for typing
  {
    event = "TextChangedI",
    sound = { wave_type = 1, base_freq = 440.0 },
    callback = "play"
  },

  -- Musical sequence for startup
  {
    event = "VimEnter",
    sound = {
      { wave_type = 1, base_freq = 523.25 },
      { wave_type = 1, base_freq = 659.25 },
      { wave_type = 1, base_freq = 783.99 },
    },
    callback = "append"
  },

  -- Confirmation for save
  {
    event = "BufWritePost",
    sound = {
      { wave_type = 1, base_freq = 587.33 },
      { wave_type = 1, base_freq = 880.00 },
    },
    callback = "play_async"
  }
}
```

##### Custom Callbacks

In addition to the built-in callbacks (`"play"`, `"append"`, `"play_async"`), you can define custom callback functions for more complex sound behaviors.

```lua
local player_one = require("player-one")
local utils = require("player-one.utils")

---@type PlayerOne.Theme
local theme = {
  -- Example 1: Conditional Sound Based on Buffer Type
  {
    event = "BufWritePost",
    sound = {
      { wave_type = 1, base_freq = 587.33, env_decay = 0.15 }, -- D5
      { wave_type = 1, base_freq = 880.00, env_decay = 0.15 }, -- A5
    },
    callback = function(sound)
      -- Play different sounds for different file types
      local ft = vim.bo.filetype
      if ft == "lua" then
        utils.append(sound)
      elseif ft == "rust" then
        utils.play_async(sound)
      else
        utils.play(sound)
      end
    end
  },

  -- Example 2: Dynamic Sound Parameters
  {
    event = "CursorMoved",
    sound = {
      wave_type = 1,
      base_freq = 440.0,
      env_decay = 0.05,
    },
    callback = function(sound)
      -- Modify frequency based on cursor position
      local pos = vim.api.nvim_win_get_cursor(0)
      local line = pos[1]
      local col = pos[2]

      -- Adjust frequency based on position
      sound.base_freq = 440.0 + (line % 12) * 50

      -- Only play if enabled and after delay
      if vim.g.player_one ~= false then
        utils.play(sound)
      end
    end
  },

  -- Example 3: Sequential Sounds with Delay
  {
    event = "VimEnter",
    sound = {
      { wave_type = 1, base_freq = 523.25, env_decay = 0.15 }, -- C5
      { wave_type = 1, base_freq = 659.25, env_decay = 0.15 }, -- E5
      { wave_type = 1, base_freq = 783.99, env_decay = 0.15 }, -- G5
    },
    callback = function(sound)
      -- Play startup sound after a delay
      vim.defer_fn(function()
        utils.append(sound)
      end, 1000) -- 1 second delay
    end
  },

  -- Example 4: Volume Based on Window Size
  {
    event = "VimResized",
    sound = {
      wave_type = 2,
      base_freq = 440.0,
      env_decay = 0.1,
    },
    callback = function(sound)
      -- Adjust volume based on window width
      local width = vim.api.nvim_win_get_width(0)
      sound.sound_vol = math.min(width / 100, 1.0)
      utils.play(sound)
    end
  }
}

-- Apply the theme
player_one.setup({
  theme = theme
})
```

Custom callbacks give you full control over:

- When and how sounds are played
- Sound parameter modifications
- Conditional playback logic
- Integration with Neovim state
- Complex sound sequences
- Timing and delays

Tips for Custom Callbacks:

1. Use `utils.play()`, `utils.append()`, or `utils.play_async()` for sound playback
2. Check `vim.g.player_one` for global enable state
3. Modify sound parameters before playback
4. Use `vim.defer_fn()` for delayed playback
5. Access Neovim API for context-aware sounds

## Usage

### Commands

| Command                  | Description                           |
| ------------------------ | ------------------------------------- |
| `:PlayerOneEnable`       | Enable sound theme                    |
| `:PlayerOneDisable`      | Disable sound theme                   |
| `:PlayerOneToggle`       | Toggle sound theme                    |
| `:PlayerOneLoad {theme}` | Load a theme (chiptune/crystal/synth) |

## How it works

## Tips

### Use Terminal Emulator with Custom Shaders

Level up the immersive experience with a terminal emulator that supports custom shaders, such as:

- [Ghostty](https://ghostty.org/): supports [customGLSL shader](https://ghostty.org/docs/config/reference#custom-shader)
- [Rio](https://raphamorim.io/rio/): supports [RetroArch shaders](https://raphamorim.io/rio/docs/features/retroarch-shaders/)

### Dark Color Scheme that matches the 8-bit theme

Use a color scheme with [base16](https://github.com/chriskempson/base16) colors for the extra retro touch:

- [RRethy/base16-nvim](https://github.com/RRethy/base16-nvim): Neovim plugin for building a sync base16 colorscheme. Includes support for Treesitter and LSP highlight groups.

  > [!TIP]
  > My favorite is `base16-default-dark`.

Or a color scheme with vibrant colors on dark background:

- [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim?tab=readme-ov-file): 🏙 A clean, dark Neovim theme written in Lua, with support for lsp, treesitter and lots of plugins. Includes additional themes for Kitty, Alacritty, iTerm and Fish.
  > [!TIP]
  > Try to setting `transparent` to true and use a dark terminal background.

### Font with Retro Look

Try to use a font that looks like it's from the past.

### Play soundtracks from games you love

This may improve your productity or may make you shed tears of nostalgia. Some awesome soundtracks to try:

- Little Root Town from Pokemon Ruby/Sapphire/Emerald
- Running Through the Cyber World from Mega Man Battle Network
- Main Theme from The Legend of Zelda

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
