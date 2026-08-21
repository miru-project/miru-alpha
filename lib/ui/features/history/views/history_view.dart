import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/model.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/features/history_favorite/shared/list_helpers.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key, this.type});

  /// Optional type filter applied on load (e.g. `/home/history?type=media.manga`).
  final ExtensionType? type;

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  @override
  void initState() {
    super.initState();
    if (widget.type != null) {
      Future.microtask(
        () => ref.read(historyPageProvider.notifier).setTypeFilter(widget.type),
      );
    }
  }

  void _openDetail(BuildContext context, History history) {
    final meta = findMeta(ref, history.package);
    if (meta == null) return;
    openDetail(context, meta, history.url);
  }

  Future<void> _confirmDelete(BuildContext context, History history) async {
    await showDeleteConfirmDialog(
      context: context,
      ref: ref,
      title: 'common.history'.i18n,
      body: 'common.history_delete_confirm'.i18n,
      onConfirm: () =>
          ref.read(historyPageProvider.notifier).deleteHistory(history),
    );
  }

  Widget _buildTile(BuildContext context, History history) {
    final meta = findMeta(ref, history.package);
    final subtitle = meta?.name ?? 'common.package_not_found'.i18n;
    final progress = history.totalProgress > 0
        ? history.progress / history.totalProgress
        : 0.0;
    return Dismissible(
      key: Key(history.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: context.theme.colors.destructive,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          FLucideIcons.trash2,
          color: context.theme.colors.background,
        ),
      ),
      confirmDismiss: (_) async {
        await _confirmDelete(context, history);
        return false;
      },
      child: MiruMobileTile(
        title: history.title,
        subtitle: subtitle,
        imageUrl: history.cover,
        onTap: () => _openDetail(context, history),
        onLongPress: () {
          showRemoveSheet(
            context: context,
            title: history.title,
            actionLabel: 'common.delete'.i18n,
            actionIcon: FLucideIcons.trash2,
            onRemove: () => _confirmDelete(context, history),
          );
        },
        stackLabel: progress > 0 ? Text('${(progress * 100).toInt()}%') : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final histories = ref.watch(
      historyPageProvider.select((s) => s.filteredHistory),
    );

    return DeviceUtil.deviceWidget(
      context: context,
      desktop: _HistoryDesktopView(histories: histories, onTap: _openDetail),
      mobile: _HistoryMobileView(histories: histories, buildTile: _buildTile),
    );
  }
}

class _HistoryDesktopView extends ConsumerWidget {
  const _HistoryDesktopView({required this.histories, required this.onTap});

  final List<History> histories;
  final void Function(BuildContext, History) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MiruScaffold.desktop(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverToBoxAdapter(
              child: Text(
                'common.history'.i18n,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          if (histories.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: FLucideIcons.clock,
                message: 'common.history_empty'.i18n,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(15.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: DeviceUtil.getWidth(context) * .875 ~/ 220,
                  childAspectRatio: 0.6,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final history = histories[index];
                  return MiruDesktopGridTile(
                    title: history.title,
                    titleMaxline: 2,
                    subtitle:
                        ref
                            .watch(
                              extensionPageProvider.select((s) => s.metaData),
                            )
                            .where((e) => e.packageName == history.package)
                            .firstOrNull
                            ?.name ??
                        'common.package_not_found'.i18n,
                    imageUrl: history.cover,
                    onTap: () => onTap(context, history),
                  );
                }, childCount: histories.length),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryMobileView extends StatelessWidget {
  const _HistoryMobileView({required this.histories, required this.buildTile});

  final List<History> histories;
  final Widget Function(BuildContext, History) buildTile;

  @override
  Widget build(BuildContext context) {
    final axisCnt = DeviceUtil.isMobileLayout(context)
        ? (MediaQuery.of(context).size.width ~/ 140).clamp(2, 8)
        : (MediaQuery.of(context).size.width * .875 ~/ 160).clamp(2, 12);

    return MiruScaffold.mobile(
      childPad: true,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: StaticSliverHeaderDelegate(
            maxExtent: 56,
            minExtent: 56,
            child: DecoratedBox(
              decoration: context.theme.scaffoldStyle.headerDecoration,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Row(
                  children: [
                    const HeaderBack(),
                    Expanded(
                      child: Text(
                        'common.history'.i18n,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (histories.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              icon: FLucideIcons.clock,
              message: 'common.history_empty'.i18n,
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              8,
              8,
              8,
              DeviceUtil.isMobileLayout(context) ? 190 : 16,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: axisCnt,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => buildTile(context, histories[index]),
                childCount: histories.length,
              ),
            ),
          ),
      ],
    );
  }
}
