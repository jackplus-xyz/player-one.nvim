mod engine;
mod params;

pub use engine::Synthesizer;
pub use params::{SynthParams, WaveType};

pub const SAMPLE_RATE: u32 = 44100;
pub const MIN_FREQUENCY: f32 = 20.0;
pub const MAX_FREQUENCY: f32 = 20000.0;
