use mlua::prelude::*;
use serde::{Deserialize, Serialize};
use sfxr::{Generator, Sample, WaveType};
use std::sync::Arc;

#[derive(Serialize, Deserialize)]
struct JsonParams {
    wave_type: u8,
    p_env_attack: f32,
    p_env_sustain: f32,
    p_env_decay: f32,
    p_env_punch: f32,
    p_base_freq: f64,
    p_freq_limit: f64,
    p_freq_ramp: f64,
    p_freq_dramp: f64,
    p_vib_strength: f64,
    p_vib_speed: f64,
    p_arp_speed: f32,
    p_arp_mod: f64,
    p_duty: f32,
    p_duty_ramp: f32,
    p_repeat_speed: f32,
    p_pha_offset: f32,
    p_pha_ramp: f32,
    p_lpf_freq: f32,
    p_lpf_ramp: f32,
    p_lpf_resonance: f32,
    p_hpf_freq: f32,
    p_hpf_ramp: f32,
}

#[derive(Serialize, Deserialize, Debug)]
struct SoundConfig {
    wave_type: Option<i64>,
    base_freq: Option<f64>,
    freq_limit: Option<f64>,
    freq_ramp: Option<f64>,
    freq_dramp: Option<f64>,
    duty: Option<f64>,
    duty_ramp: Option<f64>,
    vib_strength: Option<f64>,
    vib_speed: Option<f64>,
    vib_delay: Option<f64>,
    env_attack: Option<f64>,
    env_sustain: Option<f64>,
    env_decay: Option<f64>,
    env_punch: Option<f64>,
    lpf_resonance: Option<f64>,
    lpf_freq: Option<f64>,
    lpf_ramp: Option<f64>,
    hpf_freq: Option<f64>,
    hpf_ramp: Option<f64>,
    pha_offset: Option<f64>,
    pha_ramp: Option<f64>,
    repeat_speed: Option<f64>,
    arp_speed: Option<f64>,
    arp_mod: Option<f64>,
}

#[derive(Clone)]
pub struct SoundParams {
    sample: Arc<Sample>,
}

impl SoundParams {
    pub fn new(sample: Sample) -> Self {
        Self {
            sample: Arc::new(sample),
        }
    }

    pub fn generator(&self) -> Generator {
        Generator::new(*self.sample.as_ref())
    }

    pub fn from_json(json_str: &str) -> LuaResult<Sample> {
        let json: JsonParams = serde_json::from_str(json_str)
            .map_err(|e| mlua::Error::RuntimeError(format!("Invalid JSON: {}", e)))?;

        let mut sample = Sample::new();

        sample.wave_type = match json.wave_type {
            0 => WaveType::Square,
            1 => WaveType::Sawtooth,
            2 => WaveType::Sine,
            3 => WaveType::Noise,
            4 => WaveType::Triangle,
            _ => WaveType::Square,
        };
        sample.base_freq = json.p_base_freq;
        sample.freq_limit = json.p_freq_limit;
        sample.freq_ramp = json.p_freq_ramp;
        sample.freq_dramp = json.p_freq_dramp;
        sample.duty = json.p_duty;
        sample.duty_ramp = json.p_duty_ramp;
        sample.vib_strength = json.p_vib_strength;
        sample.vib_speed = json.p_vib_speed;
        sample.env_attack = json.p_env_attack;
        sample.env_sustain = json.p_env_sustain;
        sample.env_decay = json.p_env_decay;
        sample.env_punch = json.p_env_punch;
        sample.lpf_resonance = json.p_lpf_resonance;
        sample.lpf_freq = json.p_lpf_freq;
        sample.lpf_ramp = json.p_lpf_ramp;
        sample.hpf_freq = json.p_hpf_freq;
        sample.hpf_ramp = json.p_hpf_ramp;
        sample.pha_offset = json.p_pha_offset;
        sample.pha_ramp = json.p_pha_ramp;
        sample.repeat_speed = json.p_repeat_speed;
        sample.arp_speed = json.p_arp_speed;
        sample.arp_mod = json.p_arp_mod;

        Ok(sample)
    }
}

impl FromLua for SoundParams {
    fn from_lua(value: LuaValue, _: &Lua) -> LuaResult<Self> {
        match value {
            LuaValue::Table(table) => {
                let mut sample = Sample::new();

                fn get_val_from_table<T: FromLua>(
                    table: &LuaTable,
                    key: &str,
                ) -> LuaResult<Option<T>> {
                    if table.contains_key(key)? {
                        table.get(key).map(Some)
                    } else {
                        Ok(None)
                    }
                }

                if let Ok(Some(env_attack)) = get_val_from_table::<f32>(&table, "env_attack") {
                    sample.env_attack = (env_attack / 100000.0).sqrt();
                }

                if let Ok(wave_type) = table.get("wave_type") {
                    sample.wave_type = match wave_type {
                        0 => WaveType::Square,
                        1 => WaveType::Sawtooth,
                        2 => WaveType::Sine,
                        3 => WaveType::Noise,
                        4 => WaveType::Triangle,
                        _ => WaveType::Square,
                    };
                }

                Ok(SoundParams::new(sample))
            }
            LuaValue::String(s) => {
                let sample = Self::from_json(&s.to_str()?)?;
                Ok(SoundParams::new(sample))
            }
            _ => Err(mlua::Error::RuntimeError(
                "Expected table or string for SoundParams".into(),
            )),
        }
    }
}
