#[cfg(test)]
use crate::{Playback, PlaybackError, SynthParams, WaveType};
use rodio::cpal::traits::{DeviceTrait, HostTrait};
use std::sync::Arc;
use std::thread::sleep;
use std::time::Duration;

#[test]
fn test_playback_initialization() {
    let playback = Playback::new();
    assert!(playback.is_ok());
}

#[test]
fn test_invalid_frequency() {
    let mut params = SynthParams::default();
    params.frequency.base = 1.0; // Too low frequency

    let playback = Playback::new().unwrap();
    let result = playback.play(params);

    assert!(matches!(result, Err(PlaybackError::InvalidParameter(_))));
}

#[test]
fn test_invalid_volume() {
    let mut params = SynthParams::default();
    params.general.volume = 2.0; // Volume > 1.0

    let playback = Playback::new().unwrap();
    let result = playback.play(params);

    assert!(matches!(result, Err(PlaybackError::InvalidParameter(_))));
}

#[test]
fn test_valid_sound_generation() {
    let mut params = SynthParams::default();
    params.frequency.base = 440.0;
    params.general.volume = 0.5;
    params.envelope.attack = 0.1;
    params.envelope.sustain = 0.2;
    params.envelope.decay = 0.3;

    let playback = Playback::new().unwrap();
    let result = playback.play(params);

    assert!(result.is_ok());
}

#[test]
fn test_volume_control() {
    let playback = Playback::new().unwrap();

    // Test valid volume range
    assert!(playback.set_volume(0.5).is_ok());
    assert_eq!(playback.get_volume().unwrap(), 0.5);

    // Test invalid volume
    assert!(matches!(
        playback.set_volume(1.5),
        Err(PlaybackError::InvalidParameter(_))
    ));
}

#[test]
fn test_playback_state() {
    let playback = Arc::new(Playback::new().unwrap());
    let playback_clone = playback.clone();

    // Initial state should be Stopped
    assert!(matches!(
        playback.get_state().unwrap(),
        crate::playback::PlaybackState::Stopped
    ));

    // Start playback
    let mut params = SynthParams::default();
    params.frequency.base = 440.0;
    params.envelope.attack = 0.1;
    params.envelope.sustain = 0.1;
    params.envelope.decay = 0.1;

    std::thread::spawn(move || {
        let _ = playback_clone.play(params);
    });

    // Give it a moment to start
    std::thread::sleep(Duration::from_millis(50));

    // Stop playback
    playback.stop().unwrap();
}

#[test]
fn test_play_c4_to_c5() {
    let playback = Playback::new().unwrap();

    // Frequencies for chromatic scale from C4 to C5
    let frequencies = [
        261.63, // C4
        277.18, // C#4
        293.66, // D4
        311.13, // D#4
        329.63, // E4
        349.23, // F4
        369.99, // F#4
        392.00, // G4
        415.30, // G#4
        440.00, // A4
        466.16, // A#4
        493.88, // B4
        523.25, // C5
    ];

    let mut params = SynthParams::default();
    params.general.volume = 0.5;
    params.envelope.attack = 0.1;
    params.envelope.sustain = 0.1;
    params.envelope.decay = 0.1;
    params.wave_type = WaveType::Sine;

    for &freq in frequencies.iter() {
        params.frequency.base = freq;
        assert!(playback.play(params.clone()).is_ok());
        // Wait for the note to play
        sleep(Duration::from_millis(300));
        playback.stop().unwrap();
        // Small pause between notes
        sleep(Duration::from_millis(100));
    }
}

#[test]
fn test_playback_timeout() {
    use std::time::Instant;

    let start = Instant::now();
    let duration = start.elapsed();

    // Playback::new() should not take more than 1 second
    assert!(
        duration.as_secs() < 1,
        "Playback::new() took too long: {:?}",
        duration
    );
}

#[test]
fn test_quick_start_stop() {
    let playback = Playback::new().unwrap();
    let mut params = SynthParams::default();
    params.frequency.base = 440.0;
    params.general.volume = 0.5;

    // Start and immediately stop
    let play_result = playback.play(params);
    assert!(play_result.is_ok(), "Play failed: {:?}", play_result);

    let stop_result = playback.stop();
    assert!(stop_result.is_ok(), "Stop failed: {:?}", stop_result);
}

#[test]
fn test_multiple_quick_plays() {
    let playback = Playback::new().unwrap();
    let mut params = SynthParams::default();
    params.frequency.base = 440.0;
    params.general.volume = 0.5;

    for _ in 0..3 {
        let play_result = playback.play(params.clone());
        assert!(play_result.is_ok(), "Play failed: {:?}", play_result);

        let stop_result = playback.stop();
        assert!(stop_result.is_ok(), "Stop failed: {:?}", stop_result);
    }
}

#[test]
fn test_concurrent_playback_instances() {
    let playback1 = Playback::new().unwrap();
    let playback2 = Playback::new().unwrap();

    assert!(playback1.get_volume().is_ok());
    assert!(playback2.get_volume().is_ok());
}

#[test]
fn test_audible_output() {
    let playback = Playback::new().unwrap();
    let mut params = SynthParams::default();

    // Set up parameters for a clearly audible sound
    params.frequency.base = 440.0; // A4 note
    params.general.volume = 0.5; // 50% volume
    params.envelope.attack = 0.1;
    params.envelope.sustain = 0.5; // Longer sustain to clearly hear it
    params.envelope.decay = 0.2;
    params.wave_type = WaveType::Sine;

    println!("You should hear a clear A4 note (440Hz) for 1 second...");
    playback.play(params).unwrap();

    // Keep the note playing for 1 second
    std::thread::sleep(Duration::from_secs(1));

    playback.stop().unwrap();
}

