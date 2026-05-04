# hvim config

Personal Neovim config for [hvim](https://github.com/hooreique/hvim).

This config is meant to be used with the `hvim` wrapper, not plain `nvim`.

## NVIM_APPNAME

`hvim` runs Neovim with:

```sh
NVIM_APPNAME=hvim
````

So this repository should be cloned to:

```text
~/.config/hvim
```

and uses separate Neovim data/state/cache paths from normal `nvim`.

## pack.lua

Plugin setup is handled from:

```text
lua/config/pack.lua
```

## .luarc.json

`.luarc.json` is generated automatically when opening this repository with `hvim`.

Generation logic lives in:

```text
lua/config/hvim-config-luarc.lua
```

It calls:

```sh
hvim-luarc
```

then extends the LuaLS `workspace.library` with runtime Lua paths visible to this config.

`.luarc.json` is ignored by git because it depends on the current wrapped Neovim/Nix environment.
