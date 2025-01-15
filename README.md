# player-one.nvim

A Neovim plugin that adds retro gaming charm to your coding experience with 8-bit sound effects on keystrokes.

## Features

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

## How it works

## Tips

### Color Scheme

Use a color scheme with [base16](https://github.com/chriskempson/base16) colors for the extra retro touch:

- [RRethy/base16-nvim](https://github.com/RRethy/base16-nvim): Neovim plugin for building a sync base16 colorscheme. Includes support for Treesitter and LSP highlight groups.

> [!TIP]
> My favorite is `base16-default-dark`.

Or a color scheme with vibrant colors on dark background:
  - [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim?tab=readme-ov-file): 🏙 A clean, dark Neovim theme written in Lua, with support for lsp, treesitter and lots of plugins. Includes additional themes for Kitty, Alacritty, iTerm and Fish.
  > [!TIP]
  > Try to setting `transparent` to true and use a dark terminal background.

### Terminal Emulator

Level up the immersive experience with a terminal emulator that supports custom shaders, such as:

- [Ghostty](https://ghostty.org/): supports [customGLSL shader](https://ghostty.org/docs/config/reference#custom-shader)
- [Rio](https://raphamorim.io/rio/): supports [RetroArch shaders](https://raphamorim.io/rio/docs/features/retroarch-shaders/)

## Credits

Inspirations for this project:

- [Klack](https://tryklack.com/): A MacOS app that adds mechanical keyboard sounds to every keystroke.
- [EggbertFluffle/beepboop.nvim](https://github.com/EggbertFluffle/beepboop.nvim): A Neovim plugin that incorporate audio cues.
- [jackplus-xyz/love2jump](https://github.com/jackplus-xyz/love2jump): A 2D platformer game built with [LÖVE](https://www.love2d.org/) framework in Lua. This is my personal project to learn the fundamentals of game development. I got the idea of generating 8 bits notes and melody with [love.audio](https://love2d.org/wiki/love.audio), making this game free of audio file.
