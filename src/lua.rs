use crate::player::Player;
use crate::sound::SoundParams;
use mlua::prelude::*;
use std::fs::OpenOptions;
use std::io::Write;
use std::sync::Arc;

unsafe impl Send for Player {}
unsafe impl Sync for Player {}

pub fn create_lua_module(lua: &Lua) -> LuaResult<LuaTable> {
    let player = Player::new().map_err(|e| mlua::Error::external(e.to_string()))?;
    let player = Arc::new(player);
    let exports = lua.create_table()?;

    // Debug Logging
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open("lua_module.log")
        .unwrap();

    writeln!(
        file,
        "Creating Lua module at: {:?}",
        std::time::SystemTime::now()
    )
    .unwrap();

    register_play(lua, &exports, player.clone())?;
    register_play_async(lua, &exports, player.clone())?;
    register_play_preset(lua, &exports, player.clone())?;
    register_stop(lua, &exports, player)?;

    Ok(exports)
}

fn register_play(lua: &Lua, exports: &LuaTable, player: Arc<Player>) -> LuaResult<()> {
    exports.set(
        "play",
        lua.create_function(move |_, params: SoundParams| {
            player
                .play(params)
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}

fn register_play_async(lua: &Lua, exports: &LuaTable, player: Arc<Player>) -> LuaResult<()> {
    exports.set(
        "play_async",
        lua.create_function(move |_, params: SoundParams| {
            player
                .play_async(params)
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}

fn register_play_preset(lua: &Lua, exports: &LuaTable, player: Arc<Player>) -> LuaResult<()> {
    exports.set(
        "play_preset",
        lua.create_function(move |_, preset_name: String| {
            let sample = match preset_name.as_str() {
                "pickup" => sfxr::Sample::pickup(None),
                "laser" => sfxr::Sample::laser(None),
                "explosion" => sfxr::Sample::explosion(None),
                "powerup" => sfxr::Sample::powerup(None),
                "hit" => sfxr::Sample::hit(None),
                "jump" => sfxr::Sample::jump(None),
                "blip" => sfxr::Sample::blip(None),
                _ => {
                    return Err(mlua::Error::external(format!(
                        "Unknown preset: {}",
                        preset_name
                    )))
                }
            };

            player
                .play(SoundParams::new(sample))
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}

fn register_stop(lua: &Lua, exports: &LuaTable, player: Arc<Player>) -> LuaResult<()> {
    exports.set(
        "stop",
        lua.create_function(move |_, ()| {
            player
                .stop()
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}
