use crate::playback::{Playback, PlaybackState};
use crate::synthesizer::{SynthParams, WaveType};
use mlua::prelude::*;
use std::sync::Arc;

pub fn create_lua_module(lua: &Lua) -> LuaResult<LuaTable> {
    let player = Playback::new().map_err(|e| mlua::Error::external(e.to_string()))?;
    let player = Arc::new(player);
    let exports = lua.create_table()?;

    register_play_sound(lua, &exports, player.clone())?;
    register_stop(lua, &exports, player.clone())?;
    register_set_volume(lua, &exports, player.clone())?;
    register_get_volume(lua, &exports, player.clone())?;
    register_get_state(lua, &exports, player)?;

    Ok(exports)
}

fn play_sound(player: Arc<Playback>, sound_params: SynthParams) -> LuaResult<()> {
    player
        .play(sound_params)
        .map_err(|e| mlua::Error::external(e.to_string()))
}

fn register_play_sound(lua: &Lua, exports: &LuaTable, player: Arc<Playback>) -> LuaResult<()> {
    exports.set(
        "play_sound",
        lua.create_function(move |_, params: LuaTable| {
            let wave_type = get_wave_type(&params)?;
            let mut sound_params = SynthParams::default();

            if let Some(wave_type) = wave_type {
                sound_params.wave_type = wave_type;
            }

            // Get envelope parameters
            if let Ok(attack) = params.get("p_env_attack") {
                sound_params.envelope.attack = attack;
            }
            if let Ok(sustain) = params.get("p_env_sustain") {
                sound_params.envelope.sustain = sustain;
            }
            if let Ok(punch) = params.get("p_env_punch") {
                sound_params.envelope.punch = punch;
            }
            if let Ok(decay) = params.get("p_env_decay") {
                sound_params.envelope.decay = decay;
            }

            // Get frequency parameters
            if let Ok(base_freq) = params.get("p_base_freq") {
                sound_params.frequency.base = base_freq;
            }
            if let Ok(freq_limit) = params.get("p_freq_limit") {
                sound_params.frequency.limit = freq_limit;
            }
            if let Ok(freq_ramp) = params.get("p_freq_ramp") {
                sound_params.frequency.ramp = freq_ramp;
            }
            if let Ok(freq_dramp) = params.get("p_freq_dramp") {
                sound_params.frequency.dramp = freq_dramp;
            }

            // Get duty cycle parameters
            if let Ok(duty) = params.get("p_duty") {
                sound_params.duty_cycle.duty = duty;
            }
            if let Ok(duty_ramp) = params.get("p_duty_ramp") {
                sound_params.duty_cycle.ramp = duty_ramp;
            }

            // Get vibrato parameters
            if let Ok(vib_strength) = params.get("p_vib_strength") {
                sound_params.vibrato.strength = vib_strength;
            }
            if let Ok(vib_speed) = params.get("p_vib_speed") {
                sound_params.vibrato.speed = vib_speed;
            }

            // Get arpeggiation parameters
            if let Ok(arp_mod) = params.get("p_arp_mod") {
                sound_params.arpeggiation.mult = arp_mod;
            }
            if let Ok(arp_speed) = params.get("p_arp_speed") {
                sound_params.arpeggiation.speed = arp_speed;
            }

            // Get phaser parameters
            if let Ok(pha_offset) = params.get("p_pha_offset") {
                sound_params.phaser.offset = pha_offset;
            }
            if let Ok(pha_ramp) = params.get("p_pha_ramp") {
                sound_params.phaser.ramp = pha_ramp;
            }

            // Get filter parameters
            if let Ok(lpf_freq) = params.get("p_lpf_freq") {
                sound_params.filter.lpf_freq = lpf_freq;
            }
            if let Ok(lpf_ramp) = params.get("p_lpf_ramp") {
                sound_params.filter.lpf_ramp = lpf_ramp;
            }
            if let Ok(lpf_resonance) = params.get("p_lpf_resonance") {
                sound_params.filter.lpf_resonance = lpf_resonance;
            }
            if let Ok(hpf_freq) = params.get("p_hpf_freq") {
                sound_params.filter.hpf_freq = hpf_freq;
            }
            if let Ok(hpf_ramp) = params.get("p_hpf_ramp") {
                sound_params.filter.hpf_ramp = hpf_ramp;
            }

            // Get general parameters
            if let Ok(volume) = params.get("p_volume") {
                sound_params.general.volume = volume;
            }
            if let Ok(repeat_speed) = params.get("p_repeat_speed") {
                sound_params.general.repeat_speed = repeat_speed;
            }

            play_sound(player.clone(), sound_params)
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

fn register_set_volume(lua: &Lua, exports: &LuaTable, player: Arc<Playback>) -> LuaResult<()> {
    exports.set(
        "set_volume",
        lua.create_function(move |_, volume: f32| {
            player
                .set_volume(volume)
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}

fn register_get_volume(lua: &Lua, exports: &LuaTable, player: Arc<Playback>) -> LuaResult<()> {
    exports.set(
        "get_volume",
        lua.create_function(move |_, ()| {
            player
                .get_volume()
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}

fn register_get_state(lua: &Lua, exports: &LuaTable, player: Arc<Playback>) -> LuaResult<()> {
    exports.set(
        "get_state",
        lua.create_function(move |_, ()| {
            player
                .get_state()
                .map(|state| match state {
                    PlaybackState::Playing => "playing".to_string(),
                    PlaybackState::Stopped => "stopped".to_string(),
                    PlaybackState::Paused => "paused".to_string(),
                    PlaybackState::Error(msg) => msg,
                })
                .map_err(|e| mlua::Error::external(e.to_string()))
        })?,
    )
}

fn get_wave_type(params: &LuaTable) -> LuaResult<Option<WaveType>> {
    if params.contains_key("wave_type")? {
        let wave_type: i32 = params.get("wave_type")?;
        Ok(Some(parse_wave_type(wave_type)?))
    } else {
        Ok(None)
    }
}

fn parse_wave_type(wave_type: i32) -> LuaResult<WaveType> {
    Ok(match wave_type {
        0 => WaveType::Sine,
        1 => WaveType::Square,
        2 => WaveType::Sawtooth,
        3 => WaveType::Triangle,
        4 => WaveType::Noise,
        invalid => {
            return Err(mlua::Error::external(format!(
                "Invalid wave type: {}",
                invalid
            )))
        }
    })
}
