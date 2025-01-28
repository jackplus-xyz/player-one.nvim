use mlua::prelude::*;
use serde::{Deserialize, Serialize};
use std::fmt::{self, Display};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SynthParams {
    // Wave
    pub wave_type: u8, // 0: Square | 1: Sawtooth | 2: Sine | 3: Noise | 4: Triangle
    pub sample_rate: u32, // Hz
    pub sample_size: u32, // Bit
    // General
    pub volume: f32,
    pub repeat_speed: f32, // Hz
    // Envelope
    pub env_attack: f32,  // seconds
    pub env_sustain: f32, // seconds
    pub env_punch: f32,   // +%
    pub env_decay: f32,   // seconds
    // Frequency
    pub freq_base: f32,  // Hz
    pub freq_limit: f32, // Hz
    pub freq_ramp: f32,  // octaves/second
    pub freq_dramp: f32, // octaves/second^2
    // Vibrato
    pub vib_strength: f32, // ±%
    pub vib_speed: f32,    // Hz
    // Arpeggiation
    pub arp_mod: f32,   // multiplier
    pub arp_speed: f32, // seconds
    // Duty Cycle
    pub duty: f32,      // %
    pub duty_ramp: f32, // %/second
    // Phaser
    pub pha_offset: f32, // millisecond
    pub pha_ramp: f32,   // milliseconds/second
    // Filters
    pub lpf_freq: f32,      // Hz
    pub lpf_ramp: f32,      // Hz/second
    pub lpf_resonance: f32, // percentage
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
                fn get_value_from_table<T: FromLua>(
                    table: &LuaTable,
                    key: &str,
                ) -> LuaResult<Option<T>> {
                    if table.contains_key(key)? {
                        table.get(key).map(Some)
                    } else {
                        Ok(None)
                    }
                }

                fn update_param<T: FromLua>(
                    table: &LuaTable,
                    params: &mut SynthParams,
                    key: &str,
                    setter: impl FnOnce(&mut SynthParams, T),
                ) -> LuaResult<()> {
                    if let Some(v) = get_value_from_table::<T>(table, key)? {
                        setter(params, v);
                    }
                    Ok(())
                }

                update_param(&table, &mut params, "wave_type", |p, v| p.wave_type = v)?;
                update_param(&table, &mut params, "sample_rate", |p, v| p.sample_rate = v)?;
                update_param(&table, &mut params, "sample_size", |p, v| p.sample_size = v)?;
                update_param(&table, &mut params, "volume", |p, v| p.volume = v)?;
                update_param(&table, &mut params, "repeat_speed", |p, v| {
                    p.repeat_speed = v
                })?;
                update_param(&table, &mut params, "env_attack", |p, v| p.env_attack = v)?;
                update_param(&table, &mut params, "env_sustain", |p, v| p.env_sustain = v)?;
                update_param(&table, &mut params, "env_punch", |p, v| p.env_punch = v)?;
                update_param(&table, &mut params, "env_decay", |p, v| p.env_decay = v)?;
                update_param(&table, &mut params, "freq_base", |p, v| p.freq_base = v)?;
                update_param(&table, &mut params, "freq_limit", |p, v| p.freq_limit = v)?;
                update_param(&table, &mut params, "freq_ramp", |p, v| p.freq_ramp = v)?;
                update_param(&table, &mut params, "freq_dramp", |p, v| p.freq_dramp = v)?;
                update_param(&table, &mut params, "vib_strength", |p, v| {
                    p.vib_strength = v
                })?;
                update_param(&table, &mut params, "vib_speed", |p, v| p.vib_speed = v)?;
                update_param(&table, &mut params, "arp_mod", |p, v| p.arp_mod = v)?;
                update_param(&table, &mut params, "arp_speed", |p, v| p.arp_speed = v)?;
                update_param(&table, &mut params, "duty", |p, v| p.duty = v)?;
                update_param(&table, &mut params, "duty_ramp", |p, v| p.duty_ramp = v)?;
                update_param(&table, &mut params, "pha_offset", |p, v| p.pha_offset = v)?;
                update_param(&table, &mut params, "pha_ramp", |p, v| p.pha_ramp = v)?;
                update_param(&table, &mut params, "lpf_freq", |p, v| p.lpf_freq = v)?;
                update_param(&table, &mut params, "lpf_ramp", |p, v| p.lpf_ramp = v)?;
                update_param(&table, &mut params, "lpf_resonance", |p, v| {
                    p.lpf_resonance = v
                })?;
                update_param(&table, &mut params, "hpf_freq", |p, v| p.hpf_freq = v)?;
                update_param(&table, &mut params, "hpf_ramp", |p, v| p.hpf_ramp = v)?;

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
    RangeError(String),
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
        Ok(Self {
            wave_type: raw.wave_type,
            sample_rate: raw.sample_rate,
            sample_size: raw.sample_size,
            volume: raw.sound_vol,

            repeat_speed: if raw.p_repeat_speed == 0.0 {
                0.0
            } else {
                ((1.0 - raw.p_repeat_speed).powf(2.0) * 20000.0 + 32.0) / raw.sample_rate as f32
            },

            // Envelope times
            env_attack: raw.p_env_attack * raw.p_env_attack * 100000.0 / raw.sample_rate as f32,
            env_sustain: raw.p_env_sustain * raw.p_env_sustain * 100000.0 / raw.sample_rate as f32,
            env_punch: raw.p_env_punch * 100.0,
            env_decay: raw.p_env_decay * raw.p_env_decay * 100000.0 / raw.sample_rate as f32,

            // Frequency calculations
            freq_base: 8.0 * raw.sample_rate as f32 * (raw.p_base_freq * raw.p_base_freq + 0.001)
                / 100.0,
            freq_limit: 8.0
                * raw.sample_rate as f32
                * (raw.p_freq_limit * raw.p_freq_limit + 0.001)
                / 100.0,
            freq_ramp: (1.0 - raw.p_freq_ramp.powf(3.0) * 0.01) * raw.sample_rate as f32,
            freq_dramp: -raw.p_freq_dramp.powf(3.0) * 0.000001 * raw.sample_rate as f32,

            vib_strength: raw.p_vib_strength * 0.5,
            vib_speed: raw.p_vib_speed.powf(2.0) * 0.01 * raw.sample_rate as f32,

            arp_mod: if raw.p_arp_mod >= 0.0 {
                1.0 / (1.0 - raw.p_arp_mod.powf(2.0) * 0.9)
            } else {
                1.0 / (1.0 + raw.p_arp_mod.powf(2.0) * 10.0)
            },
            arp_speed: if raw.p_arp_speed == 1.0 {
                0.0
            } else {
                ((1.0 - raw.p_arp_speed).powf(2.0) * 20000.0 + 32.0) / raw.sample_rate as f32
            },

            duty: 0.5 - raw.p_duty * 0.5,
            duty_ramp: -raw.p_duty_ramp * 0.00005 * raw.sample_rate as f32,

            pha_offset: if raw.p_pha_offset < 0.0 { -1.0 } else { 1.0 }
                * raw.p_pha_offset.powf(2.0)
                * 1020.0
                / raw.sample_rate as f32,
            pha_ramp: if raw.p_pha_ramp < 0.0 { -1.0 } else { 1.0 }
                * raw.p_pha_ramp.powf(2.0)
                * raw.sample_rate as f32,

            lpf_freq: raw.p_lpf_freq.powf(3.0) * 0.1 * raw.sample_rate as f32,
            lpf_ramp: (1.0 + raw.p_lpf_ramp * 0.0001).powf(raw.sample_rate as f32),
            lpf_resonance: 5.0 / (1.0 + raw.p_lpf_resonance.powf(2.0) * 20.0),

            hpf_freq: raw.p_hpf_freq.powf(2.0) * 0.1 * raw.sample_rate as f32,
            hpf_ramp: (1.0 + raw.p_hpf_ramp * 0.0003).powf(raw.sample_rate as f32),
        })
    }
}

impl Default for SynthParams {
    fn default() -> Self {
        Self {
            wave_type: 0, // Square
            sample_rate: 44100,
            sample_size: 8,
            volume: 0.5,
            repeat_speed: 0.0,
            env_attack: 0.0,
            env_sustain: 0.3, // Short sustain
            env_punch: 0.0,
            env_decay: 0.4,   // Medium decay
            freq_base: 440.0, // A4
            freq_limit: 0.0,
            freq_ramp: 0.0,
            freq_dramp: 0.0,
            vib_strength: 0.0,
            vib_speed: 0.0,
            arp_mod: 0.0,
            arp_speed: 0.0,
            duty: 0.0,
            duty_ramp: 0.0,
            pha_offset: 0.0,
            pha_ramp: 0.0,
            lpf_freq: 1.0, // Low pass filter fully open
            lpf_ramp: 0.0,
            lpf_resonance: 0.0,
            hpf_freq: 0.1,
            hpf_ramp: 0.0,
        }
    }
}
