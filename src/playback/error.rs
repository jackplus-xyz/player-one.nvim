use thiserror::Error;

#[derive(Error, Debug)]
pub enum PlaybackError {
    DeviceError(String),
    InvalidParameter(String),
    PlaybackError(String),
}

impl std::fmt::Display for PlaybackError {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            PlaybackError::DeviceError(msg) => write!(f, "Device error: {}", msg),
            PlaybackError::InvalidParameter(msg) => write!(f, "Invalid parameter: {}", msg),
            PlaybackError::PlaybackError(msg) => write!(f, "Playback error: {}", msg),
        }
    }
}
