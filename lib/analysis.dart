import 'dart:math';

// TODO: These depend on other packages??
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'package:welch_psd/data/data.dart';
import 'package:welch_psd/data/data_guitar_8000.dart';

/// Returns true if the calculated value is within [percent] of the [expected]
bool test_signal(Array signal, double fs, double expected, double percent) {
  double output = pwelch(signal, fs);
  if (output < expected * (1 + percent) && output > expected * percent) {
    return true;
  }
  print("Expected = $expected.   Actual = $output");
  return false;
}

List<double> generateSin(int n, double freq, double fs,
    {double noise_factor = 0}) {
  Random random = Random();
  return List<double>.generate(n, (index) {
    double t = index / fs;
    double s1 = sin(2 * pi * freq * t);
    double rand = noise_factor * random.nextDouble();
    return s1 + rand;
  });
}

void bench() {
  int passed = 0, total_tests = 0;
  double freq = 330;
  double fs = 8192;
  int n = fs ~/ 4; // record 1/4 seconds of audio
  final sw1 = Stopwatch()..start(); // nice syntax...

  // Tweaking values of n, freq, and fs

  // Test with sin waves no noise
  print("");
  print("Starting sin with NO noise...");
  for (double f = 40; f < 2040; f = f + 100) {
    total_tests++;
    // calculate sin waves from 20 - 4000 in gaps of 200
    var signal = generateSin(n, f, fs);
    bool success = test_signal(Array(signal), fs, f, 0.9);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

  // sin waves with some noise
  print("");
  print("Starting sin with SOME noise...");
  for (double f = 40; f < 2040; f = f + 100) {
    total_tests++;
    // calculate sin waves from 20 - 4000 in gaps of 200
    var signal = generateSin(n, f, fs, noise_factor: 0.1);
    bool success = test_signal(Array(signal), fs, f, 0.9);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

  // sin  waves with a lot of noise
  print("");
  print("Starting sin with LOTS of noise...");
  for (double f = 40; f < 2040; f = f + 100) {
    total_tests++;
    // calculate sin waves from 20 - 4000 in gaps of 200
    var signal = generateSin(n, f, fs, noise_factor: 0.25); //.3 is too much?
    bool success = test_signal(Array(signal), fs, f, 0.9);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

  // sin waves with HIGH accuracy
  print("");
  print("Starting sin HIGH accuracy with some noise...");
  for (double f = 40; f < 2040; f = f + 100) {
    total_tests++;
    // calculate sin waves from 20 - 4000 in gaps of 200
    var signal = generateSin(n, f, fs, noise_factor: 0.1);
    bool success = test_signal(Array(signal), fs, f, 0.95);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

  // actual samples from guitar/ukulele

  // push the limits of high/low freqs
  print("");
  print("Starting push limits...");
  final List<double> FREQS = [
    1,
    2,
    5,
    10,
    20,
    25,
    30,
    31,
    32,
    33,
    34,
    35,
    2000,
    2200,
    2500,
    3000,
    3500,
    3750,
    4000,
    4400
  ];
  for (double f in FREQS) {
    total_tests++;
    var signal = generateSin(n, f, fs, noise_factor: 0.1); //.3 is too much?
    bool success = test_signal(Array(signal), fs, f, 0.9);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

  // no frequency should be found
  //   amplitude * MAGIC_NUMBER < mean
  print("");
  print("Starting no frequency should be detected...");
  for (double f = 40; f < 2040; f = f + 100) {
    total_tests++;
    // calculate sin waves from 20 - 4000 in gaps of 200
    var signal = generateSin(n, f, fs, noise_factor: 5); // 5 is sooo much
    bool success = test_signal(Array(signal), fs, -1, 1);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

  // timing
  print("");
  print("Starting timing test...");
  final stopwatch = Stopwatch()..start(); // nice syntax...
  total_tests++;
  for (double f = 40; f < 2040; f = f + 100) {
    // calculate sin waves from 20 - 4000 in gaps of 200
    var signal = generateSin(n, f, fs);
    test_signal(Array(signal), fs, f, 0.9);
  }
  stopwatch.stop();
  final int elapsedMilliseconds = stopwatch.elapsedMilliseconds;
  print("Timing test: elapsed time = $elapsedMilliseconds ms");
  print("Average timing per sin test = ${elapsedMilliseconds / 20}");
  if (elapsedMilliseconds / 20 < 100) {
    print("passed! Average was less than 100ms");
    passed++;
  } else {
    print("FAILED! The average time was higher than 100ms");
  }

  print("");
  sw1.stop();
  final int duration = sw1.elapsedMilliseconds;
  print("Total test time = $duration ms");
  print("Average duration = ${duration / total_tests} ms");
  print("Passed $passed out of $total_tests");
  print("DONE");
}

void analyze() {
  // generate the signals for test
  // 1Hz sine wave
  // var N = 4096.0;
  // var fs = 8192.0;
  // var n = linspace(0, N, num: (N * fs).toInt(), endpoint: false);
  // var f1 = 2.0; // 1Hz
  // var sg1 = arraySin(arrayMultiplyToScalar(n, 2 * pi * f1));

  double f1 = 330;
  double fs = 8192;
  int n = fs ~/ 4;

  Random random = Random();
  List<double> samples = List<double>.generate(n, (index) {
    double t = index / fs;
    double s1 = sin(2 * pi * f1 * t);
    double rand = 0.2 * random.nextDouble();
    return s1 + rand;
  });
  Array signal = Array(samples);

  // fs = 8192;
  // f1 = 440;
  // n = fs ~/ 4;
  // List<double> small_data = data.sublist(0, n);
  // Array signal = Array(small_data);

  // fs = 8192;
  // f1 = 110;
  // Array signal = Array(data_guitar_a110.sublist(0, 4096));

  // Create a Stopwatch to measure the time
  final stopwatch = Stopwatch()..start();

  // var fEstimated = freqFromFft(signal, fs);

  var fEstimated = pwelch(signal, fs);

  // Stop the timer
  stopwatch.stop();

  // Get the elapsed time in milliseconds
  final int elapsedMilliseconds = stopwatch.elapsedMilliseconds;
  print("Elapsed time: $elapsedMilliseconds ms");
  print('The original and estimated frequency need be very close each other');
  print('Original frequency: $f1');
  print('Estimated frequency: $fEstimated');
}

double freqFromFft(Array sig, double fs) {
  // Estimate frequency from peak of FFT

  // Compute Fourier transform of windowed signal
  // Avoid spectral leakage: https://en.wikipedia.org/wiki/Spectral_leakage
  // TODO: I want to switch this to a hamming window
  var windowed = sig * blackmanharris(sig.length);
  var f = rfft(windowed);

  var fAbs = arrayComplexAbs(f);

  // Find the peak and interpolate to get a more accurate peak
  var i = arrayArgMax(fAbs); // Just use this for less-accurate, naive version

  // Parabolic approximation is necessary to get the exact frequency of a discrete signal
  // since the frequency can be in some point between the samples.
  double true_i = parabolic(arrayLog(fAbs), i)[0];

  // Convert to equivalent frequency
  return fs * true_i / windowed.length;
}

/// Autogenerated from ChatGPT:
bool isPowerOf2(int length) {
  // Check if the length is greater than 0 and a power of 2
  return length > 0 && (length & (length - 1)) == 0;
}

/// Estimate frequency from FFT using the pwelch method
/// This might also be called "Harmonic Product Spectrum Theory"
/// [sig] should be of length (multiple of 2)
double pwelch(Array sig, double fs, {double noise_floor = 10}) {
  if (!isPowerOf2(sig.length)) {
    print("WARNING: signal length is not a power of 2");
  }

  // Split the signal into smaller windows
  // Dr. Jeffs said I would want like 10 or 100
  // I choose sig.length / 4
  const int factor = 4; // make this a multiple of 4
  int window_len = sig.length ~/ factor;
  int startIndex = 0;
  int windowsCalculated = 0;

  // Sum all the powers into this
  Array powers = Array.fixed(window_len ~/ 2 + 1);
  Array ham = hamming(window_len);

  // This will be how many windows to evaluate
  while (windowsCalculated != factor * 2 - 1) {
    // Window the sample
    Array windowed =
        Array(sig.sublist(startIndex, startIndex + window_len)) * ham;

    // Take the fft of the shorter window
    ArrayComplex f = rfft(windowed);

    // Get the abs of the fft
    Array fAbs = arrayComplexAbs(f);

    // Add those back into a bigger copy
    powers += fAbs;

    // Update the other indices
    // Shift each one by half
    startIndex += window_len ~/ 2;
    windowsCalculated++;
  }

  // Used for finding if there is a signal
  bool foundSignal = false;
  double power_mean = mean(powers);

  // Find the top 5 peaks
  List<int> peaks = [];
  const int NUM_PEAKS = 5;
  for (int i = 0; i < NUM_PEAKS; i++) {
    double tmp_max = -1;
    int tmp_i = -1;
    for (int j = 0; j < powers.length; j++) {
      if (powers[j] > tmp_max && !peaks.contains(j)) {
        tmp_i = j;
        tmp_max = powers[j];
        if (tmp_max * noise_floor > power_mean) foundSignal = true;
      }
    }
    peaks.add(tmp_i);
  }
  // for (int p in peaks) {
  //   print("Frequency if peak is $p: ${fs * p / window_len}");
  // }

  if (!foundSignal) return -1; // This means that you didn't find a signal

  // For each peak
  List<double> sums = [];
  const List<int> SPLASH = [-2, -1, 0, 1, 2];
  const List<double> FACTORS = [0.5, 2, 3];
  for (int peak in peaks) {
    double sum = 0;
    if (peak == 0) {
      sums.add(sum);
      continue;
    }

    for (double f in FACTORS) {
      int newIndex = (peak * f).toInt();
      if (newIndex < 2) newIndex = 2;
      if (newIndex + 3 > powers.length) newIndex = powers.length - 3;
      sum += powers[newIndex - 2] * powers[peak];
      sum += powers[newIndex - 1] * powers[peak];
      sum += powers[newIndex - 0] * powers[peak];
      sum += powers[newIndex + 1] * powers[peak];
      sum += powers[newIndex + 2] * powers[peak];
    }

    sums.add(sum);
  }

  // Whichever is largest is the best
  int max_index = 0;
  for (int i = 1; i < sums.length; i++) {
    if (sums[i] > sums[max_index]) {
      max_index = i;
    }
  }

  double true_i = parabolic(arrayLog(powers), peaks[max_index])[0];
  // print("The best guess index: $true_i");
  // print("The best guess frequency: ${fs * true_i / window_len}");

  // Convert to equivalent frequency
  return fs * true_i / window_len;
}
