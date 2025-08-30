import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class OutterCard extends StatelessWidget {
  const OutterCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });
  final Widget child;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 10),
          child:
              trailing == null
                  ? Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      trailing!,
                    ],
                  ),
        ),
        SizedBox(
          width: double.infinity,
          child: FCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: LayoutBuilder(builder: (context, constraints) => child),
            ),
          ),
        ),
      ],
    );
  }
}
