use crate::SynthParams;
use rand::Rng;
use rodio::Source;
use std::f32::consts::PI;
use std::time::Duration;

#[derive(Debug)]
pub struct SynthSource {
    params: SynthParams,
    sample_clock: usize,
    phase: f32,
    last_sample: f32,
}

impl SynthSource {
    pub fn new(params: SynthParams) -> Self {
        Self {
            params,
            sample_clock: 0,
            phase: 0.0,
            last_sample: 0.0,
        }
    }

    fn synthesize(&mut self) -> f32 {
        let frequency = 440.0 * self.params.freq_base;
        let period = self.params.sample_rate as f32 / frequency;

        self.phase += 1.0;
        if self.phase >= period {
            self.phase -= period;
        }

        // Generate base waveform
        let phase_ratio = self.phase / period;
        let mut sample = match self.params.wave_type {
            0 => {
                // Square
                if phase_ratio < 0.5 {
                    1.0
                } else {
                    -1.0
                }
            }
            1 => {
                // Sawtooth
                2.0 * phase_ratio - 1.0
            }
            2 => {
                // Sine
                (2.0 * PI * phase_ratio).sin()
            }
            3 => {
                // Noise
                let mut rng = rand::thread_rng();
                rng.gen_range(-1.0..=1.0)
            }
            4 => {
                // Triangle
                if phase_ratio < 0.25 {
                    4.0 * phase_ratio
                } else if phase_ratio < 0.75 {
                    2.0 - 4.0 * phase_ratio
                } else {
                    -4.0 + 4.0 * phase_ratio
                }
            }
            _ => 0.0,
        };

        // Apply vibrato
        if self.params.vib_strength > 0.0 {
            let vibrato =
                (self.sample_clock as f32 * self.params.vib_speed).sin() * self.params.vib_strength;
            sample *= 1.0 + vibrato;
        }

        // Apply arpeggio
        if self.params.arp_mod != 0.0 {
            let arp_time = (self.sample_clock as f32 * self.params.arp_speed) as i32;
            let arp_mod = match arp_time % 3 {
                0 => 1.0,
                1 => self.params.arp_mod,
                _ => 1.0 / self.params.arp_mod,
            };
            sample *= arp_mod;
        }

        // Apply duty cycle (for square wave)
        if self.params.wave_type == 0 {
            let duty = self.params.duty
                + self.params.duty_ramp
                    * (self.sample_clock as f32 / self.params.sample_rate as f32);
            if phase_ratio < duty.clamp(0.0, 1.0) {
                sample *= 1.0;
            } else {
                sample *= -1.0;
            }
        }

        // Apply phaser
        if self.params.pha_offset != 0.0 {
            let phaser_pos = self.phase
                + self.params.pha_offset
                + self.params.pha_ramp
                    * (self.sample_clock as f32 / self.params.sample_rate as f32);
            let phased_sample = match self.params.wave_type {
                0 => {
                    if (phaser_pos % period) / period < 0.5 {
                        1.0
                    } else {
                        -1.0
                    }
                }
                1 => 2.0 * ((phaser_pos % period) / period) - 1.0,
                2 => (2.0 * PI * (phaser_pos % period) / period).sin(),
                3 => sample, // No phasing for noise
                4 => {
                    let pr = (phaser_pos % period) / period;
                    if pr < 0.25 {
                        4.0 * pr
                    } else if pr < 0.75 {
                        2.0 - 4.0 * pr
                    } else {
                        -4.0 + 4.0 * pr
                    }
                }
                _ => 0.0,
            };
            sample = (sample + phased_sample) * 0.5;
        }

        // Apply low-pass filter
        let lpf_freq = self.params.lpf_freq
            + self.params.lpf_ramp * (self.sample_clock as f32 / self.params.sample_rate as f32);
        if lpf_freq < 1.0 {
            self.last_sample = self.last_sample + (lpf_freq * (sample - self.last_sample));
            sample = self.last_sample;
        }

        // Apply high-pass filter
        let hpf_freq = self.params.hpf_freq
            + self.params.hpf_ramp * (self.sample_clock as f32 / self.params.sample_rate as f32);
        if hpf_freq > 0.0 {
            sample -= self.last_sample;
            self.last_sample = sample;
            sample *= hpf_freq;
        }

        // Apply envelope
        let elapsed_time = self.sample_clock as f32 / self.params.sample_rate as f32;
        let envelope = if elapsed_time < self.params.env_attack {
            // Attack phase
            elapsed_time / self.params.env_attack
        } else if elapsed_time < self.params.env_attack + self.params.env_sustain {
            // Sustain phase
            1.0 + self.params.env_punch
                * (1.0 - (elapsed_time - self.params.env_attack) / self.params.env_sustain)
        } else if elapsed_time
            < self.params.env_attack + self.params.env_sustain + self.params.env_decay
        {
            // Decay phase
            let decay_progress = (elapsed_time - self.params.env_attack - self.params.env_sustain)
                / self.params.env_decay;
            1.0 - decay_progress
        } else {
            0.0
        };

        // Apply final volume
        sample *= envelope * self.params.volume;

        // Clamp the output to prevent distortion
        sample = sample.clamp(-1.0, 1.0);

        self.last_sample = sample;
        sample
    }
}

impl Source for SynthSource {
    fn current_frame_len(&self) -> Option<usize> {
        None // Continuous stream
    }

    fn channels(&self) -> u16 {
        1 // Mono output
    }

    fn sample_rate(&self) -> u32 {
        self.params.sample_rate
    }

    fn total_duration(&self) -> Option<Duration> {
        let total_time = self.params.env_attack + self.params.env_sustain + self.params.env_decay;
        Some(Duration::from_secs_f32(total_time))
    }
}

impl Iterator for SynthSource {
    type Item = f32;

    fn next(&mut self) -> Option<f32> {
        if self.sample_clock
            >= (self.total_duration()?.as_secs_f32() * self.params.sample_rate as f32) as usize
        {
            return None;
        }

        self.sample_clock += 1;
        Some(self.synthesize())
    }
}
