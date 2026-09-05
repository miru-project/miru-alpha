import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

@Preview(name: 'Mobile Detail Skeleton', size: Size(375, 812))
Widget mobileDetailSkeletonPreview() {
  return Theme(
    data: ThemeData.light(),
    child: Builder(
      builder: (context) {
        final muted = Theme.of(context).colorScheme.surfaceContainerHighest;
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: muted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 150,
                          height: 36,
                          decoration: BoxDecoration(
                            color: muted,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: muted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 36,
                          decoration: BoxDecoration(
                            color: muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < 5; i++)
                          Container(
                            width: 110,
                            height: 36,
                            decoration: BoxDecoration(
                              color: muted,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 18, color: muted),
                    const SizedBox(height: 10),
                    Container(width: double.infinity, height: 14, color: muted),
                    const SizedBox(height: 6),
                    Container(width: 220, height: 14, color: muted),
                    const SizedBox(height: 6),
                    Container(width: 180, height: 14, color: muted),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
