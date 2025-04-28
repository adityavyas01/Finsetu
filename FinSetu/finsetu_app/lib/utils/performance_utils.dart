import 'package:flutter/foundation.dart';
import 'dart:async';

/// Utility class for handling performance optimizations
class PerformanceUtils {
  /// Run heavy computation on a separate isolate
  /// 
  /// [computation] is the function to run
  /// [message] is the data to pass to the function
  static Future<T> computeIsolate<Q, T>(
    ComputeCallback<Q, T> computation,
    Q message,
  ) {
    return compute(computation, message);
  }
  
  /// Helper method to avoid blocking the main thread
  /// when loading data from APIs or databases
  static Future<void> scheduleMicrotask(VoidCallback callback) {
    return Future.microtask(callback);
  }
  
  /// Debounce function to prevent excessive UI updates
  static Function(T) debounce<T>(
    Function(T) function,
    Duration duration,
  ) {
    Timer? timer;
    return (T args) {
      if (timer != null) {
        timer!.cancel();
      }
      timer = Timer(duration, () {
        function(args);
      });
    };
  }
}
