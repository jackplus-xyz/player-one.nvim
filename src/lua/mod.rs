use crate::playback::Playback;
use crate::synthesizer::SynthParams;
use mlua::prelude::*;
use std::sync::Arc;

pub fn create_lua_module(lua: &Lua) -> LuaResult<LuaTable> {
    let player = Playback::new().map_err(|e| mlua::Error::external(e.to_string()))?;
    let player = Arc::new(player);
    let exports = lua.create_table()?;

    register_play_sound(lua, &exports, player.clone())?;
    register_stop(lua, &exports, player.clone())?;

    Ok(exports)
}

fn register_play_sound(lua: &Lua, exports: &LuaTable, player: Arc<Playback>) -> LuaResult<()> {
    exports.set(
        "play_sound",
        lua.create_function(move |_, input: LuaValue| {
            let params = match input {
                LuaValue::String(json) => {
                    // Parse JSON input
                    SynthParams::from_json(&json.to_str()?)
                        .map_err(|e| mlua::Error::external(e.to_string()))?
                }
                LuaValue::Table(table) => {
                    // Create SynthParams from Lua table with defaults
                    let mut params = SynthParams::default();

                    // Only set fields that exist in the table
                    if let Ok(wave_type) = table.get("wave_type") {
                        params.wave_type = wave_type;
                    }
                    if let Ok(volume) = table.get("volume") {
                        params.volume = volume;
                    }
                    if let Ok(freq_base) = table.get("freq_base") {
                        params.freq_base = freq_base;
                    }
                    if let Ok(env_attack) = table.get("env_attack") {
                        params.env_attack = env_attack;
                    }
                    if let Ok(env_sustain) = table.get("env_sustain") {
                        params.env_sustain = env_sustain;
                    }
                    if let Ok(env_punch) = table.get("env_punch") {
                        params.env_punch = env_punch;
                    }
                    if let Ok(env_decay) = table.get("env_decay") {
                        params.env_decay = env_decay;
                    }
                    if let Ok(vib_strength) = table.get("vib_strength") {
                        params.vib_strength = vib_strength;
                    }
                    if let Ok(vib_speed) = table.get("vib_speed") {
                        params.vib_speed = vib_speed;
                    }
                    // ... add other fields as needed

                    params
                }
                _ => {
                    return Err(mlua::Error::runtime(
                        "Invalid input format: expected table or JSON string",
                    ))
                }
            };

            player
                .play(params)
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
