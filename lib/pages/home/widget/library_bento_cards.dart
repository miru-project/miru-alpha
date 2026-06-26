import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class LibraryBentoCards extends ConsumerWidget {
  const LibraryBentoCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _BentoCard(
            icon: FLucideIcons.heart,
            title: 'common.favorite.title'.i18n,
            subtitle: '128 Items saved',
            onTap: () => context.push('/home/favorite'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BentoCard(
            icon: FLucideIcons.download,
            title: 'download.name'.i18n,
            subtitle: '12 Downloads',
            onTap: () => context.push('/home/download'),
          ),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FCard.raw(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: context.theme.colors.primary.withAlpha(200),
                  ),
                  Icon(
                    FLucideIcons.arrowRight,
                    size: 16,
                    color: context.theme.colors.mutedForeground.withAlpha(120),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.theme.colors.mutedForeground.withAlpha(180),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
