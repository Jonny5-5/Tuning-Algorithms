// // ignore_for_file: non_constant_identifier_names

// part of fft;

// abstract class WindowType {
//   String name;

//   static WindowType HANN = HannWindowType._intern();
//   static WindowType HAMMING = HammingWindowType._intern();
//   static WindowType NONE = NoWindowType._intern();

//   WindowType._intern(this.name);

//   Iterable<num> getFactors(int len);
// }

// class HannWindowType extends WindowType {
//   HannWindowType._intern() : super._intern("hann");

//   @override
//   Iterable<num> getFactors(int len) {
//     List<num> factors = List<num>.generate(len, (index) => 0);
//     var factor = 2 * math.pi / (len - 1);
//     for (int i = 0; i < len; i++) factors[i] = 0.5 * (1 - math.cos(i * factor));
//     return factors;
//   }
// }

// class NoWindowType extends WindowType {
//   NoWindowType._intern() : super._intern("No window");

//   @override
//   Iterable<num> getFactors(int len) {
//     return Iterable.generate(len, (i) => 1);
//   }
// }

// class HammingWindowType extends WindowType {
//   HammingWindowType._intern() : super._intern("Hamming");

//   @override
//   Iterable<num> getFactors(int len) {
//     var factors = List<num>.generate(len, (index) => 0);
//     var factor = 2 * math.pi / (len - 1);
//     for (int i = 0; i < len; i++) {
//       factors[i] = 0.54 - 0.46 * math.cos(i * factor);
//     }
//     return factors;
//   }
// }

// class Window {
//   final WindowType windowType;

//   Map<int, List<num>> cache = <int, List<num>>{};

//   Window(this.windowType);

//   List<num> multiplyLists(List<num> factors, List<num> x) {
//     if (factors.length != x.length) {
//       throw "lists of different lengths";
//     }
//     if (factors.isEmpty) return [];
//     List<num> ret = List<num>.generate(factors.length, (index) => 0);
//     for (int i = 0; i < ret.length; i++) {
//       ret[i] = factors[i] * x[i];
//     }
//     return ret;
//   }

//   List<num> apply(List<num> x) {
//     int len = x.length;
//     if (!cache.containsKey(len)) {
//       cache[len] = windowType.getFactors(len).toList(growable: false);
//     }
//     return multiplyLists(cache[len]!, x);
//   }
// }
