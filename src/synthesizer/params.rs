use super::SAMPLE_RATE;

#[derive(Clone, Copy, Debug)]
pub enum WaveType {
    Square,
    Sawtooth,
    Sine,
    Noise,
    Triangle,
}

impl Default for WaveType {
    fn default() -> Self {
        Self::Square
    }
}

#[derive(Clone, Copy)]
pub struct Envelope {
    pub attack: f32,
    pub sustain: f32,
    pub punch: f32,
    pub decay: f32,
}

impl Default for Envelope {
    fn default() -> Self {
        Self {
            attack: 0.01,
            sustain: 0.3,
            punch: 0.0,
            decay: 0.4,
        }
    }
}

#[derive(Clone, Copy)]
pub struct Frequency {
    pub base: f32,
    pub limit: f32,
    pub ramp: f32,
    pub dramp: f32,
}

impl Default for Frequency {
    fn default() -> Self {
        Self {
            base: 440.0,
            limit: 0.0,
            ramp: 0.0,
            dramp: 0.0,
        }
    }
}

#[derive(Clone, Copy)]
pub struct Vibrato {
    pub strength: f32,
    pub speed: f32,
}

impl Default for Vibrato {
    fn default() -> Self {
        Self {
            strength: 0.0,
            speed: 0.0,
        }
    }
}

#[derive(Clone, Copy)]
pub struct Arpeggiation {
    pub mult: f32,
    pub speed: f32,
}

impl Default for Arpeggiation {
    fn default() -> Self {
        Self {
            mult: 0.0,
            speed: 0.0,
        }
    }
}

#[derive(Clone, Copy)]
pub struct DutyCycle {
    pub duty: f32,
    pub ramp: f32,
}

impl Default for DutyCycle {
    fn default() -> Self {
        Self {
            duty: 0.5,
            ramp: 0.0,
        }
    }
}

#[derive(Clone, Copy)]
pub struct Phaser {
    pub offset: f32,
    pub ramp: f32,
}

impl Default for Phaser {
    fn default() -> Self {
        Self {
            offset: 0.0,
            ramp: 0.0,
        }
    }
}

#[derive(Clone, Copy)]
pub struct Filter {
    pub lpf_freq: f32,
    pub lpf_ramp: f32,
    pub lpf_resonance: f32,
    pub hpf_freq: f32,
    pub hpf_ramp: f32,
}

impl Default for Filter {
    fn default() -> Self {
        Self {
            lpf_freq: 1.0,
            lpf_ramp: 0.0,
            lpf_resonance: 0.0,
            hpf_freq: 0.0,
            hpf_ramp: 0.0,
        }
    }
}

#[derive(Clone, Copy)]
pub struct General {
    pub repeat_speed: f64,
    pub volume: f64,
    pub sample_rate: u32,
    pub sample_size: u8,
}

impl Default for General {
    fn default() -> Self {
        Self {
            repeat_speed: 0.0,
            volume: 1.0,
            sample_rate: SAMPLE_RATE,
            sample_size: 16,
        }
    }
}

pub struct WaveConfig {
    pub wave_type: WaveType,
    pub duty_cycle: DutyCycle,
}

pub struct ModulationConfig {
    pub vibrato: Vibrato,
    pub phaser: Phaser,
}

pub struct SoundConfig {
    pub envelope: Envelope,
    pub frequency: Frequency,
    pub arpeggiation: Arpeggiation,
}

#[derive(Clone, Default)]
pub struct SynthParams {
    pub wave_type: WaveType,
    pub envelope: Envelope,
    pub frequency: Frequency,
    pub vibrato: Vibrato,
    pub arpeggiation: Arpeggiation,
    pub duty_cycle: DutyCycle,
    pub phaser: Phaser,
    pub filter: Filter,
    pub general: General,
}

impl SynthParams {
    pub fn new(
        wave_config: Option<WaveConfig>,
        sound_config: Option<SoundConfig>,
        modulation_config: Option<ModulationConfig>,
        filter: Option<Filter>,
        general: Option<General>,
    ) -> Self {
        let default = Self::default();
        let default_wave = WaveConfig {
            wave_type: default.wave_type,
            duty_cycle: default.duty_cycle,
        };
        let default_sound = SoundConfig {
            envelope: default.envelope,
            frequency: default.frequency,
            arpeggiation: default.arpeggiation,
        };
        let default_mod = ModulationConfig {
            vibrato: default.vibrato,
            phaser: default.phaser,
        };

        let wave = wave_config.unwrap_or(default_wave);
        let sound = sound_config.unwrap_or(default_sound);
        let modulation = modulation_config.unwrap_or(default_mod);

        SynthParams {
            wave_type: wave.wave_type,
            duty_cycle: wave.duty_cycle,
            envelope: sound.envelope,
            frequency: sound.frequency,
            arpeggiation: sound.arpeggiation,
            vibrato: modulation.vibrato,
            phaser: modulation.phaser,
            filter: filter.unwrap_or(default.filter),
            general: general.unwrap_or(default.general),
        }
    }
}
