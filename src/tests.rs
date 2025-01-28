#[cfg(test)]
use crate::playback::{Playback, PlaybackState};
use crate::synthesizer::SynthParams;
use std::time::Duration;

#[test]
fn test_playback_initialization() {
    let playback = Playback::new();
    assert!(playback.is_ok());

    let playback = playback.unwrap();
    assert_eq!(playback.get_volume().unwrap(), 1.0);
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
    assert_eq!(params.volume, 0.5);

    // Test default envelope
    assert_eq!(params.env_attack, 0.0);
    assert_eq!(params.env_sustain, 0.3);
    assert_eq!(params.env_punch, 0.0);
    assert_eq!(params.env_decay, 0.4);
}

#[test]
fn test_sound_playback() {
    let playback = Playback::new().unwrap();
    let params = SynthParams {
        env_attack: 0.1,   // Longer attack time
        env_sustain: 0.5,  // Longer sustain
        env_decay: 0.5,    // Longer decay
        freq_base: 440.0,  // A4 note
        volume: 0.5,       // Increased volume
        vib_strength: 0.3, // Add some vibrato
        vib_speed: 4.0,    // Moderate vibrato speed
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
    let params = SynthParams {
        ..Default::default()
    };

    // Test each waveform type
    for wave_type in 0..=4 {
        let test_params = SynthParams {
            wave_type,
            ..params.clone()
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

#[test]
fn test_play_notes() {
    let playback = Playback::new().unwrap();
    let base_params = SynthParams {
        ..Default::default()
    };

    // Frequencies for notes from C4 to C5
    let frequencies = [
        261.63, // C4
        277.18, // C#4/Db4
        293.66, // D4
        311.13, // D#4/Eb4
        329.63, // E4
        349.23, // F4
        369.99, // F#4/Gb4
        392.00, // G4
        415.30, // G#4/Ab4
        440.00, // A4
        466.16, // A#4/Bb4
        493.88, // B4
        523.25, // C5
    ];

    for &freq in frequencies.iter() {
        let test_params = SynthParams {
            freq_base: freq,
            ..base_params.clone()
        };
        assert!(playback.play(test_params).is_ok());
        std::thread::sleep(Duration::from_millis(100));
        assert!(playback.stop().is_ok());
    }
}

#[test]
fn test_envelope_behavior() {
    let playback = Playback::new().unwrap();

    // Test different envelope configurations
    let test_cases = vec![
        // Fast attack, long sustain
        SynthParams {
            env_attack: 0.01,
            env_sustain: 0.5,
            env_decay: 0.1,
            env_punch: 0.0,
            ..Default::default()
        },
        // Long attack, short sustain
        SynthParams {
            env_attack: 0.3,
            env_sustain: 0.1,
            env_decay: 0.1,
            env_punch: 0.2,
            ..Default::default()
        },
        // Max envelope values
        SynthParams {
            env_attack: 1.0,
            env_sustain: 1.0,
            env_decay: 1.0,
            env_punch: 1.0,
            ..Default::default()
        },
    ];

    for params in test_cases {
        assert!(playback.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(50));
        assert!(playback.stop().is_ok());
    }
}

#[test]
fn test_vibrato_effects() {
    let playback = Playback::new().unwrap();

    let test_cases = vec![
        // Light vibrato
        SynthParams {
            vib_strength: 0.1,
            vib_speed: 2.0,
            ..Default::default()
        },
        // Heavy vibrato
        SynthParams {
            vib_strength: 0.8,
            vib_speed: 8.0,
            ..Default::default()
        },
        // Extreme values
        SynthParams {
            vib_strength: 1.0,
            vib_speed: 10.0,
            ..Default::default()
        },
    ];

    for params in test_cases {
        assert!(playback.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(100));
        assert!(playback.stop().is_ok());
    }
}

#[test]
fn test_filter_effects() {
    let playback = Playback::new().unwrap();

    let test_cases = vec![
        // Low-pass filter
        SynthParams {
            lpf_freq: 0.5,
            lpf_ramp: 0.1,
            lpf_resonance: 0.5,
            ..Default::default()
        },
        // High-pass filter
        SynthParams {
            hpf_freq: 0.3,
            hpf_ramp: 0.1,
            ..Default::default()
        },
        // Both filters
        SynthParams {
            lpf_freq: 0.7,
            lpf_resonance: 0.3,
            hpf_freq: 0.2,
            ..Default::default()
        },
    ];

    for params in test_cases {
        assert!(playback.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(100));
        assert!(playback.stop().is_ok());
    }
}

#[test]
fn test_json_parameters() {
    let playback = Playback::new().unwrap();
    let json_params = r#"{
        "oldParams": true,
        "wave_type": 1,
        "p_env_attack": 0,
        "p_env_sustain": 0.04411743910371005,
        "p_env_punch": 0.4350212384906197,
        "p_env_decay": 0.4211059470727624,
        "p_base_freq": 0.7196594711465818,
        "p_freq_limit": 0,
        "p_freq_ramp": 0,
        "p_freq_dramp": 0,
        "p_vib_strength": 0,
        "p_vib_speed": 0,
        "p_arp_mod": 0.378708522940697,
        "p_arp_speed": 0.6285888669803376,
        "p_duty": 0,
        "p_duty_ramp": 0,
        "p_repeat_speed": 0,
        "p_pha_offset": 0,
        "p_pha_ramp": 0,
        "p_lpf_freq": 1,
        "p_lpf_ramp": 0,
        "p_lpf_resonance": 0,
        "p_hpf_freq": 0,
        "p_hpf_ramp": 0,
        "sound_vol": 0.25,
        "sample_rate": 44100,
        "sample_size": 8
    }"#;

    let params =
        SynthParams::from_json(json_params).expect("Failed to parse synth parameters from JSON");
    assert!(playback.play(params).is_ok());

    // Test invalid JSON
    let invalid_json = r#"{"wave_type": "invalid"}"#;
    assert!(SynthParams::from_json(invalid_json).is_err());
}

#[test]
fn test_edge_case_parameters() {
    let playback = Playback::new().unwrap();

    // Test parameter ranges
    let edge_cases = vec![
        // Minimum valid frequency
        SynthParams {
            freq_base: 20.0,
            ..Default::default()
        },
        // Maximum valid frequency
        SynthParams {
            freq_base: 22050.0,
            ..Default::default()
        },
        // Minimum volume
        SynthParams {
            volume: 0.0,
            ..Default::default()
        },
        // Maximum volume
        SynthParams {
            volume: 1.0,
            ..Default::default()
        },
    ];

    for params in edge_cases {
        assert!(playback.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(50));
        assert!(playback.stop().is_ok());
    }
}

#[test]
fn test_error_handling() {
    let playback = Playback::new().unwrap();

    // Test concurrent operations
    let params = SynthParams::default();
    assert!(playback.play(params.clone()).is_ok());

    // Try to pause while stopped
    playback.stop().unwrap();
    assert!(playback.pause().is_ok());

    // Try to resume while stopped
    assert!(playback.resume().is_ok());

    // Test invalid state transitions
    playback.stop().unwrap();
    assert!(playback.stop().is_ok()); // Should handle double stop gracefully
}

#[test]
fn test_state_transitions() {
    let playback = Playback::new().unwrap();
    let params = SynthParams::default();

    // Test full state cycle
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Stopped
    ));

    playback.play(params.clone()).unwrap();
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Playing
    ));

    playback.pause().unwrap();
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Paused
    ));

    playback.resume().unwrap();
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Playing
    ));

    playback.stop().unwrap();
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Stopped
    ));
}

