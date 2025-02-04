use crate::sound::SoundParams;
use rodio::{OutputStream, Sink};
use std::sync::{Arc, Mutex};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum PlayError {
    #[error("Audio device error: {0}")]
    Device(String),
    #[error("Playback error: {0}")]
    Playback(String),
}

pub struct Player {
    sink: Arc<Mutex<Sink>>,
    _stream: OutputStream,
}

impl Player {
    pub fn new() -> Result<Self, PlayError> {
        let (stream, handle) =
            OutputStream::try_default().map_err(|e| PlayError::Device(e.to_string()))?;

        let sink = Sink::try_new(&handle).map_err(|e| PlayError::Device(e.to_string()))?;

        Ok(Self {
            sink: Arc::new(Mutex::new(sink)),
            _stream: stream,
        })
    }

    pub fn play(&self, params: SoundParams) -> Result<(), PlayError> {
        let mut generator = params.generator();

        let total_duration = (generator.sample.env_attack.powi(2)
            + generator.sample.env_sustain.powi(2)
            + generator.sample.env_decay.powi(2))
            * 100000.0;
        let buffer_size = total_duration.ceil() as usize;

        let mut buffer = vec![0.0; buffer_size];
        generator.generate(&mut buffer);

        let source = rodio::buffer::SamplesBuffer::new(1, 44100, buffer);

        let sink = self
            .sink
            .lock()
            .map_err(|e| PlayError::Playback(e.to_string()))?;

        sink.append(source);
        Ok(())
    }

    pub fn play_async(&self, params: SoundParams) -> Result<(), PlayError> {
        self.play(params)?;

        let sink = self
            .sink
            .lock()
            .map_err(|e| PlayError::Playback(e.to_string()))?;

        sink.sleep_until_end();

        Ok(())
    }

    pub fn stop(&self) -> Result<(), PlayError> {
        let sink = self
            .sink
            .lock()
            .map_err(|e| PlayError::Playback(e.to_string()))?;
        sink.stop();
        Ok(())
    }
}
