import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Generates the coin sound effect: a handful of coins landing on top of
/// each other, the way spending money should sound.
///
/// Run with:
///   dart run tool/audio/generate_coin_sfx.dart
///
/// A coin does not ring on a musical harmonic series - it is a small
/// metal disc, so its partials are inharmonic and decay fast. Each hit
/// here is a few detuned high partials with a very short attack and a
/// tight exponential decay, over a soft low "landing" thud that gives
/// the pile some weight. Six of those, unevenly spaced and falling in
/// level, read as a cascade of coins rather than one beep.
///
/// Everything is deterministic: the same command always writes the same
/// bytes, so the asset can be regenerated and reviewed like source.
const _sampleRate = 44100;
const _output = 'assets/audio/coin.wav';

/// One coin landing: [at] seconds into the clip, ringing around [freq]
/// Hz, at [gain].
class _Coin {
  const _Coin(this.at, this.freq, this.gain, this.decay);
  final double at;
  final double freq;
  final double gain;
  final double decay;
}

/// Struck-metal partials: deliberately not whole-number multiples, which
/// is what makes it read as metal instead of a musical note.
const _partials = [1.0, 1.732, 2.413, 3.169, 4.217];
const _partialGains = [1.0, 0.62, 0.44, 0.28, 0.16];

const _coins = [
  _Coin(0.000, 2640, 1.00, 0.085),
  _Coin(0.052, 3180, 0.82, 0.070),
  _Coin(0.104, 2280, 0.88, 0.090),
  _Coin(0.171, 3520, 0.70, 0.062),
  _Coin(0.238, 2860, 0.64, 0.072),
  _Coin(0.312, 3960, 0.52, 0.055),
];

void main() {
  const duration = 0.62;
  final sampleCount = (duration * _sampleRate).round();
  final samples = Float64List(sampleCount);

  // A fixed seed keeps the noise transients identical run to run.
  final random = math.Random(20240908);

  for (final coin in _coins) {
    final start = (coin.at * _sampleRate).round();
    for (var i = start; i < sampleCount; i++) {
      final t = (i - start) / _sampleRate;
      final envelope = math.exp(-t / coin.decay);
      if (envelope < 0.0005) break;

      var value = 0.0;
      for (var p = 0; p < _partials.length; p++) {
        // A touch of detune per partial stops the hits sounding cloned.
        final detune = 1 + (p * 0.0021) - 0.0013;
        value += _partialGains[p] * math.sin(2 * math.pi * coin.freq * _partials[p] * detune * t);
      }
      value /= _partialGains.reduce((a, b) => a + b);

      // The 2ms scrape of metal on metal at the moment of contact.
      if (t < 0.002) {
        value += (random.nextDouble() * 2 - 1) * 0.55 * (1 - t / 0.002);
      }
      // Low thud: the coin actually landing on something.
      value += 0.22 * math.sin(2 * math.pi * 196 * t) * math.exp(-t / 0.028);

      samples[i] += value * envelope * coin.gain;
    }
  }

  // Normalise to a comfortable level, then fade the tail so the clip
  // never ends on a click.
  var peak = 0.0;
  for (final s in samples) {
    if (s.abs() > peak) peak = s.abs();
  }
  final scale = peak == 0 ? 0.0 : 0.89 / peak;
  const fade = 0.03;
  final fadeSamples = (fade * _sampleRate).round();

  final pcm = Int16List(sampleCount);
  for (var i = 0; i < sampleCount; i++) {
    var value = samples[i] * scale;
    final remaining = sampleCount - i;
    if (remaining < fadeSamples) value *= remaining / fadeSamples;
    pcm[i] = (value.clamp(-1.0, 1.0) * 32767).round();
  }

  File(_output)
    ..createSync(recursive: true)
    ..writeAsBytesSync(_wav(pcm));
  stdout.writeln('wrote $_output '
      '(${duration.toStringAsFixed(2)}s, $_sampleRate Hz mono, ${_coins.length} coins)');
}

/// Wraps 16-bit mono PCM in a WAV container, matching the other effects
/// in assets/audio.
Uint8List _wav(Int16List pcm) {
  final dataBytes = pcm.lengthInBytes;
  final out = BytesBuilder();
  void ascii(String s) => out.add(s.codeUnits);
  void u32(int v) => out.add(Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little));
  void u16(int v) => out.add(Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little));

  ascii('RIFF');
  u32(36 + dataBytes);
  ascii('WAVE');
  ascii('fmt ');
  u32(16); // PCM chunk size
  u16(1); // PCM
  u16(1); // mono
  u32(_sampleRate);
  u32(_sampleRate * 2); // byte rate
  u16(2); // block align
  u16(16); // bits per sample
  ascii('data');
  u32(dataBytes);
  out.add(pcm.buffer.asUint8List(0, dataBytes));
  return out.toBytes();
}
