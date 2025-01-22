#[cfg(test)]
use crate::playback::{Playback, PlaybackState};
use crate::synthesizer::SynthParams;
use std::time::Duration;

#[test]
fn test_playback_initialization() {
    let playback = Playback::new();
    assert!(playback.is_ok());

    let playback = playback.unwrap();
    assert_eq!(playback.get_volume().unwrap(), 1.0); // DEFAULT_VOLUME
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Stopped
    ));
}

#[test]
fn test_volume_control() {
    let playback = Playback::new().unwrap();

    // Test valid volume settings
    assert!(playback.set_volume(0.5).is_ok());
    assert_eq!(playback.get_volume().unwrap(), 0.5);

    // Test volume limits
    assert!(playback.set_volume(0.0).is_ok());
    assert!(playback.set_volume(1.0).is_ok());

    // Test invalid volume settings
    assert!(playback.set_volume(-0.1).is_err());
    assert!(playback.set_volume(1.1).is_err());
}

#[test]
fn test_synth_params_default() {
    let params = SynthParams::default();

    // Test default wave settings
    assert_eq!(params.wave_type, 0); // Square wave
    assert_eq!(params.sample_rate, 44100);
    assert_eq!(params.sample_size, 8);

    // Test default volume
    assert_eq!(params.volume, 0.25);

    // Test default envelope
    assert_eq!(params.env_attack, 0.0);
    assert_eq!(params.env_sustain, 0.03);
    assert_eq!(params.env_punch, 0.42);
    assert_eq!(params.env_decay, 0.35);
}

#[test]
fn test_sound_playback() {
    let playback = Playback::new().unwrap();
    let params = SynthParams {
        freq_base: 440.0, // A4 note
        env_attack: 0.01,
        env_sustain: 0.02,
        env_decay: 0.02,
        volume: 0.5,
        ..Default::default()
    };

    // Test playing sound
    assert!(playback.play(params.clone()).is_ok());
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Playing
    ));

    // Wait for sound to finish
    std::thread::sleep(Duration::from_millis(100));

    // Test stopping sound
    assert!(playback.stop().is_ok());
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Stopped
    ));
}

#[test]
fn test_playback_controls() {
    let playback = Playback::new().unwrap();
    let params = SynthParams {
        freq_base: 440.0, // Add a valid frequency
        volume: 0.5,      // Add a valid volume
        env_sustain: 0.5, // Longer sustain for testing controls
        env_attack: 0.01, // Add reasonable envelope parameters
        env_decay: 0.1,
        ..Default::default()
    };

    // Start playback
    assert!(playback.play(params).is_ok());
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Playing
    ));

    // Test pause
    assert!(playback.pause().is_ok());
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Paused
    ));

    // Test resume
    assert!(playback.resume().is_ok());
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Playing
    ));

    // Test stop
    assert!(playback.stop().is_ok());
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Stopped
    ));
}

#[test]
fn test_invalid_parameters() {
    let playback = Playback::new().unwrap();

    // Test invalid frequency
    let params_invalid_freq = SynthParams {
        freq_base: -1.0,
        ..Default::default()
    };
    assert!(playback.play(params_invalid_freq.clone()).is_err());

    // Test invalid volume
    let params_invalid_volume = SynthParams {
        freq_base: 440.0,
        volume: 1.5,
        ..Default::default()
    };
    assert!(playback.play(params_invalid_volume.clone()).is_err());

    // Test invalid envelope parameters
    let params_invalid_envelope = SynthParams {
        volume: 0.5,
        env_attack: -0.1,
        ..Default::default()
    };
    assert!(playback.play(params_invalid_envelope.clone()).is_err());
}

#[test]
fn test_concurrent_playback() {
    let playback = Playback::new().unwrap();
    let mut params1 = SynthParams::default();
    let mut params2 = SynthParams::default();

    // Configure two different sounds
    params1.freq_base = 440.0; // A4
    params2.freq_base = 554.37; // C#5

    // Play first sound
    assert!(playback.play(params1).is_ok());

    // Attempt to play second sound while first is playing
    assert!(playback.play(params2).is_ok());

    // Stop playback
    assert!(playback.stop().is_ok());
}

#[test]
fn test_waveform_types() {
    let playback = Playback::new().unwrap();
    let base_params = SynthParams {
        freq_base: 440.0, // Add a valid frequency
        volume: 0.5,      // Add a valid volume
        env_sustain: 0.1,
        env_attack: 0.01, // Add reasonable envelope parameters
        env_decay: 0.1,
        ..Default::default()
    };

    // Test each waveform type
    for wave_type in 0..=4 {
        let test_params = SynthParams {
            wave_type,
            ..base_params.clone()
        };
        assert!(playback.play(test_params).is_ok());
        std::thread::sleep(Duration::from_millis(50));
        assert!(playback.stop().is_ok());
    }
}

#[test]
fn test_sink_drop_behavior() {
    let playback = Playback::new().unwrap();
    let params = SynthParams {
        freq_base: 440.0, // Add a valid frequency
        volume: 0.5,      // Add a valid volume
        env_attack: 0.01, // Add reasonable envelope parameters
        env_decay: 0.1,
        env_sustain: 0.1,
        ..Default::default()
    };

    // Start playback
    assert!(playback.play(params).is_ok());

    // Drop the playback instance
    drop(playback);

    // Create new instance to ensure we can still create playback after dropping
    assert!(Playback::new().is_ok());
}
