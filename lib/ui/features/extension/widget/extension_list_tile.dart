import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/ui/core/widget/miru_card.dart';
import 'package:miru_alpha/ui/core/widget/small_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';
import 'package:miru_alpha/ui/core/core/image_widget.dart';
import 'package:miru_alpha/ui/features/extension/widget/text_cover.dart';

/// Reference card for the mobile store list: 44px rounded icon, name with
/// type/update/NSFW badges, a metadata line, an optional two-line
/// description, and the state-appropriate trailing action (Install /
/// Update / Installed chip + uninstall).
class ExtensionListTile extends StatelessWidget {
  const ExtensionListTile({
    super.key,
    required this.name,
    required this.isNSFW,
    this.icon,
    this.typeIcon,
    required this.version,
    required this.author,
    required this.type,
    this.description,
    required this.onInstall,
    required this.onUninstall,
    required this.isInstalled,
    required this.needUpdate,
    this.lang = '',
    this.installedVersion = '',
    this.tags = const [],
  });
  final bool isNSFW;
  final String name;
  final String? icon;

  /// Category glyph for the [TextCover] fallback tile (see
  /// [extensionTypeIcon]) — drawn when the source has no icon of its own.
  final IconData? typeIcon;
  final String version;

  /// The currently-installed version, only used for the `v1.4.0 → v1.5.0`
  /// line while an update waits.
  final String installedVersion;
  final String author;
  final String lang;
  final String type;
  final String? description;
  final List<String> tags;
  final void Function() onInstall;
  final void Function() onUninstall;
  final bool isInstalled;
  final bool needUpdate;

