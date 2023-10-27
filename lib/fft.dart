// TODO: These depend on other packages??
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';

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
