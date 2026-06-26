import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LibraryQuickActions extends ConsumerWidget {
  const LibraryQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionItem(
            icon: FLucideIcons.refreshCcw,
            label: 'Updates',
            onTap: () {},
          ),
        ),
        Expanded(
          child: _QuickActionItem(
            icon: FLucideIcons.cloudSync,
            label: 'Sync',
            onTap: () {},
          ),
        ),
        Expanded(
          child: _QuickActionItem(
            icon: FLucideIcons.bookmark,
            label: 'Tags',
            onTap: () {},
          ),
        ),
        Expanded(
          child: _QuickActionItem(
            icon: FLucideIcons.settings,
            label: 'Tools',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: FCard.raw(
                child: Icon(
                  icon,
                  size: 22,
                  color: context.theme.colors.foreground.withAlpha(200),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