  /// The `v1.4.0 → v1.5.0` line while an update waits, otherwise the plain
  /// `v1.4.2 · en_US · author` metadata line. Version strings already
  /// carry their own `v` in the repo data, so they are joined raw.
  String get _metaLine {
    if (needUpdate && installedVersion.isNotEmpty) {
      return '$installedVersion → $version';
    }
    return [
      version,
      if (lang.isNotEmpty) lang,
      if (author.isNotEmpty) author,
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    // Icon height = title line + 4px gap + meta line. The text heights come
    // from the resolved typography (lg fontSize 20 × height 1.75 = 35; xs2
    // fontSize 12 × height 1.0 = 12), so the icon grows to match the block
    // and its center aligns with the text block's center.
    final titleLineHeight =
        (typography.body.lg.fontSize ?? 20.0) *
        (typography.body.lg.height ?? 1.75);
    final metaLineHeight =
        (typography.body.xs2.fontSize ?? 12.0) *
        (typography.body.xs2.height ?? 1.0);
    const gap = 4.0;
    final textBlockHeight = titleLineHeight + gap + metaLineHeight;
    final iconSize = textBlockHeight;
    return MiruCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ExtensionIcon(
                  iconUrl: icon,
                  name: name,
                  size: iconSize,
                  typeIcon: typeIcon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.body.lg.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SmallBadge(label: type),
                          if (needUpdate) ...[
                            const SizedBox(width: 4),
                            SmallBadge(
                              label: 'common.update'.i18n,
                              variant: .outline,
                            ),
                          ],
                          if (isNSFW) ...[
                            const SizedBox(width: 4),
                            SmallBadge(
                              label: 'extension.nsfw'.i18n,
                              variant: .destructive,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _metaLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typography.body.xs2.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _ExtensionAction(
                  isInstalled: isInstalled,
                  needUpdate: needUpdate,
                  onInstall: onInstall,
                  onUninstall: onUninstall,
                ),
              ],
            ),
            if (description != null && description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: typography.body.xs.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 44px rounded square for the source icon on the muted surface — the
/// reference card's app-icon slot. Falls back to the [TextCover] glyph tile
/// when the source has no icon (or it fails to load).
class _ExtensionIcon extends StatelessWidget {
  const _ExtensionIcon({
    this.iconUrl,
    this.name = '',
    this.typeIcon,
    this.size = 44,
  });

  final String? iconUrl;
  final String name;
  final IconData? typeIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = context.theme.style.borderRadius.sm;
    final hasIcon = iconUrl != null && iconUrl!.isNotEmpty;
    final cover = TextCover(
      seed: name,
      icon: typeIcon,
      size: size,
      borderRadius: radius,
    );
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: size,
        height: size,
        color: context.theme.colors.muted,
        alignment: Alignment.center,
        child: hasIcon
            ? ImageWidget(
                imageUrl: iconUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                borderRadius: 0,
                errChild: cover,
              )
            : cover,
      ),
    );
  }
}

/// The card's trailing action: an Install button while uninstalled, an
/// Update button while an update waits, and a quiet "Installed" chip plus
/// an uninstall button once the source is current.
class _ExtensionAction extends StatelessWidget {
  const _ExtensionAction({
    required this.isInstalled,
    required this.needUpdate,
    required this.onInstall,
    required this.onUninstall,
  });

  final bool isInstalled;
  final bool needUpdate;
  final VoidCallback onInstall;
  final VoidCallback onUninstall;

  /// Same "healthy" green the search pills use for an up-to-date state.
  static const _upToDate = Color(0xFF34D399);

  FButtonContentStyleDelta get _contentStyle => .delta(
    // 44dp meets the mobile touch minimum (44x44) without growing the card:
    // the icon column beside it is already taller (~51px), so the row's
    // height is unchanged.
    constraints: const BoxConstraints(minHeight: 44),
    padding: EdgeInsetsGeometryDelta.value(
      const EdgeInsets.symmetric(horizontal: 12),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final labelStyle = context.theme.typography.body.xs2.copyWith(
      fontWeight: FontWeight.w600,
    );
    if (needUpdate) {
      return FButton(
        variant: .primary,
        onPress: onInstall,
        prefix: Icon(FLucideIcons.circleFadingArrowUp, size: 16),
        style: .delta(contentStyle: _contentStyle),
        child: Text('common.update'.i18n, style: labelStyle),
      );
    }
    if (!isInstalled) {
      return FButton(
        variant: .secondary,
        onPress: onInstall,
        prefix: Icon(FLucideIcons.download, size: 16),
        style: .delta(contentStyle: _contentStyle),
        child: Text('common.install'.i18n, style: labelStyle),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FBadge(
          variant: .secondary,
          style: .delta(
            padding: EdgeInsetsGeometryDelta.value(
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FLucideIcons.check, size: 14, color: _upToDate),
              const SizedBox(width: 4),
              Text('extension.installed'.i18n),
            ],
          ),
        ),
        const SizedBox(width: 4),
        FButton.icon(
          variant: .ghost,
          semanticsLabel: 'extension.uninstall'.i18n,
          style: .delta(
            contentStyle: FButtonContentStyleDelta.delta(
              // 44x44 touch target; the 16px glyph keeps the visual weight.
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            ),
          ),
          onPress: onUninstall,
          child: Icon(
            FLucideIcons.trash2,
            size: 16,
            color: colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Desktop grid tile - kept unchanged
class ExtensionGridTile extends StatelessWidget {
  const ExtensionGridTile({
    super.key,
    required this.name,
    required this.isNSFW,
    required this.version,
    required this.author,
    required this.type,
    required this.onInstall,
    required this.onUninstall,
    required this.isInstalled,
    required this.package,
    this.icon,
    this.typeIcon,
    this.description,
    required this.needUpdate,
    this.tags = const [],
  });
  final bool isNSFW;
  final String name;
  final String? icon;
  final IconData? typeIcon;
  final String version;
  final String author;
  final String type;
  final String package;
  final String? description;
  final List<String> tags;
  final void Function() onInstall;
  final void Function() onUninstall;
  final bool isInstalled;
  final bool needUpdate;

  @override
  Widget build(BuildContext context) {
    final badges = tags
        .map((e) => FBadge(variant: .outline, child: Text(e)))
        .toList();
    if (isNSFW) {
      badges.add(
        FBadge(variant: .destructive, child: Text('extension.nsfw'.i18n)),
      );
    }
    if (needUpdate) {
      badges.add(
        FBadge(
          variant: .outline,
          child: Text('extension.update_available'.i18n),
        ),
      );
    }
    return MiruCard(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.only(right: 15),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: ImageWidget(
                      imageUrl: icon,
                      width: 70,
                      height: 70,
                      // Same text-as-image cover as the mobile card, so a
                      // source without an icon never shows the alert glyph.
                      errChild: TextCover(
                        seed: name,
                        icon: typeIcon,
                        size: 70,
                        borderRadius: context.theme.style.borderRadius.sm,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FLabel(
                    layout: .vertical,
                    description: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        FBadge(variant: .secondary, child: Text(version)),
                        FBadge(variant: .secondary, child: Text(type)),
                      ],
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Intrinsic height: a fixed 55px box clipped two-row badge wraps.
            Wrap(spacing: 5, runSpacing: 5, children: badges),
            SizedBox(height: 10),
            // Single row: FButton stretches to fill, so a Wrap would push the
            // icon buttons onto a second row and overflow the fixed cell.
            if (isInstalled)
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      onPress: onUninstall,
                      prefix: Icon(FLucideIcons.trash2),
                      child: Text('extension.uninstall'.i18n),
                    ),
                  ),
                  if (needUpdate)
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 10),
                      child: FButton.icon(
                        onPress: onInstall,
                        child: Icon(FLucideIcons.circleFadingArrowUp),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsetsGeometry.only(left: 10),
                    child: FTooltip(
                      tipBuilder: (context, controller) =>
                          Text('common.settings'.i18n),
                      child: FButton.icon(
                        variant: .secondary,
                        onPress: () {
                          context.push(
                            "/extensionSettings",
                            extra: ExtensionSettingParam(
                              pkg: package,
                              name: name,
                            ),
                          );
                        },
                        child: Icon(FLucideIcons.cog),
                      ),
                    ),
                  ),
                ],
              )
            else
              FButton(
                onPress: onInstall,
                prefix: Icon(FLucideIcons.download),
                child: Text('common.install'.i18n),
              ),
          ],
        ),
      ),
    );
  }
}
