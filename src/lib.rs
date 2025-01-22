mod lua;
mod playback;
mod synthesizer;

pub use playback::{error::PlaybackError, Playback};
pub use synthesizer::SynthParams;

#[mlua::lua_module]
fn libplayerone(lua: &mlua::Lua) -> mlua::Result<mlua::Table> {
    lua::create_lua_module(lua)
}

#[cfg(test)]
mod tests;
