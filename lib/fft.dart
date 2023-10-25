// library fft;

// import 'dart:math' as math;
// import 'dart:collection';
// import 'package:tuple/tuple.dart';
// import 'package:complex/complex.dart';

// part 'window.dart';

// typedef Combiner<T> = T Function(T t1, T t2);
// typedef MapFunc<S, T> = T Function(int i, S s);

// class FFT {
//   late _Twiddles _twiddles;

//   List<Complex> Transform(List<num> x) {
//     int len = x.length;
//     if (!isPowerOf2(len)) throw "length must be power of 2";
//     _twiddles = _Twiddles(len);
//     var xcp =
//         x.map((num d) => Complex(d.toDouble(), 0.0)).toList(growable: false);
//     return _transform(xcp, xcp.length, 1).toList(growable: false);
//   }

//   List<Complex> _transform(List<Complex> x, int length, int step) {
//     if (length == 1) return x;
//     int halfLength = length ~/ 2;
//     var sl = SplitList<Complex>.fromIterable(x);
//     List<Complex> evens = _transform(sl.evens, halfLength, step * 2);
//     List<Complex> odds = _transform(sl.odds, halfLength, step * 2);

//     List<Complex> newodds =
//         indexedMap(odds, (i, odd) => odd * _twiddles.at(i, length));

//     var results = combineIterables<Complex>(
//         evens.take(halfLength), newodds.take(halfLength), (i1, i2) => i1 + i2)
//       ..addAll(combineIterables<Complex>(evens.take(halfLength),
//           newodds.take(halfLength), (i1, i2) => i1 - i2));

//     return results;
//   }
// }

// bool isPowerOf2(int i) {
//   if (i == 1) return true;
//   if (i % 2 == 1) return false;
//   return isPowerOf2(i ~/ 2);
// }

// List<T> indexedMap<S, T>(List<S> l, MapFunc<S, T> mapFunc) {
//   List<T> ret = [];
//   for (int i = 0; i < l.length; i++) {
//     ret.add(mapFunc(i, l[i]));
//   }
//   return ret;
// }

// List<T> combineIterables<T>(
//     Iterable<T> i1, Iterable<T> i2, Combiner<T> combiner) {
//   return combineLists(
//       i1.toList(growable: false), i2.toList(growable: false), combiner);
// }

// List<T> combineLists<T>(List<T> l1, List<T> l2, Combiner<T> combiner) {
//   if (l1.length != l2.length) {
//     throw "lists of different lengths";
//   }
//   if (l1.isEmpty) return l2;
//   if (l2.isEmpty) return l1;

//   List<T> ret = [];
//   for (int i = 0; i < l1.length; i++) {
//     ret.add(combiner(l1[i], l2[i]));
//   }
//   return ret;
// }

// class _Twiddles {
//   late List<Complex> _cache;
//   late final int _cacheLength;
//   late double _turn;

//   _Twiddles(this._cacheLength) {
//     _cache = [];
//     _turn = 2 * math.pi / _cacheLength;
//   }

//   Complex at(int i, int length) {
//     int n = i * _cacheLength ~/ length;
//     if (_cache[n] == null) {
//       _cache[n] = Complex.polar(1.0, -n * _turn);
//     }
//     return _cache[n];
//   }
// }

// class SplitList<T> {
//   final List<T> evens;
//   final List<T> odds;

//   SplitList(this.evens, this.odds);

//   factory SplitList.fromIterable(Iterable<T> x) {
//     var t = _createSplitList(x.toList(growable: false));
//     return SplitList(t.item1.toList(), t.item2.toList());
//   }

//   static Tuple2<List<T>, List<T>> _createSplitList<T>(List<T> x) {
//     if (x.isEmpty) {
//       return Tuple2<List<T>, List<T>>([], []);
//     }
//     List<T> evens = [];
//     List<T> odds = [];
//     for (int i = 0; i < x.length; i += 2) {
//       evens.add(x[i]);
//       if (i + 1 < x.length) odds.add(x[i + 1]);
//     }
//     return Tuple2<List<T>, List<T>>(evens, odds);
//   }

//   static Queue<T> _zipInternal<T>(Iterable<T> i1, Iterable<T> i2) {
//     if (i1.isEmpty) return Queue.from(i2);
//     return _zipInternal(i2, i1.skip(1))..addFirst(i1.first);
//   }

//   List<T> zip() => _zipInternal(this.evens, this.odds).toList();
// }
