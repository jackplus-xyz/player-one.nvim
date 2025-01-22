#[derive(Debug, Clone)]
pub struct SynthParams {
    // Wave
    pub wave_type: u8,
    pub sample_rate: u32,
    pub sample_size: u32,
    // General
    pub volume: f32,
    pub repeat_speed: f32,
    // Envelope
    pub env_attack: f32,
    pub env_sustain: f32,
    pub env_punch: f32,
    pub env_decay: f32,
    // Frequency
    pub freq_base: f32,
    pub freq_limit: f32,
    pub freq_ramp: f32,
    pub freq_dramp: f32,
    // Vibrato
    pub vib_strength: f32,
    pub vib_speed: f32,
    // Arpeggiation
    pub arp_mod: f32,
    pub arp_speed: f32,
    // Duty Cycle
    pub duty: f32,
    pub duty_ramp: f32,
    // Phaser
    pub pha_offset: f32,
    pub pha_ramp: f32,
    // Filters
    pub lpf_freq: f32,
    pub lpf_ramp: f32,
    pub lpf_resonance: f32,
    pub hpf_freq: f32,
    pub hpf_ramp: f32,
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
            freq_base: 0.56,   // C4 note
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
