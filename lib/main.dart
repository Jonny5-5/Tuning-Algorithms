import 'package:flutter/material.dart';
import 'package:welch_psd/benchmark.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  void thing() {
    analyze();
  }

  void benchmark() {
    bench();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: thing,
                child: const Text('Single test'),
              ),
              ElevatedButton(
                onPressed: benchmark,
                child: const Text('Benchmark'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
