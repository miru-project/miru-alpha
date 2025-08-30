import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class InnerCard extends StatelessWidget {
  const InnerCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: FLabel(
                description: subtitle == null ? null : Text(subtitle!),
                axis: Axis.vertical,
                child: Text(title),
              ),
            ),
            SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
