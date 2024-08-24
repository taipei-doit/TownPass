import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TPShimmerWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const TPShimmerWidget({
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: isLoading,
      child: child,
    );
  }
}
