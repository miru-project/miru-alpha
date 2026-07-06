import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return const Center(child: FCircularProgress());
  }
}
