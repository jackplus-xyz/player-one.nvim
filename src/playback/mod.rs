pub mod error;

use crate::synthesizer::{SynthParams, Synthesizer, MAX_FREQUENCY, MIN_FREQUENCY};
use error::PlaybackError;
use rodio::{OutputStream, Sink};
use std::sync::{Arc, Mutex};

pub const MAX_AMPLITUDE: f32 = 1.0;
pub const MIN_AMPLITUDE: f32 = 0.0;
pub const DEFAULT_VOLUME: f32 = 1.0;

#[derive(Debug, Clone, PartialEq)]
pub enum PlaybackState {
    Playing,
    Stopped,
    Paused,
    Error(String),
}

pub struct Playback {
    sink: Arc<Mutex<Sink>>,
    _stream: OutputStream,
    state: Arc<Mutex<PlaybackState>>,
    volume: Arc<Mutex<f32>>,
}

// We need Send + Sync for thread safety
unsafe impl Send for Playback {}
unsafe impl Sync for Playback {}

impl Playback {
    pub fn new() -> Result<Self, PlaybackError> {
        let (stream, stream_handle) = OutputStream::try_default().map_err(|e| {
            PlaybackError::DeviceError(format!("Failed to create audio stream: {}", e))
        })?;

        let sink = Sink::try_new(&stream_handle).map_err(|e| {
            PlaybackError::DeviceError(format!("Failed to create audio sink: {}", e))
        })?;

        sink.set_volume(DEFAULT_VOLUME);

        Ok(Self {
            sink: Arc::new(Mutex::new(sink)),
            _stream: stream,
            state: Arc::new(Mutex::new(PlaybackState::Stopped)),
            volume: Arc::new(Mutex::new(DEFAULT_VOLUME)),
        })
    }

    fn validate_sound_params(params: &SynthParams) -> Result<(), PlaybackError> {
        if !(MIN_FREQUENCY..=MAX_FREQUENCY).contains(&params.frequency.base) {
            return Err(PlaybackError::InvalidParameter(format!(
                "Base frequency must be between {} and {} Hz",
                MIN_FREQUENCY, MAX_FREQUENCY
            )));
        }

        if !(MIN_AMPLITUDE..=MAX_AMPLITUDE).contains(&(params.general.volume as f32)) {
            return Err(PlaybackError::InvalidParameter(format!(
                "Volume must be between {} and {}",
                MIN_AMPLITUDE, MAX_AMPLITUDE
            )));
        }

        if params.envelope.attack < 0.0
            || params.envelope.sustain < 0.0
            || params.envelope.decay < 0.0
        {
            return Err(PlaybackError::InvalidParameter(
                "Envelope parameters must be non-negative".into(),
            ));
        }
        Ok(())
    }

    pub fn play(&self, mut params: SynthParams) -> Result<(), PlaybackError> {
        Self::validate_sound_params(&params)?;

        let sink = self.sink.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire sink lock: {}", e))
        })?;

        // Apply current volume scaling
        let volume = self.get_volume()?;
        params.general.volume *= volume as f64;

        let source = Synthesizer::new(params);
        sink.append(source);

        // Update state
        let mut state = self.state.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire state lock: {}", e))
        })?;
        *state = PlaybackState::Playing;

        Ok(())
    }

    pub fn play_blocking(&self, params: SynthParams) -> Result<(), PlaybackError> {
        self.play(params)?;
        self.wait_until_end()?;
        Ok(())
    }

    pub fn stop(&self) -> Result<(), PlaybackError> {
        let sink = self.sink.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire sink lock: {}", e))
        })?;

        // First, stop accepting new samples
        sink.pause();
        
        // Wait for the current samples to finish playing, with a timeout
        let timeout = std::time::Duration::from_millis(100);
        let start = std::time::Instant::now();
        while !sink.empty() && start.elapsed() < timeout {
            std::thread::sleep(std::time::Duration::from_millis(10));
        }
        
        // Now clear the sink
        sink.stop();

        let mut state = self.state.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire state lock: {}", e))
        })?;
        *state = PlaybackState::Stopped;

        Ok(())
    }

    pub fn pause(&self) -> Result<(), PlaybackError> {
        let sink = self.sink.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire sink lock: {}", e))
        })?;

        sink.pause();

        let mut state = self.state.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire state lock: {}", e))
        })?;
        *state = PlaybackState::Paused;

        Ok(())
    }

    pub fn resume(&self) -> Result<(), PlaybackError> {
        let sink = self.sink.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire sink lock: {}", e))
        })?;

        sink.play();

        let mut state = self.state.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire state lock: {}", e))
        })?;
        *state = PlaybackState::Playing;

        Ok(())
    }

    pub fn set_volume(&self, volume: f32) -> Result<(), PlaybackError> {
        if !(0.0..=1.0).contains(&volume) {
            return Err(PlaybackError::InvalidParameter(
                "Volume must be between 0.0 and 1.0".into(),
            ));
        }

        let mut vol = self.volume.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire volume lock: {}", e))
        })?;
        *vol = volume;

        let sink = self.sink.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire sink lock: {}", e))
        })?;
        sink.set_volume(volume);

        Ok(())
    }

    pub fn get_volume(&self) -> Result<f32, PlaybackError> {
        self.volume.lock().map(|v| *v).map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire volume lock: {}", e))
        })
    }

    pub fn get_state(&self) -> Result<PlaybackState, PlaybackError> {
        self.state.lock().map(|s| s.clone()).map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire state lock: {}", e))
        })
    }

    pub fn wait_until_end(&self) -> Result<(), PlaybackError> {
        let sink = self.sink.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire sink lock: {}", e))
        })?;

        sink.sleep_until_end();

        let mut state = self.state.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire state lock: {}", e))
        })?;
        *state = PlaybackState::Stopped;

        Ok(())
    }

    pub fn is_empty(&self) -> Result<bool, PlaybackError> {
        let sink = self.sink.lock().map_err(|e| {
            PlaybackError::PlaybackError(format!("Failed to acquire sink lock: {}", e))
        })?;
        Ok(sink.empty())
    }
}

impl Drop for Playback {
    fn drop(&mut self) {
        if let Ok(sink) = self.sink.lock() {
            sink.stop();
        }

        if let Ok(mut state) = self.state.lock() {
            *state = PlaybackState::Error("Player dropped".into());
        }
    }
}
