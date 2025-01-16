use mlua::prelude::*;
use rodio::{source::Source, OutputStream, Sink};
use std::sync::Arc;
use std::sync::Mutex;
use std::time::Duration;

struct AudioPlayer {
    sink: Arc<Mutex<Option<Sink>>>,
    _stream: OutputStream,
}

unsafe impl Send for AudioPlayer {}
unsafe impl Sync for AudioPlayer {}

impl AudioPlayer {
    fn new() -> Result<Self, Box<dyn std::error::Error>> {
        let (stream, stream_handle) = OutputStream::try_default()?;
        let sink = Sink::try_new(&stream_handle)?;
        Ok(AudioPlayer {
            sink: Arc::new(Mutex::new(Some(sink))),
            _stream: stream,
        })
    }

    fn play_tone(
        &self,
        frequency: f32,
        duration_ms: u64,
        amplitude: f32,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let sink = self.sink.lock().unwrap();
        if let Some(sink) = &*sink {
            let source = rodio::source::SineWave::new(frequency)
                .take_duration(Duration::from_millis(duration_ms))
                .amplify(amplitude);
            sink.append(source);
            sink.sleep_until_end();
        }
        Ok(())
    }
}

// Lua module registration
#[mlua::lua_module]
fn nvim_sound(lua: &Lua) -> LuaResult<LuaTable> {
    let player = AudioPlayer::new().map_err(|e| mlua::Error::external(e.to_string()))?;
    let player = Arc::new(player);

    // Create module table
    let exports = lua.create_table()?;

    // Add custom tone function
    let player_clone = player.clone();
    exports.set(
        "play_tone",
        lua.create_function(move |_, (freq, duration, amplitude): (f32, u64, f32)| {
            player_clone
                .play_tone(freq, duration, amplitude)
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )?;

    Ok(exports)
}