#[test]
fn test_specific_sound_parameters() {
    let json_params = r#"{
        "wave_type": 1,
        "p_env_attack": 0.0,
        "p_env_sustain": 0.2085214052828498,
        "p_env_punch": 0.07627120320112912,
        "p_env_decay": 0.6375892081597456,
        "p_base_freq": 0.2723171360931539,
        "p_freq_limit": 0.0,
        "p_freq_ramp": 0.0,
        "p_freq_dramp": 0.0,
        "p_vib_strength": 0.0,
        "p_vib_speed": 0.0,
        "p_arp_mod": 0.7454,
        "p_arp_speed": 0.8026369371272526,
        "p_duty": 0.19997913173878423,
        "p_duty_ramp": 0.0,
        "p_repeat_speed": 0.0,
        "p_pha_offset": 0.0,
        "p_pha_ramp": 0.0,
        "p_lpf_freq": 0.10977949670708084,
        "p_lpf_ramp": 0.888955760020286,
        "p_lpf_resonance": 0.19946614651039674,
        "p_hpf_freq": 0.0,
        "p_hpf_ramp": 0.0,
        "sound_vol": 0.25,
        "sample_rate": 44100,
        "sample_size": 8
    }"#;

    let playback = Playback::new().unwrap();
    let params = SynthParams::from_json(json_params).unwrap();

    assert!(playback.play(params).is_ok());
}

