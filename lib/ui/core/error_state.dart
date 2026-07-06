import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.icon = FLucideIcons.alertCircle,
    this.iconSize = 48,
    this.iconColor,
    this.onRetry,
    this.retryLabel,
    this.child,
  });

  final String message;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(height: 16),
          Text(message),
          if (child != null) ...[
            const SizedBox(height: 8),
            DefaultTextStyle(
              style: Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
              child: child!,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FButton(onPress: onRetry, child: Text(retryLabel ?? 'Retry')),
          ],
        ],
      ),
    );
  }
}