#[test]
fn test_volume_levels() {
    let playback = Playback::new().unwrap();
    let mut params = SynthParams::default();
    params.frequency.base = 440.0;
    params.envelope.attack = 0.1;
    params.envelope.sustain = 0.3;
    params.envelope.decay = 0.1;
    params.wave_type = WaveType::Sine;

    // Test different volume levels
    for volume in [0.2, 0.5, 0.8].iter() {
        println!("Playing at {}% volume...", volume * 100.0);
        params.general.volume = *volume;
        playback.play(params.clone()).unwrap();
        std::thread::sleep(Duration::from_millis(500));
        playback.stop().unwrap();
        std::thread::sleep(Duration::from_millis(200));
    }
}

#[test]
fn test_audio_device_info() {
    let host = rodio::cpal::default_host();

    // Test if we can get the default audio device
    let device = host.default_output_device();
    assert!(device.is_some(), "No default audio device found!");

    if let Some(device) = device {
        println!("Default audio device name: {:?}", device.name());
        println!("Audio device found and accessible");
    }
}

#[test]
fn test_synthesizer_output_values() {
    use crate::synthesizer::{Synthesizer, SAMPLE_RATE};
    use rodio::Source;

    let mut params = SynthParams::default();
    params.frequency.base = 440.0; // A4 note
    params.general.volume = 1.0;
    params.wave_type = WaveType::Sine;
    params.envelope.attack = 0.01; // Shorter attack to get sound immediately
    params.envelope.sustain = 0.1;
    params.envelope.decay = 0.1;

    println!("Initial parameters:");
    println!("  Frequency: {} Hz", params.frequency.base);
    println!("  Volume: {}", params.general.volume);
    println!("  Wave type: {:?}", params.wave_type);
    println!("  Attack: {}s", params.envelope.attack);
    println!("  Sustain: {}s", params.envelope.sustain);
    println!("  Decay: {}s", params.envelope.decay);
    println!("  Sample rate: {}", params.general.sample_rate);

    assert_eq!(
        params.general.sample_rate, SAMPLE_RATE,
        "Sample rate mismatch"
    );

    let mut synth = Synthesizer::new(params);

    // Get synth properties before consuming it
    let sample_rate = synth.sample_rate();
    let channels = synth.channels();
    let duration = synth.total_duration();

    // Debug the first few samples with intermediate values
    println!("\nFirst 10 samples generation:");
    for i in 0..10 {
        if let Some(sample) = synth.next() {
            println!("Sample {}: value={:.6}", i, sample);
        }
    }

    // Reset synthesizer for full test
    let mut synth = Synthesizer::new(params);
    let samples: Vec<f32> = synth.take(1000).collect();

    // Ensure we're getting samples
    assert!(!samples.is_empty(), "No samples generated!");

    // Check if we have any non-zero samples (audio output)
    let non_zero_samples = samples.iter().filter(|&&x| x.abs() > 1e-6).count();

    // Print detailed debug info
    println!("\nSample statistics:");
    println!("First 10 samples: {:?}", &samples[..10.min(samples.len())]);
    println!("Non-zero samples: {}/{}", non_zero_samples, samples.len());
    println!("Sample rate: {}", sample_rate);
    println!("Channels: {}", channels);
    println!("Duration: {:?}", duration);

    assert!(
        non_zero_samples > 0,
        "All samples are zero! First 10 samples: {:?}",
        &samples[..10.min(samples.len())]
    );
}

#[test]
fn test_sink_playback_state() {
    let playback = Playback::new().unwrap();
    let mut params = SynthParams::default();
    params.frequency.base = 440.0;
    params.general.volume = 1.0;
    params.envelope.attack = 0.1;
    params.envelope.sustain = 0.3;
    params.envelope.decay = 0.1;

    // Test initial state
    assert!(
        playback.is_empty().unwrap(),
        "Sink should be empty initially"
    );

    // Play sound
    playback.play(params).unwrap();

    // Check if sink is no longer empty
    assert!(
        !playback.is_empty().unwrap(),
        "Sink should not be empty during playback"
    );

    // Print playback state
    println!("Playback state: {:?}", playback.get_state().unwrap());

    std::thread::sleep(std::time::Duration::from_millis(500));

    // Stop and check final state
    playback.stop().unwrap();
    assert!(
        playback.is_empty().unwrap(),
        "Sink should be empty after stopping"
    );
}

#[test]
fn test_extended_playback() {
    let playback = Playback::new().unwrap();
    let mut params = SynthParams::default();

    // Set up a long, loud sound that should be clearly audible
    params.frequency.base = 440.0;
    params.general.volume = 1.0;
    params.wave_type = WaveType::Square; // Square wave is usually more noticeable
    params.envelope.attack = 0.1;
    params.envelope.sustain = 1.0; // Longer sustain
    params.envelope.decay = 0.5;

    println!("Playing a loud 440Hz square wave for 2 seconds...");
    println!("Please confirm if you can hear the sound.");

    playback.play(params).unwrap();

    // Print periodic state updates
    for i in 0..4 {
        std::thread::sleep(std::time::Duration::from_millis(500));
        println!(
            "Playback state at {}ms: {:?}, Sink empty: {}",
            i * 500,
            playback.get_state().unwrap(),
            playback.is_empty().unwrap()
        );
    }

    playback.stop().unwrap();
}
