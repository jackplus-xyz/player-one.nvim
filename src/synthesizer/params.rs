use mlua::prelude::*;
use serde::{Deserialize, Serialize};
use std::fmt::{self, Display};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SynthParams {
    // Wave
    pub wave_type: u8,
    pub sample_rate: u32,
    pub sample_size: u32,
    // General
    pub volume: f32,
    pub repeat_speed: f32,
    // Envelope
    pub env_attack: f32,  // seconds
    pub env_sustain: f32, // seconds
    pub env_punch: f32,   // percentage (0-1)
    pub env_decay: f32,   // seconds
    // Frequency
    pub freq_base: f32,  // Hz
    pub freq_limit: f32, // Hz
    pub freq_ramp: f32,  // octaves/second
    pub freq_dramp: f32, // octaves/second^2
    // Vibrato
    pub vib_strength: f32, // percentage (0-1)
    pub vib_speed: f32,    // Hz
    // Arpeggiation
    pub arp_mod: f32,   // frequency multiplier
    pub arp_speed: f32, // seconds
    // Duty Cycle
    pub duty: f32,      // percentage (0-1)
    pub duty_ramp: f32, // percentage/second
    // Phaser
    pub pha_offset: f32, // seconds
    pub pha_ramp: f32,   // seconds/second
    // Filters
    pub lpf_freq: f32,      // Hz
    pub lpf_ramp: f32,      // Hz/second
    pub lpf_resonance: f32, // percentage (0-1)
    pub hpf_freq: f32,      // Hz
    pub hpf_ramp: f32,      // Hz/second
}

impl FromLua for SynthParams {
    fn from_lua(lua_value: LuaValue, _: &Lua) -> LuaResult<Self> {
        match lua_value {
            LuaValue::String(s) => SynthParams::from_json(&s.to_str()?)
                .map_err(|e| mlua::Error::external(e.to_string())),
            LuaValue::Table(table) => {
                let mut params = SynthParams::default();

                // Helper function to get value with type conversion
                fn get_value<T: FromLua>(table: &LuaTable, key: &str) -> LuaResult<Option<T>> {
                    if table.contains_key(key)? {
                        table.get(key).map(Some)
                    } else {
                        Ok(None)
                    }
                }

                // Type-safe value assignments with proper conversion
                if let Some(v) = get_value(&table, "wave_type")? {
                    params.wave_type = v;
                }
                if let Some(v) = get_value(&table, "sample_rate")? {
                    params.sample_rate = v;
                }
                if let Some(v) = get_value(&table, "sample_size")? {
                    params.sample_size = v;
                }
                if let Some(v) = get_value::<f32>(&table, "volume")? {
                    params.volume = v;
                }
                if let Some(v) = get_value::<f32>(&table, "repeat_speed")? {
                    params.repeat_speed = v;
                }
                if let Some(v) = get_value::<f32>(&table, "env_attack")? {
                    params.env_attack = v;
                }
                if let Some(v) = get_value::<f32>(&table, "env_sustain")? {
                    params.env_sustain = v;
                }
                if let Some(v) = get_value::<f32>(&table, "env_punch")? {
                    params.env_punch = v;
                }
                if let Some(v) = get_value::<f32>(&table, "env_decay")? {
                    params.env_decay = v;
                }
                if let Some(v) = get_value::<f32>(&table, "freq_base")? {
                    params.freq_base = v;
                }
                if let Some(v) = get_value::<f32>(&table, "freq_limit")? {
                    params.freq_limit = v;
                }
                if let Some(v) = get_value::<f32>(&table, "freq_ramp")? {
                    params.freq_ramp = v;
                }
                if let Some(v) = get_value::<f32>(&table, "freq_dramp")? {
                    params.freq_dramp = v;
                }
                if let Some(v) = get_value::<f32>(&table, "vib_strength")? {
                    params.vib_strength = v;
                }
                if let Some(v) = get_value::<f32>(&table, "vib_speed")? {
                    params.vib_speed = v;
                }
                if let Some(v) = get_value::<f32>(&table, "arp_mod")? {
                    params.arp_mod = v;
                }
                if let Some(v) = get_value::<f32>(&table, "arp_speed")? {
                    params.arp_speed = v;
                }
                if let Some(v) = get_value::<f32>(&table, "duty")? {
                    params.duty = v;
                }
                if let Some(v) = get_value::<f32>(&table, "duty_ramp")? {
                    params.duty_ramp = v;
                }
                if let Some(v) = get_value::<f32>(&table, "pha_offset")? {
                    params.pha_offset = v;
                }
                if let Some(v) = get_value::<f32>(&table, "pha_ramp")? {
                    params.pha_ramp = v;
                }
                if let Some(v) = get_value::<f32>(&table, "lpf_freq")? {
                    params.lpf_freq = v;
                }
                if let Some(v) = get_value::<f32>(&table, "lpf_ramp")? {
                    params.lpf_ramp = v;
                }
                if let Some(v) = get_value::<f32>(&table, "lpf_resonance")? {
                    params.lpf_resonance = v;
                }
                if let Some(v) = get_value::<f32>(&table, "hpf_freq")? {
                    params.hpf_freq = v;
                }
                if let Some(v) = get_value::<f32>(&table, "hpf_ramp")? {
                    params.hpf_ramp = v;
                }

                Ok(params)
            }
            _ => Err(mlua::Error::runtime(
                "Expected string or table for SynthParams",
            )),
        }
    }
}

