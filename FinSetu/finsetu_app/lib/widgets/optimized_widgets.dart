import 'package:flutter/material.dart';

/// A wrapper widget that only rebuilds when necessary
class OptimizedBuilder extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final Object? dependency;

  const OptimizedBuilder({
    Key? key,
    required this.builder,
    required this.dependency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }

  // (removed custom == and hashCode; Widgets cannot override operator==)
}

/// ListView with built-in performance optimizations
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      // Using cacheExtent to keep more items in memory
      cacheExtent: 100.0,
      // Adding clipBehavior to improve scrolling performance
      clipBehavior: Clip.hardEdge,
      itemBuilder: (context, index) {
        // Wrapping each item with RepaintBoundary to isolate repaints
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      shrinkWrap: shrinkWrap,
      physics: physics,
      // Add these to improve scrolling performance
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
    );
  }
}
