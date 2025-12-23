import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart' as vec;

class BlocksPathLoopIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isTriggered;

  const BlocksPathLoopIcon({
    super.key,
    this.size = 22.0,
    this.color = Colors.black,
    this.isTriggered = false,
  });

  @override
  Widget build(BuildContext context) {
    const String path1Data =
        "M10 22V7c0-.6-.4-1-1-1H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2v-5c0-.6-.4-1-1-1H2";
    const String path2Data =
        "M15 2 H21 A1 1 0 0 1 22 3 V9 A1 1 0 0 1 21 10 H15 A1 1 0 0 1 14 9 V3 A1 1 0 0 1 15 2 Z";

    return Animate(target: isTriggered ? 1.0 : 0.0).custom(
      duration: 1200.ms,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // pathLength: 1 -> 0 -> 1
        double pathLengthFactor = (value - 0.5).abs() * 2;

        return Center(
          // Added Center to ensure it doesn't stretch to parent
          child: CustomPaint(
            size: Size(size, size),
            painter: _PathLoopPainter(
              paths: [path1Data, path2Data],
              color: color,
              pathLengthFactor: pathLengthFactor,
            ),
          ),
        );
      },
    );
  }
}

class _PathLoopPainter extends CustomPainter {
  final List<String> paths;
  final Color color;
  final double pathLengthFactor;

  _PathLoopPainter({
    required this.paths,
    required this.color,
    required this.pathLengthFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // IMPORTANT: Calculate uniform scale to prevent flattening
    // Since the original viewBox is 24x24
    double scaleX = size.width / 24;
    double scaleY = size.height / 24;
    double uniformScale = scaleX < scaleY ? scaleX : scaleY;

    for (var data in paths) {
      Path path = parseSvgPathData(data);

      // Apply uniform scale
      final matrix = Matrix4.identity()
        ..scaleByVector3(vec.Vector3(uniformScale, uniformScale, 0));
      path = path.transform(matrix.storage);

      Path extractPath = Path();
      for (PathMetric metric in path.computeMetrics()) {
        final double extractLength = metric.length * pathLengthFactor;
        extractPath.addPath(metric.extractPath(0, extractLength), Offset.zero);
      }

      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PathLoopPainter oldDelegate) =>
      oldDelegate.pathLengthFactor != pathLengthFactor ||
      oldDelegate.color != color;
}
// class BlocksIcon extends StatelessWidget {
//   final double size;
//   final Color color;
//   final bool isHovered;

//   const BlocksIcon({
//     super.key,
//     this.size = 24.0,
//     this.color = Colors.black,
//     this.isHovered = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Path Data from your React code
//     const String path1Initial =
//         "M10 22V7c0-.6-.4-1-1-1H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2v-5c0-.6-.4-1-1-1H2";
//     const String path1Animate =
//         "M10 22V6H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2v-6H2";

//     const String path2Initial =
//         "M15 2 H21 A1 1 0 0 1 22 3 V9 A1 1 0 0 1 21 10 H15 A1 1 0 0 1 14 9 V3 A1 1 0 0 1 15 2 Z";
//     const String path2Animate =
//         "M15 2 H20 A2 2 0 0 1 22 4 V9 A1 1 0 0 1 21 10 H15 A1 1 0 0 1 14 9 V3 A1 1 0 0 1 15 2 Z";

//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         children: [
//           // Path 1 Animation (The larger block)
//           _AnimatedPath(
//             pathInitial: path1Initial,
//             pathAnimate: path1Animate,
//             color: color,
//             size: size,
//             offset: const Offset(2, -2),
//             isTriggered: isHovered,
//           ),
//           // Path 2 Animation (The smaller block)
//           _AnimatedPath(
//             pathInitial: path2Initial,
//             pathAnimate: path2Animate,
//             color: color,
//             size: size,
//             offset: const Offset(-2, 2),
//             isTriggered: isHovered,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AnimatedPath extends StatelessWidget {
//   final String pathInitial;
//   final String pathAnimate;
//   final Color color;
//   final double size;
//   final Offset offset;
//   final bool isTriggered;

//   const _AnimatedPath({
//     required this.pathInitial,
//     required this.pathAnimate,
//     required this.color,
//     required this.size,
//     required this.offset,
//     required this.isTriggered,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Animate(target: isTriggered ? 1.0 : 0.0).custom(
//       duration: 800.ms,
//       curve: Curves.easeInOut,
//       builder: (context, value, child) {
//         // value goes 0 -> 1 -> 0 to create the "loop" feel
//         // We use a simple triangle wave for the loop
//         double loopValue = value <= 0.5 ? value * 2 : (1.0 - value) * 2;

//         // Morph path based on loopValue (Snap at 0.3 as per your React delay)
//         String currentPath = loopValue > 0.3 ? pathAnimate : pathInitial;

//         return Transform.translate(
//           offset: Offset(offset.dx * loopValue, offset.dy * loopValue),
//           child: CustomPaint(
//             size: Size(size, size),
//             painter: _PathPainter(
//               pathData: currentPath,
//               color: color,
//               // Match strokeJoin: ['round', 'miter', 'round']
//               strokeJoin: loopValue > 0.3 ? StrokeJoin.miter : StrokeJoin.round,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _PathPainter extends CustomPainter {
//   final String pathData;
//   final Color color;
//   final StrokeJoin strokeJoin;

//   _PathPainter({
//     required this.pathData,
//     required this.color,
//     required this.strokeJoin,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     Path path = parseSvgPathData(pathData);

//     // Scale SVG 24x24 to widget size
//     final matrix = Matrix4.identity()..scale(size.width / 24, size.height / 24);
//     path = path.transform(matrix.storage);

//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0
//       ..strokeCap = StrokeCap.round
//       ..strokeJoin = strokeJoin;

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant _PathPainter oldDelegate) =>
//       oldDelegate.pathData != pathData || oldDelegate.strokeJoin != strokeJoin;
// }