#[test]
fn test_play_async() {
    let playback = Playback::new().unwrap();

    let note_sequence = vec![
        (392.00, "G4"),
        (369.99, "F#4"),
        (311.13, "D#4"),
        (220.00, "A3"),
        (207.65, "G#3"),
        (329.63, "E4"),
        (415.30, "G#4"),
        (523.25, "C5"),
    ];

    // Test initial state
    assert!(matches!(
        playback.get_state().unwrap(),
        PlaybackState::Stopped
    ));

    let start_time = std::time::Instant::now();

    // Play each note and wait for completion
    for (freq, note_name) in note_sequence {
        let params = SynthParams {
            freq_base: freq,
            // env_attack: 0.01,
            // env_sustain: 0.05,
            // env_decay: 0.1,
            // volume: 0.5,
            ..Default::default()
        };

        println!("Playing {}", note_name);

        // Play and wait for completion
        assert!(playback.play_async(params).is_ok());

        // Verify state is Stopped after completion
        assert!(matches!(
            playback.get_state().unwrap(),
            PlaybackState::Stopped
        ));
        assert!(playback.is_empty().unwrap());
    }

    let duration = start_time.elapsed();

    // Ensure total duration is reasonable (at least 400ms for 4 notes)
    assert!(
        duration >= std::time::Duration::from_millis(400),
        "Sequence played too quickly: {:?}",
        duration
    );

    println!("Sequence completed in {:?}", duration);
}

#[test]
fn test_jsfxr_param_conversion() {
    let json = r#"{
        "wave_type": 1,
        "p_env_attack": 0.0,
        "p_env_sustain": 0.024555768060600138,
        "p_env_punch": 0.4571553721133509,
        "p_env_decay": 0.3423639066276736,
        "p_base_freq": 0.5500696633190347,
        "p_freq_limit": 0.0,
        "p_freq_ramp": 0.0,
        "p_freq_dramp": 0.0,
        "p_vib_strength": 0.0,
        "p_vib_speed": 0.0,
        "p_arp_mod": 0.5329522492796008,
        "p_arp_speed": 0.689393158112304,
        "p_duty": 0.0,
        "p_duty_ramp": 0.0,
        "p_repeat_speed": 0.0,
        "p_pha_offset": 0.0,
        "p_pha_ramp": 0.0,
        "p_lpf_freq": 1.0,
        "p_lpf_ramp": 0.0,
        "p_lpf_resonance": 0.0,
        "p_hpf_freq": 0.0,
        "p_hpf_ramp": 0.0,
        "sound_vol": 0.25,
        "sample_rate": 44100,
        "sample_size": 8
    }"#;

    let params = SynthParams::from_json(json).unwrap();

    // Expected values from jsfxr
    assert_eq!(params.wave_type, 1);
    assert!((params.env_attack - 0.0).abs() < 0.001);
    assert!((params.env_sustain - 0.001367).abs() < 0.001);
    assert!((params.env_punch - 45.715).abs() < 0.01);
    assert!((params.env_decay - 0.2658).abs() < 0.001);
    assert!((params.freq_base - 1071.0).abs() < 0.1);
    assert!((params.freq_limit - 3.528).abs() < 0.001);
    assert!((params.arp_mod - 1.343).abs() < 0.001);
    assert!((params.arp_speed - 0.04447).abs() < 0.001);

    // println!("Volume:{}", params.volume);

    let playback = Playback::new().unwrap();
    assert!(playback.play(params).is_ok());
}
