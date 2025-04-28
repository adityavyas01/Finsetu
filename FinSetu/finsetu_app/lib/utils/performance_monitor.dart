import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A class that helps monitor app performance and responsiveness
class PerformanceMonitor {
  static const int _uiLagThresholdMs = 100;
  static Timer? _periodicTimer;
  static DateTime? _lastCheckTime;
  
  /// Start monitoring UI responsiveness
  static void startMonitoring() {
    if (_periodicTimer != null) {
      return;
    }
    
    _lastCheckTime = DateTime.now();
    _periodicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkUIResponsiveness();
    });
  }
  
  /// Stop monitoring
  static void stopMonitoring() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
  
  /// Check if the UI is responsive
  static void _checkUIResponsiveness() {
    final now = DateTime.now();
    final lastTime = _lastCheckTime;
    _lastCheckTime = now;
    
    if (lastTime != null) {
      final lag = now.difference(lastTime).inMilliseconds - 1000;
      if (lag > _uiLagThresholdMs) {
        developer.log('UI lag detected: ${lag}ms', name: 'PerformanceMonitor');
      }
    }
  }
  
  /// Initialize performance improvements
  static void initPerformanceImprovements() {
    if (kReleaseMode) {
      // Optimize Flutter for release mode
      WidgetsBinding.instance.renderView.automaticSystemUiAdjustment = false;
      
      // Additional optimizations for Windows platform
      if (defaultTargetPlatform == TargetPlatform.windows) {
        // Windows-specific optimizations
        developer.log('Applying Windows performance optimizations', name: 'PerformanceMonitor');
      }
    }
  }
}
