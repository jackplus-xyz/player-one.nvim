mod lua;
mod player;
mod sound;

pub use player::{PlayError, Player};
pub use sound::SoundParams;

#[mlua::lua_module]
fn libplayerone(lua: &mlua::Lua) -> mlua::Result<mlua::Table> {
    lua::create_lua_module(lua)
}

#[cfg(test)]
mod tests;
