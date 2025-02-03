# player-one.nvim

A Neovim plugin that adds retro gaming charm to your coding experience with 8-bit sound effects on keystrokes.

## Features

## Requirements

- [Neovim](https://neovim.io/) >= 0.9.0

### System Support Status

| Operating System | Status | Notes                        |
| ---------------- | ------ | ---------------------------- |
| macOS            | ✅     | Tested on macOS Sequoia 15.2 |
| Linux            | ⚠️     | Not tested                   |
| Windows          | ⚠️     | Not tested                   |

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "jackplus-xyz/player-one.nvim",
    opts = {
        -- Add your configuration here
    }
}
```

## Configuration

`player-one.nvim` comes with the following default configuration:

```lua
{}
```

### Custom Sounds

You can add new sounds by:

1. Creating a table
2. Use a json string generated from [jsfxr - 8 bit sound maker and online sfx generator](https://sfxr.me/).

Note that the json string uses normalized value while the table uses real units.

Here's the units used in the table:

| Parameter     | Unit     | Note                                                   |
| ------------- | -------- | ------------------------------------------------------ |
| wave_type     | int      | 0: Square, 1: Sawtooth, 2: Sine, 3: Noise, 4: Triangle |
| env_attack    | sec      |                                                        |
| env_sustain   | sec      |                                                        |
| env_punch     | +%       |                                                        |
| env_decay     | sec      |                                                        |
| base_freq     | Hz       |                                                        |
| freq_limit    | Hz       |                                                        |
| freq_ramp     | 8va/sec  |                                                        |
| freq_dramp    | 8va/s^2  |                                                        |
| vib_strength  | ± %      |                                                        |
| vib_speed     | Hz       |                                                        |
| p_arp_mod     | mult     |                                                        |
| p_arp_speed   | sec      |                                                        |
| duty          | %        |                                                        |
| duty_ramp     | %/sec    |                                                        |
| repeat_speed  | Hz       |                                                        |
| pha_offset    | msec     |                                                        |
| pha_ramp      | msec/sec |                                                        |
| lpf_freq      | Hz       |                                                        |
| lpf_ramp      | ^sec     |                                                        |
| lpf_resonance | %        |                                                        |
| hpf_freq      | Hz       |                                                        |
| hpf_ramp      | ^sec     |                                                        |

#### Default Value for a sound

When a value is not provided, it will fallback to the default value.

| Json Parameter Name | Default Value | Lua Table Parameter Name | Default Value |
| ------------------- | ------------- | ------------------------ | ------------- |
| wave_type           | 0 (Square)    | wave_type                | 0 (Square)    |
| p_env_attack        | 0.4           | env_attack               | 0.3628        |
| p_env_sustain       | 0.1           | env_sustain              | 0.02268       |
| p_env_punch         | 0.0           | env_punch                | 0.0           |
| p_env_decay         | 0.5           | env_decay                | 0.5669        |
| p_base_freq         | 0.3           | base_freq                | 321.0         |
| p_freq_limit        | 0.0           | freq_limit               | 0.0           |
| p_freq_ramp         | 0.0           | freq_ramp                | 0.0           |
| p_freq_dramp        | 0.0           | freq_dramp               | 0.0           |
| p_vib_strength      | 0.0           | vib_strength             | 0.0           |
| p_vib_speed         | 0.0           | vib_speed                | 0.0           |
| p_arp_mod           | 0.0           | p_arp_mod                | 0.0           |
| p_arp_speed         | 0.0           | p_arp_speed              | 0.0           |
| p_duty              | 0.0           | duty                     | 50.0          |
| p_duty_ramp         | 0.0           | duty_ramp                | 0.0           |
| p_repeat_speed      | 0.0           | repeat_speed             | 0.0           |
| p_pha_offset        | 0.0           | pha_offset               | 0.0           |
| p_pha_ramp          | 0.0           | pha_ramp                 | 0.0           |
| p_lpf_freq          | 1.0           | lpf_freq                 | 0.0           |
| p_lpf_ramp          | 0.0           | lpf_ramp                 | 0.0           |
| p_lpf_resonance     | 0.0           | lpf_resonance            | 45.0          |
| p_hpf_freq          | 0.0           | hpf_freq                 | 0.0           |
| p_hpf_ramp          | 0.0           | hpf_ramp                 | 0.0           |

#### Examples

##### Use a table

```lua
local coin = {
    wave_type = 1,
    env_sustain = 0.001367,
    env_punch = 45.72,
    env_decay = 0.2658,
    base_freq = 1071.0,
    arp_mod = 1.343,
    arp_speed = 0.04447,
    duty = 50.0,
    lpf_ramp = 1.0,
    lpf_resonance = 45.0,
}

require("player-one").play(coin)
```

##### Use a json

```lua
local coin = [[{
        "oldParams": true,
        "wave_type": 1,
        "p_env_attack": 0,
        "p_env_sustain": 0.024555768060600138,
        "p_env_punch": 0.4571553721133509,
        "p_env_decay": 0.3423639066276736,
        "p_base_freq": 0.5500696633190347,
        "p_freq_limit": 0,
        "p_freq_ramp": 0,
        "p_freq_dramp": 0,
        "p_vib_strength": 0,
        "p_vib_speed": 0,
        "p_arp_mod": 0.5329522492796008,
        "p_arp_speed": 0.689393158112304,
        "p_duty": 0,
        "p_duty_ramp": 0,
        "p_repeat_speed": 0,
        "p_pha_offset": 0,
        "p_pha_ramp": 0,
        "p_lpf_freq": 1,
        "p_lpf_ramp": 0,
        "p_lpf_resonance": 0,
        "p_hpf_freq": 0,
        "p_hpf_ramp": 0,
        "sound_vol": 0.25,
        "sample_rate": 44100,
        "sample_size": 8
}]]

require("player-one").play(coin)

```

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
