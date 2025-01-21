use super::params::*;
use super::{MAX_FREQUENCY, MIN_FREQUENCY};
use oorandom::Rand32;
use rodio::Source;
use std::f32::consts::PI;
use std::time::Duration;

pub struct Synthesizer {
    params: SynthParams,
    pub(crate) sample_clock: f32,
    pub(crate) phase: f32,
    pub(crate) env_time: f32,
    flt_dp: f32,
    flt_w: f32,
    flt_dw: f32,
    flt_pos: f32,
    flt_prev: f32,
    rng: Rand32,
    finished: bool,
    // Cache for wave lookup
    wave_lookup: Vec<f32>,
    wave_lookup_size: usize,
}

impl Synthesizer {
    pub fn new(params: SynthParams) -> Self {
        let rng = Rand32::new(0);
        let wave_lookup_size = 1024;
        let wave_lookup = match params.wave_type {
            WaveType::Sine => {
                let mut lookup = Vec::with_capacity(wave_lookup_size);
                for i in 0..wave_lookup_size {
                    let phase = i as f32 / wave_lookup_size as f32;
                    lookup.push((phase * 2.0 * PI).sin());
                }
                lookup
            }
            WaveType::Triangle => {
                let mut lookup = Vec::with_capacity(wave_lookup_size);
                for i in 0..wave_lookup_size {
                    let phase = i as f32 / wave_lookup_size as f32;
                    lookup.push(if phase < 0.5 {
                        phase * 4.0 - 1.0
                    } else {
                        3.0 - phase * 4.0
                    });
                }
                lookup
            }
            _ => Vec::new(), // Other waveforms are generated on-the-fly
        };

        Self {
            params,
            sample_clock: 0.0,
            phase: 0.0,
            env_time: 0.0,
            flt_dp: 0.0,
            flt_w: 0.0,
            flt_dw: 0.0,
            flt_pos: 0.0,
            flt_prev: 0.0,
            rng,
            finished: false,
            wave_lookup,
            wave_lookup_size,
        }
    }

    pub(crate) fn get_envelope(&self) -> f32 {
        let env = &self.params.envelope;
        let env_time = self.env_time;

        if env_time < env.attack {
            // Attack phase
            env_time / env.attack
        } else if env_time < env.attack + env.sustain {
            // Sustain phase with punch
            1.0 + env.punch * (1.0 - (env_time - env.attack) / env.sustain)
        } else if env_time < env.attack + env.sustain + env.decay {
            // Decay phase
            let decay_time = env_time - env.attack - env.sustain;
            1.0 - (decay_time / env.decay)
        } else {
            // Sound finished
            0.0
        }
    }

    fn get_wave(&mut self, phase: f32) -> f32 {
        match self.params.wave_type {
            WaveType::Sine => {
                if self.wave_lookup.is_empty() {
                    (phase * 2.0 * PI).sin()
                } else {
                    let index =
                        (phase * self.wave_lookup_size as f32) as usize % self.wave_lookup_size;
                    self.wave_lookup[index]
                }
            }
            WaveType::Square => {
                let duty = self.params.duty_cycle.duty;
                if phase < duty {
                    1.0
                } else {
                    -1.0
                }
            }
            WaveType::Sawtooth => 1.0 - phase * 2.0,
            WaveType::Triangle => {
                if self.wave_lookup.is_empty() {
                    if phase < 0.5 {
                        phase * 4.0 - 1.0
                    } else {
                        3.0 - phase * 4.0
                    }
                } else {
                    let index =
                        (phase * self.wave_lookup_size as f32) as usize % self.wave_lookup_size;
                    self.wave_lookup[index]
                }
            }
            WaveType::Noise => self.rng.rand_float() * 2.0 - 1.0,
        }
    }

    fn apply_filter(&mut self, sample: f32) -> f32 {
        let flt = &self.params.filter;

        // Skip filtering if no filters are active
        if flt.lpf_freq <= 0.0 && flt.hpf_freq <= 0.0 {
            return sample;
        }

        // Apply low-pass filter
        if flt.lpf_freq > 0.0 {
            self.flt_w *= flt.lpf_ramp;
            self.flt_w = self.flt_w.clamp(0.0, 0.1);
            self.flt_dp += (sample - self.flt_pos) * self.flt_w;
            self.flt_pos += self.flt_dp;
        }

        // Apply high-pass filter
        if flt.hpf_freq > 0.0 {
            self.flt_dw *= flt.hpf_ramp;
            self.flt_dw = self.flt_dw.clamp(0.0, 0.1);
            self.flt_dp -= self.flt_dp * self.flt_dw;
        }

        self.flt_pos
    }
}

impl Source for Synthesizer {
    fn current_frame_len(&self) -> Option<usize> {
        None
    }

    fn channels(&self) -> u16 {
        1
    }

    fn sample_rate(&self) -> u32 {
        self.params.general.sample_rate
    }

    fn total_duration(&self) -> Option<Duration> {
        let total_time =
            self.params.envelope.attack + self.params.envelope.sustain + self.params.envelope.decay;
        Some(Duration::from_secs_f32(total_time))
    }
}

impl Iterator for Synthesizer {
    type Item = f32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.finished {
            return None;
        }

        // Time tracking
        let sample_rate = self.sample_rate() as f32;
        self.sample_clock += 1.0;
        self.env_time = self.sample_clock / sample_rate;

        // Get envelope
        let env = self.get_envelope();
        if env <= 0.0 {
            self.finished = true;
            return Some(0.0);
        }

        // Calculate frequency with all modulations
        let freq = &self.params.frequency;
        let mut freq_val = freq.base;

        // Apply frequency modulations
        if freq.ramp != 0.0 {
            freq_val += self.env_time * freq.ramp;
        }
        if freq.dramp != 0.0 {
            freq_val *= 1.0 + (self.env_time * freq.dramp).exp2();
        }

        // Apply frequency limit
        if freq.limit > 0.0 {
            freq_val = freq_val.min(freq.limit);
        }
        freq_val = freq_val.clamp(MIN_FREQUENCY, MAX_FREQUENCY);

        // Apply vibrato
        let vib = &self.params.vibrato;
        if vib.speed > 0.0 {
            freq_val += (self.env_time * vib.speed * PI * 2.0).sin() * vib.strength;
        }

        // Apply arpeggiation
        let arp = &self.params.arpeggiation;
        if arp.speed > 0.0 {
            freq_val *= (self.env_time * arp.speed * PI * 2.0).sin().abs() * arp.mult + 1.0;
        }

        // Update phase (calculate phase increment based on frequency)
        let phase_inc = freq_val * 2.0 * PI / sample_rate; // Convert frequency to radians per sample
        self.phase += phase_inc;
        if self.phase >= 2.0 * PI {
            self.phase -= 2.0 * PI;
        }

        // Generate base waveform
        let mut sample = self.get_wave(self.phase / (2.0 * PI)); // Normalize phase to 0-1 range

        // Apply filters
        sample = self.apply_filter(sample);

        // Apply phaser
        let pha = &self.params.phaser;
        if pha.offset != 0.0 || pha.ramp != 0.0 {
            self.flt_dp = (self.flt_dp + pha.offset * (self.env_time * pha.ramp).sin()) % 1.0;
            sample += self.flt_prev * self.flt_dp;
            self.flt_prev = sample;
        }

        // Apply envelope and volume
        sample *= env * self.params.general.volume as f32;

        Some(sample)
    }
}
