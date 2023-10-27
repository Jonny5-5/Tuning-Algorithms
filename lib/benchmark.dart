import 'dart:math';

// TODO: These depend on other packages??
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'package:welch_psd/data/data.dart';
import 'package:welch_psd/data/data_guitar_8000.dart';
import 'package:welch_psd/tuner/tuner.dart';

/// Returns true if the calculated value is within [percent] of the [expected]
bool test_signal(Array signal, double fs, double expected, double percent) {
  double output = findFundFreqWelchHPS(signal, fs);
  if (output == expected) return true;
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

  // push the limits of high/low freqs
  print("");
  print("Starting push limits...");
  final List<double> FREQS = [
    20,
    21,
    22,
    23,
    24,
    25,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    2000,
    2200,
    2500,
    3000,
    3500,
    3750,
    3880,
    3900,
    4000
  ];
  for (double f in FREQS) {
    total_tests++;
    var signal = generateSin(n, f, fs, noise_factor: 1); //.3 is too much?
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
    var signal = generateSin(n, f, fs, noise_factor: 2);
    bool success = test_signal(Array(signal), fs, f, 0.95);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

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
    var signal = generateSin(n, f, fs, noise_factor: 1);
    bool success = test_signal(Array(signal), fs, f, 0.9);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

  // actual samples from guitar/ukulele
  print("");
  print("Real samples:");
  bool success = test_signal(Array(data_guitar_a110), fs, 110, 0.9);
  if (success) {
    print("Success! Passed Guitar 110Hz");
    passed++;
  } else {
    print("FAILED! Guitar 110Hz");
  }

  success = test_signal(Array(uke_data.sublist(0, 4096)), fs, 440, 0.9);
  if (success) {
    print("Success! Passed Ukulele 440Hz");
    passed++;
  } else {
    print("FAILED! Ukulele 440Hz");
  }

  success = test_signal(Array(uke_data), fs, 440, 0.9);
  if (success) {
    print("Success! Passed Ukulele too much data 440Hz");
    passed++;
  } else {
    print("FAILED! Ukulele too much data 440Hz");
  }

  // sin  waves with a lot of noise
  print("");
  print("Starting sin with LOTS of noise...");
  for (double f = 40; f < 2040; f = f + 100) {
    total_tests++;
    // calculate sin waves from 20 - 4000 in gaps of 200
    var signal = generateSin(n, f, fs, noise_factor: 10); // 15 is SOOO much
    bool success = test_signal(Array(signal), fs, f, 0.9);
    if (success) {
      print("Success! Passed, freq = $f");
      passed++;
    } else {
      print("FAILED!, freq = $f");
    }
  }

  // no frequency should be found. TOO MUCH NOISE
  print("");
  print("Starting no frequency should be detected...");
  for (double f = 40; f < 2040; f = f + 100) {
    total_tests++;
    // calculate sin waves from 20 - 4000 in gaps of 200
    var signal = generateSin(n, f, fs, noise_factor: 50); // 15 is SOOO much
    bool success = test_signal(Array(signal), fs, -1, 0.999);
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

  var fEstimated = findFundFreqWelchHPS(signal, fs);

  // Stop the timer
  stopwatch.stop();

  // Get the elapsed time in milliseconds
  final int elapsedMilliseconds = stopwatch.elapsedMilliseconds;
  print("Elapsed time: $elapsedMilliseconds ms");
  print('The original and estimated frequency need be very close each other');
  print('Original frequency: $f1');
  print('Estimated frequency: $fEstimated');
}
