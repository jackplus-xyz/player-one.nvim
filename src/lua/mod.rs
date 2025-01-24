use crate::playback::Playback;
use crate::synthesizer::SynthParams;
use mlua::prelude::*;
use std::sync::Arc;

pub fn create_lua_module(lua: &Lua) -> LuaResult<LuaTable> {
    let player = Playback::new().map_err(|e| mlua::Error::external(e.to_string()))?;
    let player = Arc::new(player);
    let exports = lua.create_table()?;

    register_play(lua, &exports, player.clone())?;
    register_play_async(lua, &exports, player.clone())?;
    register_stop(lua, &exports, player.clone())?;

    Ok(exports)
}

fn register_play(lua: &Lua, exports: &LuaTable, player: Arc<Playback>) -> LuaResult<()> {
    exports.set(
        "play",
        lua.create_function(move |_, params: SynthParams| {
            player
                .play(params)
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}

fn register_play_async(lua: &Lua, exports: &LuaTable, player: Arc<Playback>) -> LuaResult<()> {
    exports.set(
        "play_async",
        lua.create_function(move |_, params: SynthParams| {
            player
                .play_async(params)
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}

fn register_stop(lua: &Lua, exports: &LuaTable, player: Arc<Playback>) -> LuaResult<()> {
    exports.set(
        "stop",
        lua.create_function(move |_, ()| {
            player
                .stop()
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}