// Raw JSON format from legacy/external sources
#[derive(Debug, Deserialize)]
pub struct JsonParams {
    pub wave_type: u8,
    pub p_env_attack: f32,
    pub p_env_sustain: f32,
    pub p_env_punch: f32,
    pub p_env_decay: f32,
    pub p_base_freq: f32,
    pub p_freq_limit: f32,
    pub p_freq_ramp: f32,
    pub p_freq_dramp: f32,
    pub p_vib_strength: f32,
    pub p_vib_speed: f32,
    pub p_arp_mod: f32,
    pub p_arp_speed: f32,
    pub p_duty: f32,
    pub p_duty_ramp: f32,
    pub p_repeat_speed: f32,
    pub p_pha_offset: f32,
    pub p_pha_ramp: f32,
    pub p_lpf_freq: f32,
    pub p_lpf_ramp: f32,
    pub p_lpf_resonance: f32,
    pub p_hpf_freq: f32,
    pub p_hpf_ramp: f32,
    pub sound_vol: f32,
    pub sample_rate: u32,
    pub sample_size: u32,
}

#[derive(Debug)]
pub enum ParamsError {
    InvalidJson(String),
    InvalidValue(String),
    ConversionError(String),
}

impl Display for ParamsError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

impl SynthParams {
    pub fn from_json(json: &str) -> Result<Self, ParamsError> {
        let raw: JsonParams =
            serde_json::from_str(json).map_err(|e| ParamsError::InvalidJson(e.to_string()))?;
        Self::from_json_params(raw)
    }

    fn from_json_params(raw: JsonParams) -> Result<Self, ParamsError> {
        // Convert normalized values to real units
        Ok(Self {
            wave_type: raw.wave_type,
            sample_rate: raw.sample_rate,
            sample_size: raw.sample_size,
            volume: raw.sound_vol,
            repeat_speed: raw.p_repeat_speed,
            // Convert to seconds
            env_attack: raw.p_env_attack,
            env_sustain: raw.p_env_sustain,
            env_punch: raw.p_env_punch,
            env_decay: raw.p_env_decay,
            // Convert to Hz
            freq_base: Self::normalized_to_freq(raw.p_base_freq),
            freq_limit: Self::normalized_to_freq(raw.p_freq_limit),
            freq_ramp: raw.p_freq_ramp * 8.0, // Convert to octaves/second
            freq_dramp: raw.p_freq_dramp,
            vib_strength: raw.p_vib_strength,
            vib_speed: raw.p_vib_speed * 10.0, // Convert to Hz
            arp_mod: raw.p_arp_mod,
            arp_speed: raw.p_arp_speed,
            duty: raw.p_duty,
            duty_ramp: raw.p_duty_ramp,
            pha_offset: raw.p_pha_offset,
            pha_ramp: raw.p_pha_ramp,
            lpf_freq: Self::normalized_to_freq(raw.p_lpf_freq),
            lpf_ramp: raw.p_lpf_ramp * 8000.0, // Convert to Hz/second
            lpf_resonance: raw.p_lpf_resonance,
            hpf_freq: Self::normalized_to_freq(raw.p_hpf_freq),
            hpf_ramp: raw.p_hpf_ramp * 8000.0, // Convert to Hz/second
        })
    }

    // Helper function to convert normalized frequency (0-1) to Hz
    fn normalized_to_freq(normalized: f32) -> f32 {
        20.0 * (2.0_f32.powf(10.0 * normalized))
    }
}

impl Default for SynthParams {
    fn default() -> Self {
        Self {
            wave_type: 0, // Square
            sample_rate: 44100,
            sample_size: 8, // 8-bit samples
            volume: 0.25,   // 25% volume to avoid clipping
            repeat_speed: 0.0,
            env_attack: 0.0,
            env_sustain: 0.03, // Short sustain
            env_punch: 0.42,   // Add punch to the sound
            env_decay: 0.35,   // Medium decay
            freq_base: 440.0,  // A4
            freq_limit: 0.0,
            freq_ramp: 0.0,
            freq_dramp: 0.0,
            vib_strength: 0.0,
            vib_speed: 0.0,
            arp_mod: 0.0,
            arp_speed: 0.0,
            duty: 0.0, // 50% duty cycle
            duty_ramp: 0.0,
            pha_offset: 0.0,
            pha_ramp: 0.0,
            lpf_freq: 1.0, // Low pass filter fully open
            lpf_ramp: 0.0,
            lpf_resonance: 0.0,
            hpf_freq: 0.0,
            hpf_ramp: 0.0,
        }
    }
}
