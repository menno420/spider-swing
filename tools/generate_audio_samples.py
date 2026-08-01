#!/usr/bin/env python3
"""Generate Spider Swing's original, deterministic gameplay SFX samples.

The runtime files are intentionally small mono PCM WAVs for Android.  Every
sample is synthesized from elementary waveforms and seeded noise in this file;
no recorded or third-party source material is used.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import struct
import tempfile
import wave
from dataclasses import dataclass
from pathlib import Path
from typing import Callable


SAMPLE_RATE = 44_100
CHANNELS = 1
SAMPLE_WIDTH_BYTES = 2
MANIFEST_NAME = "audio-sample-manifest.json"
OUTPUT_DIR = Path("assets/runtime/audio")
GENERATOR_DATE = "2026-08-01"


@dataclass(frozen=True)
class ClipDefinition:
    filename: str
    event: str
    target_peak_dbfs: float
    loop: bool
    builder: Callable[[], list[float]]


def _frames(duration: float) -> int:
    return max(1, round(duration * SAMPLE_RATE))


def _silence(duration: float) -> list[float]:
    return [0.0] * _frames(duration)


def _mix(*parts: tuple[list[float], float, float]) -> list[float]:
    """Mix (samples, gain, offset_seconds) tuples."""
    length = 1
    for samples, _gain, offset in parts:
        length = max(length, _frames(offset) + len(samples))
    result = [0.0] * length
    for samples, gain, offset in parts:
        start = _frames(offset) if offset > 0.0 else 0
        for index, value in enumerate(samples):
            result[start + index] += value * gain
    return result


def _decay_envelope(
    samples: list[float],
    attack: float = 0.004,
    release: float = 0.035,
    decay_power: float = 1.6,
) -> list[float]:
    length = len(samples)
    attack_frames = max(1, _frames(attack))
    release_frames = max(1, _frames(release))
    result: list[float] = []
    for index, sample in enumerate(samples):
        attack_gain = min(1.0, (index + 1) / attack_frames)
        progress = index / max(1, length - 1)
        decay_gain = max(0.0, 1.0 - progress) ** decay_power
        release_gain = min(1.0, (length - index) / release_frames)
        result.append(sample * attack_gain * decay_gain * release_gain)
    return result


def _shaped_envelope(
    samples: list[float],
    points: tuple[tuple[float, float], ...],
) -> list[float]:
    """Apply a piecewise-linear envelope with normalized time/value points."""
    result: list[float] = []
    segment = 0
    for index, sample in enumerate(samples):
        progress = index / max(1, len(samples) - 1)
        while segment < len(points) - 2 and progress > points[segment + 1][0]:
            segment += 1
        left_t, left_value = points[segment]
        right_t, right_value = points[segment + 1]
        span = max(1e-9, right_t - left_t)
        local = max(0.0, min(1.0, (progress - left_t) / span))
        smooth = local * local * (3.0 - 2.0 * local)
        gain = left_value + (right_value - left_value) * smooth
        result.append(sample * gain)
    return result


def _chirp(
    duration: float,
    start_hz: float,
    end_hz: float,
    phase: float = 0.0,
    harmonic: float = 0.0,
) -> list[float]:
    result: list[float] = []
    angle = phase
    count = _frames(duration)
    for index in range(count):
        progress = index / max(1, count - 1)
        frequency = start_hz * ((end_hz / start_hz) ** progress)
        angle += math.tau * frequency / SAMPLE_RATE
        value = math.sin(angle)
        if harmonic:
            value += math.sin(angle * 2.0 + 0.37) * harmonic
        result.append(value)
    return result


def _tone(
    duration: float,
    frequency: float,
    phase: float = 0.0,
    harmonic: float = 0.0,
) -> list[float]:
    return _chirp(duration, frequency, frequency, phase, harmonic)


def _seeded_noise(duration: float, seed: int) -> list[float]:
    generator = random.Random(seed)
    return [generator.uniform(-1.0, 1.0) for _ in range(_frames(duration))]


def _low_pass(samples: list[float], cutoff_hz: float) -> list[float]:
    dt = 1.0 / SAMPLE_RATE
    rc = 1.0 / (math.tau * cutoff_hz)
    alpha = dt / (rc + dt)
    output: list[float] = []
    previous = 0.0
    for sample in samples:
        previous += alpha * (sample - previous)
        output.append(previous)
    return output


def _high_pass(samples: list[float], cutoff_hz: float) -> list[float]:
    dt = 1.0 / SAMPLE_RATE
    rc = 1.0 / (math.tau * cutoff_hz)
    alpha = rc / (rc + dt)
    output: list[float] = []
    previous_input = 0.0
    previous_output = 0.0
    for sample in samples:
        value = alpha * (previous_output + sample - previous_input)
        output.append(value)
        previous_input = sample
        previous_output = value
    return output


def _band_pass(
    samples: list[float],
    low_cut_hz: float,
    high_cut_hz: float,
) -> list[float]:
    return _low_pass(_high_pass(samples, low_cut_hz), high_cut_hz)


def _pluck(
    duration: float,
    frequency: float,
    seed: int,
    damping: float = 0.996,
) -> list[float]:
    """A small Karplus-Strong string: silk-like, pitched, and fully original."""
    period = max(2, round(SAMPLE_RATE / frequency))
    generator = random.Random(seed)
    ring = [generator.uniform(-1.0, 1.0) for _ in range(period)]
    output: list[float] = []
    cursor = 0
    for _ in range(_frames(duration)):
        current = ring[cursor]
        following = ring[(cursor + 1) % period]
        ring[cursor] = (current + following) * 0.5 * damping
        output.append(current)
        cursor = (cursor + 1) % period
    return output


def _pulse_train(
    duration: float,
    frequency: float,
    width: float = 0.12,
) -> list[float]:
    output: list[float] = []
    for index in range(_frames(duration)):
        phase = (index * frequency / SAMPLE_RATE) % 1.0
        output.append(1.0 if phase < width else -0.18)
    return output


def _delay(
    samples: list[float],
    delay_seconds: float,
    gain: float,
    repeats: int = 1,
) -> list[float]:
    delay_frames = _frames(delay_seconds)
    result = samples[:] + [0.0] * (delay_frames * repeats)
    for repeat in range(1, repeats + 1):
        offset = delay_frames * repeat
        repeat_gain = gain**repeat
        for index, value in enumerate(samples):
            result[offset + index] += value * repeat_gain
    return result


def _finish(
    samples: list[float],
    target_peak_dbfs: float,
    edge_fade: bool = True,
) -> list[float]:
    mean = sum(samples) / max(1, len(samples))
    centered = [value - mean for value in samples]
    # A little saturation joins layers without hard clipping.
    saturated = [math.tanh(value * 1.18) for value in centered]
    if edge_fade:
        fade_frames = min(_frames(0.003), max(1, len(saturated) // 6))
        for index in range(fade_frames):
            gain = (index + 1) / fade_frames
            saturated[index] *= gain
            saturated[-index - 1] *= gain
    peak = max((abs(value) for value in saturated), default=1.0)
    target = 10.0 ** (target_peak_dbfs / 20.0)
    scale = target / max(peak, 1e-9)
    return [max(-1.0, min(1.0, value * scale)) for value in saturated]


def _web_attach(variant: int) -> list[float]:
    pitch = [720.0, 790.0, 660.0][variant]
    whip = _decay_envelope(
        _band_pass(_seeded_noise(0.105, 1100 + variant), 850.0, 8_500.0),
        attack=0.001,
        release=0.018,
        decay_power=0.72,
    )
    sweep = _decay_envelope(
        _chirp(0.12, 3_700.0 + variant * 180.0, 980.0, harmonic=0.18),
        attack=0.001,
        release=0.025,
        decay_power=0.9,
    )
    knot = _decay_envelope(
        _pluck(0.14, pitch, 2100 + variant, 0.994),
        attack=0.001,
        release=0.035,
        decay_power=1.25,
    )
    return _mix((whip, 0.42, 0.0), (sweep, 0.34, 0.0), (knot, 0.72, 0.068))


def _web_release(variant: int) -> list[float]:
    pitch = [840.0, 930.0][variant]
    snap = _decay_envelope(
        _high_pass(_seeded_noise(0.07, 3100 + variant), 1_900.0),
        attack=0.001,
        release=0.014,
        decay_power=0.8,
    )
    silk = _decay_envelope(
        _chirp(0.13, pitch * 1.65, pitch * 0.62, harmonic=0.22),
        attack=0.001,
        release=0.026,
        decay_power=1.1,
    )
    return _mix((snap, 0.38, 0.0), (silk, 0.7, 0.004))


def _reel_start() -> list[float]:
    spool = _decay_envelope(
        _chirp(0.16, 128.0, 510.0, harmonic=0.32),
        attack=0.012,
        release=0.045,
        decay_power=0.65,
    )
    fibre = _decay_envelope(
        _band_pass(_seeded_noise(0.13, 4101), 1_200.0, 5_800.0),
        attack=0.003,
        release=0.03,
        decay_power=1.0,
    )
    return _mix((spool, 0.78, 0.0), (fibre, 0.28, 0.012))


def _reel_loop() -> list[float]:
    # 0.5 s and integer-Hz components give a mathematically seamless loop.
    duration = 0.5
    output: list[float] = []
    for index in range(_frames(duration)):
        time = index / SAMPLE_RATE
        modulation = math.sin(math.tau * 8.0 * time)
        phase = math.tau * 96.0 * time + modulation * 0.18
        value = (
            math.sin(phase) * 0.62
            + math.sin(phase * 2.0 + 0.31) * 0.24
            + math.sin(phase * 4.0 + 0.73) * 0.08
        )
        breath = 0.82 + 0.18 * math.sin(math.tau * 4.0 * time - 0.4)
        output.append(value * breath)
    return output


def _reel_empty() -> list[float]:
    first = _decay_envelope(_pluck(0.12, 290.0, 4201, 0.989), decay_power=1.5)
    second = _decay_envelope(_pluck(0.1, 210.0, 4202, 0.987), decay_power=1.7)
    knock = _decay_envelope(
        _low_pass(_seeded_noise(0.08, 4203), 1_400.0),
        decay_power=2.2,
    )
    return _mix((first, 0.72, 0.0), (second, 0.6, 0.07), (knock, 0.28, 0.012))


def _burst(variant: int) -> list[float]:
    airy = _shaped_envelope(
        _band_pass(_seeded_noise(0.235, 5100 + variant), 240.0, 6_200.0),
        ((0.0, 0.0), (0.28, 0.9), (0.72, 0.55), (1.0, 0.0)),
    )
    drive = _shaped_envelope(
        _chirp(0.23, 150.0 + variant * 18.0, 980.0 + variant * 90.0,
               harmonic=0.26),
        ((0.0, 0.0), (0.12, 0.55), (0.58, 1.0), (1.0, 0.0)),
    )
    catch = _decay_envelope(
        _pluck(0.13, 610.0 + variant * 70.0, 5200 + variant, 0.993),
        decay_power=1.3,
    )
    return _mix((airy, 0.34, 0.0), (drive, 0.68, 0.0), (catch, 0.46, 0.125))


def _dive(variant: int) -> list[float]:
    rush = _shaped_envelope(
        _band_pass(_seeded_noise(0.23, 6100 + variant), 180.0, 5_100.0),
        ((0.0, 0.0), (0.16, 0.8), (0.65, 0.56), (1.0, 0.0)),
    )
    fall = _shaped_envelope(
        _chirp(0.22, 1_050.0 + variant * 90.0, 120.0 + variant * 12.0,
               harmonic=0.22),
        ((0.0, 0.0), (0.08, 0.75), (0.62, 1.0), (1.0, 0.0)),
    )
    return _mix((rush, 0.38, 0.0), (fall, 0.73, 0.0))


def _fly_catch(variant: int) -> list[float]:
    base = [1_420.0, 1_570.0, 1_320.0][variant]
    first = _decay_envelope(
        _chirp(0.105, base, base * 1.72, harmonic=0.14),
        attack=0.002,
        release=0.018,
        decay_power=0.95,
    )
    second = _decay_envelope(
        _tone(0.085, base * 2.05, harmonic=0.12),
        attack=0.001,
        release=0.02,
        decay_power=1.25,
    )
    wing = _decay_envelope(
        _high_pass(_seeded_noise(0.075, 7100 + variant), 2_900.0),
        attack=0.001,
        release=0.012,
        decay_power=1.2,
    )
    return _mix((first, 0.62, 0.0), (second, 0.46, 0.045), (wing, 0.18, 0.0))


def _invalid_target() -> list[float]:
    knock = _decay_envelope(
        _low_pass(_seeded_noise(0.085, 8101), 980.0),
        attack=0.001,
        release=0.018,
        decay_power=2.0,
    )
    tone = _decay_envelope(_tone(0.09, 180.0), decay_power=2.4)
    return _mix((knock, 0.55, 0.0), (tone, 0.48, 0.0))


def _rescue_silk() -> list[float]:
    catch = _shaped_envelope(
        _chirp(0.34, 180.0, 880.0, harmonic=0.18),
        ((0.0, 0.0), (0.18, 0.85), (0.64, 0.72), (1.0, 0.0)),
    )
    high = _decay_envelope(_pluck(0.24, 660.0, 9101, 0.996), decay_power=0.85)
    shimmer = _delay(
        _decay_envelope(_tone(0.13, 1_320.0), decay_power=1.25),
        0.065,
        0.38,
        2,
    )
    return _mix((catch, 0.62, 0.0), (high, 0.5, 0.08), (shimmer, 0.28, 0.11))


def _death_impact() -> list[float]:
    body = _decay_envelope(
        _low_pass(_seeded_noise(0.36, 9201), 1_250.0),
        attack=0.001,
        release=0.055,
        decay_power=1.65,
    )
    thump = _decay_envelope(
        _chirp(0.38, 130.0, 48.0, harmonic=0.28),
        attack=0.001,
        release=0.065,
        decay_power=1.35,
    )
    crack = _decay_envelope(
        _band_pass(_seeded_noise(0.09, 9202), 900.0, 4_100.0),
        attack=0.001,
        release=0.02,
        decay_power=1.2,
    )
    return _mix((body, 0.52, 0.0), (thump, 0.78, 0.0), (crack, 0.33, 0.018))


def _boost_catch() -> list[float]:
    rise = _shaped_envelope(
        _chirp(0.3, 330.0, 1_780.0, harmonic=0.2),
        ((0.0, 0.0), (0.12, 0.65), (0.72, 0.9), (1.0, 0.0)),
    )
    sparkle = _delay(
        _decay_envelope(_pluck(0.12, 1_260.0, 9301, 0.995), decay_power=1.0),
        0.055,
        0.42,
        2,
    )
    return _mix((rise, 0.64, 0.0), (sparkle, 0.42, 0.09))


def _surface_bounce() -> list[float]:
    body = _decay_envelope(
        _chirp(0.24, 170.0, 520.0, harmonic=0.3),
        attack=0.002,
        release=0.05,
        decay_power=1.05,
    )
    shell = _decay_envelope(
        _pluck(0.15, 440.0, 9401, 0.991),
        attack=0.001,
        release=0.03,
        decay_power=1.4,
    )
    return _mix((body, 0.75, 0.0), (shell, 0.55, 0.018))


def _mist_echo() -> list[float]:
    call = _shaped_envelope(
        _chirp(0.18, 470.0, 310.0, harmonic=0.12),
        ((0.0, 0.0), (0.2, 0.75), (0.72, 0.45), (1.0, 0.0)),
    )
    air = _decay_envelope(
        _band_pass(_seeded_noise(0.18, 10101), 300.0, 2_200.0),
        attack=0.02,
        release=0.06,
        decay_power=0.8,
    )
    return _delay(_mix((call, 0.68, 0.0), (air, 0.22, 0.0)), 0.085, 0.4, 2)


def _glass_phase() -> list[float]:
    chime = _delay(
        _decay_envelope(
            _mix(
                (_tone(0.17, 1_210.0), 0.7, 0.0),
                (_tone(0.17, 1_906.0, 0.4), 0.36, 0.0),
                (_tone(0.17, 2_844.0, 0.8), 0.18, 0.0),
            ),
            attack=0.001,
            release=0.035,
            decay_power=1.35,
        ),
        0.052,
        0.3,
        1,
    )
    return chime


def _rotten_crack() -> list[float]:
    wood = _decay_envelope(
        _band_pass(_seeded_noise(0.2, 10301), 120.0, 2_600.0),
        attack=0.001,
        release=0.035,
        decay_power=1.3,
    )
    splinter = _decay_envelope(
        _pulse_train(0.075, 86.0, 0.08),
        attack=0.001,
        release=0.02,
        decay_power=1.5,
    )
    low = _decay_envelope(_chirp(0.2, 190.0, 66.0), decay_power=1.5)
    return _mix((wood, 0.55, 0.0), (splinter, 0.3, 0.012), (low, 0.6, 0.0))


def _storm_gust() -> list[float]:
    wind = _shaped_envelope(
        _band_pass(_seeded_noise(0.32, 10401), 90.0, 2_100.0),
        ((0.0, 0.0), (0.35, 0.4), (0.78, 1.0), (1.0, 0.0)),
    )
    rise = _shaped_envelope(
        _chirp(0.3, 105.0, 360.0, harmonic=0.18),
        ((0.0, 0.0), (0.22, 0.35), (0.78, 0.82), (1.0, 0.0)),
    )
    return _mix((wind, 0.55, 0.0), (rise, 0.52, 0.015))


def _storm_charge() -> list[float]:
    rise = _shaped_envelope(
        _chirp(0.27, 420.0, 1_680.0, harmonic=0.18),
        ((0.0, 0.0), (0.12, 0.4), (0.82, 1.0), (1.0, 0.0)),
    )
    static = _shaped_envelope(
        _high_pass(_seeded_noise(0.25, 10501), 2_000.0),
        ((0.0, 0.0), (0.42, 0.22), (0.85, 0.8), (1.0, 0.0)),
    )
    return _mix((rise, 0.64, 0.0), (static, 0.18, 0.02))


def _definitions() -> tuple[ClipDefinition, ...]:
    return (
        ClipDefinition("web-attach-01.wav", "ATTACHED", -4.0, False,
                       lambda: _web_attach(0)),
        ClipDefinition("web-attach-02.wav", "ATTACHED", -4.0, False,
                       lambda: _web_attach(1)),
        ClipDefinition("web-attach-03.wav", "ATTACHED", -4.0, False,
                       lambda: _web_attach(2)),
        ClipDefinition("web-release-01.wav", "RELEASED", -5.0, False,
                       lambda: _web_release(0)),
        ClipDefinition("web-release-02.wav", "RELEASED", -5.0, False,
                       lambda: _web_release(1)),
        ClipDefinition("reel-start.wav", "REEL_STARTED", -5.0, False,
                       _reel_start),
        ClipDefinition("reel-loop.wav", "REEL_ACTIVE_LOOP", -12.0, True,
                       _reel_loop),
        ClipDefinition("reel-empty.wav", "REEL_EMPTY", -6.0, False,
                       _reel_empty),
        ClipDefinition("burst-01.wav", "BURST_STARTED", -3.5, False,
                       lambda: _burst(0)),
        ClipDefinition("burst-02.wav", "BURST_STARTED", -3.5, False,
                       lambda: _burst(1)),
        ClipDefinition("dive-01.wav", "DIVE_STARTED", -4.0, False,
                       lambda: _dive(0)),
        ClipDefinition("dive-02.wav", "DIVE_STARTED", -4.0, False,
                       lambda: _dive(1)),
        ClipDefinition("fly-catch-01.wav", "FLY_COLLECTED", -5.0, False,
                       lambda: _fly_catch(0)),
        ClipDefinition("fly-catch-02.wav", "FLY_COLLECTED", -5.0, False,
                       lambda: _fly_catch(1)),
        ClipDefinition("fly-catch-03.wav", "FLY_COLLECTED", -5.0, False,
                       lambda: _fly_catch(2)),
        ClipDefinition("invalid-target.wav", "INVALID_OR_UNAVAILABLE", -9.0,
                       False, _invalid_target),
        ClipDefinition("rescue-silk.wav", "RESCUE_USED", -3.5, False,
                       _rescue_silk),
        ClipDefinition("death-impact.wav", "DEATH_REQUESTED", -3.0, False,
                       _death_impact),
        ClipDefinition("boost-catch.wav", "BOOST_COLLECTED", -4.0, False,
                       _boost_catch),
        ClipDefinition("surface-bounce.wav", "SURFACE_BOUNCED", -4.0, False,
                       _surface_bounce),
        ClipDefinition("mist-echo.wav", "HAZARD_CUE:mist_echo", -8.0, False,
                       _mist_echo),
        ClipDefinition("glass-phase.wav", "HAZARD_CUE:glass_phase", -7.0,
                       False, _glass_phase),
        ClipDefinition("rotten-crack.wav", "HAZARD_CUE:rotten_crack", -5.5,
                       False, _rotten_crack),
        ClipDefinition("storm-gust.wav", "HAZARD_CUE:storm_gust", -7.0,
                       False, _storm_gust),
        ClipDefinition("storm-charge.wav", "HAZARD_CUE:storm_charge", -6.0,
                       False, _storm_charge),
    )


def _pcm_bytes(samples: list[float]) -> bytes:
    values = [round(max(-1.0, min(1.0, value)) * 32_767.0) for value in samples]
    return struct.pack("<%dh" % len(values), *values)


def _write_wav(path: Path, samples: list[float]) -> bytes:
    path.parent.mkdir(parents=True, exist_ok=True)
    pcm = _pcm_bytes(samples)
    with wave.open(str(path), "wb") as output:
        output.setnchannels(CHANNELS)
        output.setsampwidth(SAMPLE_WIDTH_BYTES)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(pcm)
    return path.read_bytes()


def _metrics(samples: list[float]) -> tuple[float, float]:
    peak = max((abs(value) for value in samples), default=0.0)
    rms = math.sqrt(sum(value * value for value in samples) / max(1, len(samples)))
    peak_dbfs = 20.0 * math.log10(max(peak, 1e-12))
    rms_dbfs = 20.0 * math.log10(max(rms, 1e-12))
    return peak_dbfs, rms_dbfs


def build(output_dir: Path) -> dict[str, object]:
    assets: list[dict[str, object]] = []
    for definition in _definitions():
        samples = _finish(
            definition.builder(),
            definition.target_peak_dbfs,
            edge_fade=not definition.loop,
        )
        path = output_dir / definition.filename
        data = _write_wav(path, samples)
        peak_dbfs, rms_dbfs = _metrics(samples)
        maximum_internal_step = max(
            (abs(samples[index] - samples[index - 1])
             for index in range(1, len(samples))),
            default=0.0,
        )
        loop_seam_ratio = (
            abs(samples[0] - samples[-1]) / max(maximum_internal_step, 1e-12)
            if definition.loop
            else None
        )
        assets.append({
            "file": definition.filename,
            "event": definition.event,
            "duration_seconds": round(len(samples) / SAMPLE_RATE, 4),
            "sample_rate_hz": SAMPLE_RATE,
            "channels": CHANNELS,
            "bits_per_sample": SAMPLE_WIDTH_BYTES * 8,
            "peak_dbfs": round(peak_dbfs, 2),
            "rms_dbfs": round(rms_dbfs, 2),
            "loop": definition.loop,
            "loop_seam_ratio": (
                round(loop_seam_ratio, 3) if loop_seam_ratio is not None else None
            ),
            "sha256": hashlib.sha256(data).hexdigest(),
        })
    generator_hash = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    manifest: dict[str, object] = {
        "schema_version": 1,
        "generated_on": GENERATOR_DATE,
        "generator": "tools/generate_audio_samples.py",
        "generator_sha256": generator_hash,
        "source_policy": (
            "Original procedural synthesis only; no recorded, sampled, or "
            "third-party source material."
        ),
        "runtime_format": "PCM WAV · mono · 44.1 kHz · 16-bit",
        "assets": assets,
    }
    manifest_path = output_dir / MANIFEST_NAME
    manifest_path.write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    return manifest


def _check(committed_dir: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="spider-sfx-") as temp:
        generated_dir = Path(temp)
        manifest = build(generated_dir)
        expected = {str(asset["file"]) for asset in manifest["assets"]}
        expected.add(MANIFEST_NAME)
        actual = {
            path.name
            for path in committed_dir.iterdir()
            if path.is_file() and (path.suffix == ".wav" or path.name == MANIFEST_NAME)
        }
        failures: list[str] = []
        if expected != actual:
            failures.append(
                "asset set differs: missing=%s extra=%s" % (
                    sorted(expected - actual),
                    sorted(actual - expected),
                )
            )
        for filename in sorted(expected & actual):
            generated = (generated_dir / filename).read_bytes()
            committed = (committed_dir / filename).read_bytes()
            if generated != committed:
                failures.append("generated bytes differ: %s" % filename)
        if failures:
            for failure in failures:
                print("audio-samples: FAIL — %s" % failure)
            return 1
        print("audio-samples: PASS — %d deterministic WAVs + manifest" % (
            len(expected) - 1,
        ))
        return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="regenerate in a temporary directory and compare exact bytes",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=OUTPUT_DIR,
        help="runtime output directory (default: %(default)s)",
    )
    args = parser.parse_args()
    if args.check:
        return _check(args.output_dir)
    manifest = build(args.output_dir)
    print("audio-samples: wrote %d deterministic WAVs to %s" % (
        len(manifest["assets"]),
        args.output_dir,
    ))
    for asset in manifest["assets"]:
        print(
            "  %-24s %5.3fs  peak %6.2f dBFS  rms %6.2f dBFS" % (
                asset["file"],
                asset["duration_seconds"],
                asset["peak_dbfs"],
                asset["rms_dbfs"],
            )
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
