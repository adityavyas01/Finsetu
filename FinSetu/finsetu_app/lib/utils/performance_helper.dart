import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

class PerformanceHelper {
  /// Monitor frame build times
  static void monitorFrames() {
    Timeline.startSync('FrameMonitoring');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timeline.finishSync();
    });
  }
  
  /// Run heavy operations in isolates or separate compute functions
  static Future<T> runExpensiveOperation<T>(
    Future<T> Function() operation,
  ) async {
    // This is where you could add compute() or isolates for CPU-intensive tasks
    try {
      return await operation();
    } catch (e) {
      log('Error in expensive operation: $e');
      rethrow;
    }
  }
  
  /// Optimize image loading
  static Widget optimizedImage({
    required ImageProvider imageProvider,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}
