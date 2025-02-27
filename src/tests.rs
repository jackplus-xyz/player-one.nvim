use crate::player::Player;
use crate::sound::SoundParams;
use sfxr::Sample;
use std::time::Duration;

#[test]
fn test_player_initialization() {
    let player = Player::new();
    assert!(player.is_ok());
}

#[test]
fn test_basic_sound_playback() {
    let player = Player::new().unwrap();
    let mut sample = Sample::new();
    sample.wave_type = sfxr::WaveType::Square;

    let params = SoundParams::new(sample);
    assert!(player.play(params).is_ok());
    std::thread::sleep(Duration::from_millis(100));
    assert!(player.stop().is_ok());
}

#[test]
fn test_preset_sounds() {
    let player = Player::new().unwrap();
    let presets = vec![
        Sample::pickup(None),
        Sample::laser(None),
        Sample::explosion(None),
        Sample::powerup(None),
        Sample::hit(None),
        Sample::jump(None),
        Sample::blip(None),
    ];

    for sample in presets {
        let params = SoundParams::new(sample);
        assert!(player.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(100));
        assert!(player.stop().is_ok());
    }
}

#[test]
fn test_waveform_types() {
    let player = Player::new().unwrap();
    let wave_types = vec![
        sfxr::WaveType::Square,
        sfxr::WaveType::Triangle,
        sfxr::WaveType::Sine,
        sfxr::WaveType::Noise,
    ];

    for wave_type in wave_types {
        let mut sample = Sample::new();
        sample.wave_type = wave_type;
        let params = SoundParams::new(sample);

        assert!(player.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(50));
        assert!(player.stop().is_ok());
    }
}

#[test]
fn test_concurrent_playback() {
    let player = Player::new().unwrap();

    let mut sample1 = Sample::new();
    sample1.base_freq = 0.5;

    let mut sample2 = Sample::new();
    sample2.base_freq = 0.7;

    assert!(player.play(SoundParams::new(sample1)).is_ok());
    assert!(player.play(SoundParams::new(sample2)).is_ok());
    assert!(player.stop().is_ok());
}

#[test]
fn test_parameter_ranges() {
    let player = Player::new().unwrap();
    let test_cases = vec![
        {
            let mut s = Sample::new();
            s.base_freq = 0.0;
            s
        },
        {
            let mut s = Sample::new();
            s.base_freq = 1.0;
            s
        },
        {
            let mut s = Sample::new();
            s.env_attack = 0.0;
            s
        },
        {
            let mut s = Sample::new();
            s.env_attack = 1.0;
            s
        },
    ];

    for sample in test_cases {
        let params = SoundParams::new(sample);
        assert!(player.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(50));
        assert!(player.stop().is_ok());
    }
}

#[test]
fn test_envelope_parameters() {
    let player = Player::new().unwrap();
    let test_cases = vec![
        {
            let mut s = Sample::new();
            s.env_attack = 0.1;
            s.env_sustain = 0.8;
            s.env_decay = 0.2;
            s
        },
        {
            let mut s = Sample::new();
            s.env_attack = 0.8;
            s.env_sustain = 0.1;
            s.env_decay = 0.1;
            s
        },
    ];

    for sample in test_cases {
        let params = SoundParams::new(sample);
        assert!(player.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(100));
        assert!(player.stop().is_ok());
    }
}

#[test]
fn test_frequency_modulation() {
    let player = Player::new().unwrap();
    let test_cases = vec![
        {
            let mut s = Sample::new();
            s.base_freq = 0.3;
            s.freq_ramp = 0.3;
            s
        },
        {
            let mut s = Sample::new();
            s.base_freq = 0.7;
            s.freq_ramp = -0.3;
            s
        },
        {
            let mut s = Sample::new();
            s.base_freq = 0.5;
            s.vib_strength = 0.5;
            s.vib_speed = 0.5;
            s
        },
    ];

    for sample in test_cases {
        let params = SoundParams::new(sample);
        assert!(player.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(100));
        assert!(player.stop().is_ok());
    }
}

#[test]
fn test_error_handling() {
    let player = Player::new().unwrap();
    assert!(player.stop().is_ok());
    assert!(player.stop().is_ok());
}

#[test]
fn test_json_params() {
    let player = Player::new().unwrap();
    let json_params = r#"{
        "wave_type": 1,
        "p_env_attack": 0,
        "p_env_sustain": 0.024555768060600138,
        "p_env_punch": 0.4571553721133509,
        "p_env_decay": 0.3423639066276736,
        "p_base_freq": 0.5500696633190347,
        "sound_vol": 0.25
    }"#;

    let params = SoundParams::from_json(json_params).expect("Should parse JSON successfully");
    assert!(player.play_and_wait(params).is_ok());

    let invalid_json = r#"{ invalid json }"#;
    assert!(SoundParams::from_json(invalid_json).is_err());

    let incomplete_json = r#"{ "wave_type": 1 }"#;
    let params = SoundParams::from_json(incomplete_json).expect("Should parse JSON successfully");
    assert!(player.play_and_wait(params).is_ok());
}

#[test]
fn test_volume_settings() {
    let player = Player::new().unwrap();

    // Test normal volume values
    let test_volumes = vec![0.0, 0.2, 0.5, 0.8, 1.0];
    for volume in test_volumes {
        let sample = Sample::new();
        let params = SoundParams::new(sample).with_volume(volume);
        assert!(player.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(50));
        assert!(player.stop().is_ok());
    }

    // Test volume from JSON
    let json_with_volume = r#"{
        "wave_type": 0,
        "sound_vol": 0.5
    }"#;
    let params = SoundParams::from_json(json_with_volume).unwrap();
    assert!(player.play(params).is_ok());
    std::thread::sleep(Duration::from_millis(50));
    assert!(player.stop().is_ok());

    // Test edge cases and invalid values
    let edge_cases = vec![
        // Negative volume (should be clamped)
        -1.0,  // Volume above 1.0 (should be clamped)
        1.5,   // Very small volume
        0.001, // Very large volume
        100.0, // Zero volume
        0.0,
    ];

    for volume in edge_cases {
        let sample = Sample::new();
        let params = SoundParams::new(sample).with_volume(volume);
        assert!(player.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(50));
        assert!(player.stop().is_ok());
    }

    // Test JSON with invalid volume values
    let json_cases = vec![
        // Missing volume (should use default)
        r#"{ "wave_type": 0 }"#,
        // Negative volume
        r#"{ "wave_type": 0, "sound_vol": -1.0 }"#,
        // Very large volume
        r#"{ "wave_type": 0, "sound_vol": 100.0 }"#,
    ];

    for json in json_cases {
        let params = SoundParams::from_json(json).unwrap();
        assert!(player.play(params).is_ok());
        std::thread::sleep(Duration::from_millis(50));
        assert!(player.stop().is_ok());
    }
}

#[test]
fn test_append_sound() {
    use crate::player::Player;
    use crate::sound::SoundParams;
    use sfxr::Sample;
    use sfxr::WaveType;
    use std::time::Duration;

    let player = Player::new().unwrap();

    // Create two different sound samples.
    let mut sample1 = Sample::new();
    sample1.wave_type = WaveType::Square;
    let params1 = SoundParams::new(sample1);

    let mut sample2 = Sample::new();
    sample2.wave_type = WaveType::Sine;
    let params2 = SoundParams::new(sample2);

    // Append two sounds sequentially.
    assert!(player.append(params1).is_ok());
    assert!(player.append(params2).is_ok());

    // Give the sounds some time to play.
    std::thread::sleep(Duration::from_millis(200));

    // Stop playback.
    assert!(player.stop().is_ok());
}
