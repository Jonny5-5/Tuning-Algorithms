// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';

const double ERROR_FREQ = -1;
const double SAMPLE_RATE = 8192;

/*
Testing from the benchmark
I/flutter ( 8203): Total test time = 3596 ms
I/flutter ( 8203): Average duration = 27.450381679389313 ms
I/flutter ( 8203): Passed 131 out of 131
I/flutter ( 8203): DONE
*/

/// Autogenerated from ChatGPT:
bool isPowerOf2(int length) {
  // Check if the length is greater than 0 and a power of 2
  return length > 0 && (length & (length - 1)) == 0;
}

/// Estimate frequency from FFT using the Welch method
/// and "Harmonic Product Spectrum Theory"
/// [sig] should be of length (multiple of 2)
double findFundFreqWelchHPS(Array sig, double fs, {double noise_floor = 2}) {
  // Check that there are enough samples
  const int minSigLength = 2048;
  if (sig.length < minSigLength) {
    debugPrint("Not enough samples! Expecting > 2048. Got ${sig.length}");
    return ERROR_FREQ;
  }

  // Check that the signal is a power of 2
  if (!isPowerOf2(sig.length)) {
    debugPrint("WARNING: signal length is not a power of 2");
  }

  // Trim the array to either samplerate/2 or samplerate/4
  if (sig.length > SAMPLE_RATE / 2) {
    debugPrint("Cutting length to ${SAMPLE_RATE ~/ 2}");
    sig = Array(sig.sublist(0, SAMPLE_RATE ~/ 2));
  } else if (sig.length > SAMPLE_RATE ~/ 4) {
    sig = Array(sig.sublist(0, SAMPLE_RATE ~/ 4));
  }

  // Add a warning that the samplerate should be the rate passed into the function
  if (fs != SAMPLE_RATE) {
    debugPrint("What are you doing?");
    debugPrint("The sample_rate should be $SAMPLE_RATE");
    debugPrint("This algorthm shouldn't care, but double check...");
  }

  // Normalize the signal to get rid of the noise.
  double sig_avg = mean(sig);
  for (int i = 0; i < sig.length; i++) {
    sig[i] -= sig_avg;
  }

  // Split the signal into smaller windows
  // Dr. Jeffs said I would want like 10 or 100
  // I choose sig.length / 4 (7 windows)
  const int factor = 4; // make this a multiple of 4
  int windowLength = sig.length ~/ factor;
  int startIndex = 0;
  int windowsCalculated = 0;

  // Sum all the powers into arrays for later use.
  // Allocate the arrays:
  Array powers = Array.fixed(windowLength ~/ 2 + 1);
  // Create my hamming window to avoid spectral leakage.
  Array ham = hamming(windowLength);

  // There should always be 7 windows.
  while (windowsCalculated != factor * 2 - 1) {
    // Window the sample...
    Array windowed =
        Array(sig.sublist(startIndex, startIndex + windowLength)) * ham;

    // Take the fft of the shorter window...
    ArrayComplex f = rfft(windowed);

    // Get the abs of the fft because we only have real values...
    Array fAbs = arrayComplexAbs(f);

    // Add those back into the [powers] array from above...
    powers += fAbs;

    // Update the other indices and shift each one by half a window...
    startIndex += windowLength ~/ 2;
    windowsCalculated++;
  }

  // Used for finding if there is a signal worth processing
  bool foundSignal = false;
  double avgPower = mean(powers);

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
        // If the max power value is greater than the noise_floor, we found a signal
        if (tmp_max / noise_floor > avgPower) foundSignal = true;
      }
    }
    peaks.add(tmp_i);
  }

  // This means that you didn't find a signal
  if (!foundSignal) return ERROR_FREQ;

  // Do some "Harmonic Product Spectrum Theory"
  // For each peak, multiply by where the harmonics (should) appear in the signal.
  // Sum up the power multiples of these and then find the largest one.
  List<double> sums = [];
  // Check at all these multiples of the frequency that we want to evaluate
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
      // Splash out a little bit and include the neighboring peaks
      // in case we weren't too accurate.
      sum += powers[newIndex - 2] * powers[peak];
      sum += powers[newIndex - 1] * powers[peak];
      sum += powers[newIndex - 0] * powers[peak];
      sum += powers[newIndex + 1] * powers[peak];
      sum += powers[newIndex + 2] * powers[peak];
    }

    sums.add(sum);
  }

  // Whichever is largest is the final peak option
  int max_index = 0;
  for (int i = 1; i < sums.length; i++) {
    if (sums[i] > sums[max_index]) {
      max_index = i;
    }
  }

  // Use a parabolic approximation around the max_index to get better estimation
  double true_i = parabolic(arrayLog(powers), peaks[max_index])[0];

  // Convert to equivalent frequency :)
  return fs * true_i / windowLength;
}
