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

    // Create two different sounds
    let mut sample1 = Sample::new();
    sample1.base_freq = 0.5; // Different frequency

    let mut sample2 = Sample::new();
    sample2.base_freq = 0.7; // Different frequency

    // Play first sound
    assert!(player.play(SoundParams::new(sample1)).is_ok());

    // Play second sound immediately after
    assert!(player.play(SoundParams::new(sample2)).is_ok());

    // Stop playback
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
            // Fast attack, long sustain
            let mut s = Sample::new();
            s.env_attack = 0.1;
            s.env_sustain = 0.8;
            s.env_decay = 0.2;
            s
        },
        {
            // Long attack, short sustain
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
            // Frequency slide up
            let mut s = Sample::new();
            s.base_freq = 0.3;
            s.freq_ramp = 0.3;
            s
        },
        {
            // Frequency slide down
            let mut s = Sample::new();
            s.base_freq = 0.7;
            s.freq_ramp = -0.3;
            s
        },
        {
            // With vibrato
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

    // Test stop without playing
    assert!(player.stop().is_ok());

    // Test multiple stops
    assert!(player.stop().is_ok());
    assert!(player.stop().is_ok());
}

#[test]
fn test_json_params() {
    let player = Player::new().unwrap();
    let json_params = r#"{
  "oldParams": true,
  "wave_type": 1,
  "p_env_attack": 0,
  "p_env_sustain": 0.024555768060600138,
  "p_env_punch": 0.4571553721133509,
  "p_env_decay": 0.3423639066276736,
  "p_base_freq": 0.5500696633190347,
  "p_freq_limit": 0,
  "p_freq_ramp": 0,
  "p_freq_dramp": 0,
  "p_vib_strength": 0,
  "p_vib_speed": 0,
  "p_arp_mod": 0.5329522492796008,
  "p_arp_speed": 0.689393158112304,
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

    // let sample = SoundParams::from_json(json_params).expect("Should parse JSON successfully");
    // let sound_params = SoundParams::new(sample);
    // assert!(
    //     player.play(sound_params).is_ok(),
    //     "Should play sound successfully"
    // );

    let sample = SoundParams::from_json(json_params).expect("Should parse JSON successfully");

    // Verify the parsed values match the input JSON
    // assert_eq!(sample.wave_type, WaveType::Sawtooth); // wave_type 1 should be Sawtooth
    assert_eq!(sample.env_attack, 0.0);
    assert!((sample.env_sustain - 0.024555768060600138).abs() < f32::EPSILON);
    assert!((sample.env_punch - 0.4571553721133509).abs() < f32::EPSILON);
    assert!((sample.env_decay - 0.3423639066276736).abs() < f32::EPSILON);
    assert!((sample.base_freq - 0.5500696633190347).abs() < f64::EPSILON);
    assert_eq!(sample.freq_limit, 0.0);
    assert_eq!(sample.freq_ramp, 0.0);
    assert_eq!(sample.freq_dramp, 0.0);
    assert_eq!(sample.vib_strength, 0.0);
    assert_eq!(sample.vib_speed, 0.0);
    assert!((sample.arp_mod - 0.5329522492796008).abs() < f64::EPSILON);
    assert!((sample.arp_speed - 0.689393158112304).abs() < f32::EPSILON);
    assert_eq!(sample.duty, 0.0);
    assert_eq!(sample.duty_ramp, 0.0);
    assert_eq!(sample.repeat_speed, 0.0);
    assert_eq!(sample.pha_offset, 0.0);
    assert_eq!(sample.pha_ramp, 0.0);
    assert_eq!(sample.lpf_freq, 1.0);
    assert_eq!(sample.lpf_ramp, 0.0);
    assert_eq!(sample.lpf_resonance, 0.0);
    assert_eq!(sample.hpf_freq, 0.0);
    assert_eq!(sample.hpf_ramp, 0.0);

    let params = SoundParams::new(sample);
    player.play_async(params).expect("Failed to play sound");

    let invalid_json = r#"{ invalid json }"#;
    assert!(SoundParams::from_json(invalid_json).is_err());

    let incomplete_json = r#"{ "wave_type": 1 }"#;
    assert!(SoundParams::from_json(incomplete_json).is_err());
}
