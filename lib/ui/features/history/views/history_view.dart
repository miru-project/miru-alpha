import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/user_data.dart';
import 'package:miru_alpha/provider/extension_page_notifier_provider.dart';
import 'package:miru_alpha/provider/home/history_page_provider.dart';
import 'package:miru_alpha/ui/core/index.dart';
import 'package:miru_alpha/ui/core/empty_state.dart';
import 'package:miru_alpha/utils/core/device_util.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:miru_alpha/utils/router/page_entry.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  void _openDetail(BuildContext context, History history) {
    final meta = ref
        .read(extensionPageProvider)
        .metaData
        .where((e) => e.packageName == history.package)
        .firstOrNull;
    if (meta == null) return;
    context.push(
      '/detail',
      extra: DetailParam(meta: meta, url: history.url),
    );
  }

  Future<void> _confirmDelete(BuildContext context, History history) async {
    final confirmed = await showMiruDialog<bool>(
      context: context,
      title: Text('common.history'.i18n),
      body: Text('common.history_delete_confirm'.i18n),
      actions: [
        FButton(
          variant: FButtonVariant.secondary,
          onPress: () => Navigator.pop(context, false),
          child: Text('common.cancel'.i18n),
        ),
        FButton(
          variant: FButtonVariant.destructive,
          onPress: () => Navigator.pop(context, true),
          child: Text('common.delete'.i18n),
        ),
      ],
    );
    if (confirmed == true) {
      ref.read(historyPageProvider.notifier).deleteHistory(history);
    }
  }

  Widget _buildTile(BuildContext context, History history) {
    final meta = ref
        .read(extensionPageProvider)
        .metaData
        .where((e) => e.packageName == history.package)
        .firstOrNull;
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
          showFSheet(
            context: context,
            side: .btt,
            builder: (context) => FCard.raw(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: 20,
                ),
                child: FTileGroup(
                  label: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(history.title),
                  ),
                  children: [
                    FTile(
                      prefix: Icon(FLucideIcons.trash2),
                      title: Text('common.delete'.i18n),
                      onPress: () {
                        Navigator.pop(context);
                        _confirmDelete(context, history);
                      },
                    ),
                  ],
                ),
              ),
            ),
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
                (context, index) => _buildTile(context, histories[index]),
                childCount: histories.length,
              ),
            ),
          ),
      ],
    );
  }
}
