use mlua::prelude::*;
use serde::{Deserialize, Serialize};
use sfxr::{Generator, Sample, WaveType};
use std::sync::Arc;

// Used to parse json values from [jsfxr](https://sfxr.me/)
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

    pub fn from_table(table: LuaTable) -> LuaResult<Sample> {
        let mut sample = Sample::new();

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
        if let Ok(v) = table.get::<f64>("base_freq") {
            sample.base_freq = (v * 100.0 / (8.0 * 44100.0) - 0.001).sqrt();
        }
        if let Ok(v) = table.get::<f64>("freq_limit") {
            sample.freq_limit = (v * 100.0 / (8.0 * 44100.0) - 0.001).sqrt();
        }
        if let Ok(v) = table.get::<f64>("freq_ramp") {
            sample.freq_ramp = (-v * 0.01).cbrt();
        }
        if let Ok(v) = table.get::<f64>("freq_dramp") {
            sample.freq_dramp = (v / -0.000001).cbrt();
        }

        if let Ok(v) = table.get::<f32>("duty") {
            sample.duty = (v / 100.0 - 0.5) / -0.5;
        }
        if let Ok(v) = table.get::<f32>("duty_ramp") {
            sample.duty_ramp = v / (-0.00005 * 8.0 * 44100.0);
        }

        if let Ok(v) = table.get::<f64>("vib_speed") {
            sample.vib_speed = (v * 64.0 / 441000.0).sqrt();
        }
        if let Ok(v) = table.get::<f64>("vib_strength") {
            sample.vib_strength = v / 0.5;
        }

        if let Ok(v) = table.get::<f32>("env_attack") {
            sample.env_attack = (v * 44100.0).sqrt();
        }
        if let Ok(v) = table.get::<f32>("env_sustain") {
            sample.env_sustain = (v * 44100.0 / 100000.0).sqrt();
        }

        if let Ok(v) = table.get::<f32>("env_punch") {
            sample.env_punch = (v / 100.0 * 44100.0 / 100000.0).sqrt();
        }
        if let Ok(v) = table.get::<f32>("env_decay") {
            sample.env_decay = (v * 44100.0 / 100000.0).sqrt();
        }

        if let Ok(v) = table.get::<f32>("lpf_freq") {
            sample.lpf_freq = (v / (8.0 * 44100.0 * (1.0 - v / (8.0 * 44100.0))) / 0.1).cbrt();
        }
        if let Ok(v) = table.get::<f32>("lpf_ramp") {
            if v != 0.0 {
                sample.lpf_ramp = (v.powf(1.0 / 44100.0) - 1.0) / 0.0003;
            }
        }
        if let Ok(v) = table.get::<f32>("lpf_resonance") {
            sample.lpf_resonance = ((1.0 / ((100.0 - v) / 500.0) - 1.0) / 20.0).sqrt();
        }

        if let Ok(v) = table.get::<f32>("hpf_freq") {
            sample.hpf_freq = (v / (8.0 * 44100.0 * (1.0 - v / (8.0 * 44100.0))) / 0.1).sqrt();
        }
        if let Ok(v) = table.get::<f32>("hpf_ramp") {
            if v != 0.0 {
                sample.hpf_ramp = (v.powf(1.0 / 44100.0) - 1.0) / 0.0003;
            }
        }
        if let Ok(mut v) = table.raw_get::<f32>("pha_offset") {
            if v < 0.0 {
                v = -1.0
            } else {
                v = 1.0
            }
            sample.pha_offset = ((v * 44.1).abs() / 1020.0).sqrt();
        }
        if let Ok(v) = table.raw_get::<f32>("pha_ramp") {
            sample.pha_ramp = (if v < 0.0 { -1.0 } else { 1.0 }) * (v.abs() / 1000.0).sqrt();
        }
        if let Ok(v) = table.raw_get::<f32>("repeat_speed") {
            if v != 0.0 {
                sample.repeat_speed = -(((44100.0 / v - 32.0) / 20000.0).sqrt() - 1.0)
            };
        }

        if let Ok(v) = table.raw_get::<f32>("arp_speed") {
            sample.arp_speed = if v == 0.0 {
                1.
            } else {
                1.0 - ((v * 44100.0 - 32.0) / 20000.0).sqrt()
            };
        }
        if let Ok(mut v) = table.raw_get::<f64>("arp_mod") {
            if v != 0.0 {
                v = 1.0 / v
            }
            sample.arp_mod = if v < 1.0 {
                ((1.0 - v) / 0.9).sqrt()
            } else {
                -((v - 1.0) / 10.0).sqrt()
            };
        }
        // TODO: add volume config?
        // if let Ok(v) = table.raw_get::<f64>("sound_vol") {
        //     sample.volume = (10f64.powf(v / 10.0)).sqrt().ln() + 1.0;
        // }

        Ok(sample)
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
                let sample = Self::from_table(table)?;
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
