import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:miru_alpha/provider/cast/dlna_cast_provider.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';

import 'package:miru_alpha/ui/core/core/toast.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'dart:ui';

/// DLNA cast flow for the portrait player: the Cast button opens this sheet,
/// the SSDP search runs while it is open, and picking a renderer pushes the
/// currently playing URL to it (SetAVTransportURI + Play) and pauses the
/// local player.
Future<void> showDlnaCastSheet(
  BuildContext context, {
  required VideoPlayerNotifierProvider vidPr,
  required String title,
}) {
  return showFSheet<void>(
    context: context,
    side: .btt,
    // Frosted-glass backdrop — same treatment as the settings sheet.
    style: FModalSheetStyleDelta.delta(
      barrierFilter: (context, animation) =>
          ImageFilter.blur(sigmaX: 10.0 * animation, sigmaY: 10.0 * animation),
    ),
    builder: (sheetContext) => SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.heightOf(context) * 0.55,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: ColoredBox(
            color: sheetContext.theme.colors.background.withAlpha(216),
            child: DlnaCastPanel(vidPr: vidPr, title: title),
          ),
        ),
      ),
    ),
  );
}

class DlnaCastPanel extends ConsumerStatefulWidget {
  const DlnaCastPanel({super.key, required this.vidPr, required this.title});

  final VideoPlayerNotifierProvider vidPr;
  final String title;

  @override
  ConsumerState<DlnaCastPanel> createState() => _DlnaCastPanelState();
}

class _DlnaCastPanelState extends ConsumerState<DlnaCastPanel> {
  /// The keep-alive cast notifier, captured while mounted: dispose() must
  /// not read through `ref` (riverpod asserts on reads from an unmounted
  /// element — the sheet closing mid-cast crashed the widget tree).
  late final DlnaCast _cast;

  @override
  void initState() {
    super.initState();
    _cast = ref.read(dlnaCastProvider.notifier);
    // The SSDP socket lives only while the sheet is open; the provider is
    // keep-alive, so the discovered devices and the connected session
    // survive the close and the next open rescans onto the kept list.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cast.startScan();
    });
  }

  @override
  void dispose() {
    // Close the socket; the device list and connection state stay in the
    // keep-alive provider.
    _cast.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final castState = ref.watch(dlnaCastProvider);
    final colors = context.theme.colors;
    final connected = castState.connected();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Text(
                // watch.cast (投屏 — casting to a device), NOT media.cast
                // (角色 — a show's actor/character list).
                'watch.cast'.i18n,
                style: context.theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              FButton.icon(
                variant: .ghost,
                onPress: () => Navigator.of(context).pop(),
                child: const Icon(FLucideIcons.x, size: 18),
              ),
            ],
          ),
        ),
        // Connected banner: the renderer + its transport controls.
        if (connected != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: colors.primary.withAlpha(26),
                border: Border.all(color: colors.primary.withAlpha(128)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(FLucideIcons.cast, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      connected.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FButton.icon(
                    variant: .ghost,
                    onPress: _cast.play,
                    child: const Icon(FLucideIcons.play, size: 16),
                  ),
                  FButton.icon(
                    variant: .ghost,
                    onPress: _cast.pause,
                    child: const Icon(FLucideIcons.pause, size: 16),
                  ),
                  FButton.icon(
                    variant: .ghost,
                    onPress: () async {
                      await _cast.disconnect();
                      if (mounted) {
                        showSimpleToast('watch.cast_stopped'.i18n);
                      }
                    },
                    child: const Icon(FLucideIcons.square, size: 14),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Text(
            castState.searching
                ? 'watch.cast_searching'.i18n
                : 'watch.cast_devices'.i18n,
            style: context.theme.typography.body.xs.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ),
        Expanded(
          child: castState.devices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (castState.searching)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: FCircularProgress(),
                          ),
                        ),
                      Text(
                        castState.searching
                            ? 'watch.cast_searching'.i18n
                            : 'watch.cast_no_devices'.i18n,
                        style: context.theme.typography.body.sm.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: castState.devices.length,
                  itemBuilder: (context, index) {
                    final device = castState.devices[index];
                    final selected = device.id == castState.connectedId;
                    final connecting = device.id == castState.connectingId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FTile(
                        selected: selected,
                        // The connecting target is untappable while the
                        // handshake runs — a second tap would stack two
                        // SetAVTransportURI calls.
                        onPress: selected || connecting
                            ? null
                            : () => _castTo(device),
                        prefix: connecting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: FCircularProgress(),
                              )
                            : const Icon(FLucideIcons.monitorPlay, size: 18),
                        title: Text(device.name),
                        subtitle: connecting
                            ? Text(
                                'watch.cast_connecting'.i18n,
                                style: context.theme.typography.body.xs
                                    .copyWith(color: colors.mutedForeground),
                              )
                            : null,
                        suffix: selected
                            ? Icon(
                                FLucideIcons.cast,
                                size: 16,
                                color: colors.primary,
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _castTo(DlnaDeviceUi device) async {
    final player = ref.read(widget.vidPr.notifier);
    final url = player.vidController.dataSource;
    if (url.isEmpty) return;
    // ALL traffic hot-proxies through the local media server: the in-process
    // ffmpeg remuxes every source to MPEG-TS, and the cast provider walks a
    // protocolInfo ladder over the same bytes. The app player stays the
    // master surface — its play/pause/seek/episode actions forward to the
    // renderer and the renderer's transport state echoes back (two-way
    // sync).
    final ok = await _cast.cast(
      deviceId: device.id,
      url: url,
      title: widget.title,
      // The extension's HTTP headers travel with the cast: the engine's
      // fetches must pass the same gates the local player passes.
      headers: player.streamHeaders,
    );
    // The user asked for explicit feedback: connecting state on the tile
    // (driven by connectingId), then a toast for the outcome.
    if (ok) {
      showSimpleToast('watch.cast_connected'.fill({'name': device.name}));
    } else {
      final reason = ref.read(dlnaCastProvider).error;
      showSimpleToast(
        reason ?? 'watch.cast_failed'.fill({'name': device.name}),
      );
    }
  }
}
