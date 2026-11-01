import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/miru_core/core.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/utils/core/i18n.dart';

/// The 800ms easeInOut slide/opacity pair the mobile detail page's pinned
/// sliver header uses for its title reveal — reused here so the title swap
/// speaks the same motion language.
const _swapDuration = Duration(milliseconds: 800);

/// Title block driven by the backend connection gate: while the core is
/// connecting, the connecting status (`Connecting` + `server:port`) renders;
/// once online the status slides up and out as [title] slides up into place.
///
/// Mobile mounts it in the home top bar (over `Home`), the desktop sidebar
/// header over the `Miru Alpha` brand row.
class BackendConnectionTitle extends ConsumerWidget {
  const BackendConnectionTitle({super.key, required this.title});

  /// The real title, shown once the backend is online.
  final Widget title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(backendConnectionProvider).hasValue;
    final typography = context.theme.typography;
    final colors = context.theme.colors;

    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        // Connecting status: leaves upward (and fades) when online.
        AnimatedSlide(
          offset: online ? const Offset(0, -1.1) : Offset.zero,
          duration: _swapDuration,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: online ? 0 : 1,
            duration: _swapDuration,
            curve: Curves.easeInOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'common.connecting'.i18n,
                  style: typography.body.lg.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                Text(
                  '${Core.host}:${Core.port}',
                  style: typography.body.xs2.copyWith(
                    color: colors.mutedForeground,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Real title: rises into place when online.
        AnimatedSlide(
          offset: online ? Offset.zero : const Offset(0, 1.1),
          duration: _swapDuration,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: online ? 1 : 0,
            duration: _swapDuration,
            curve: Curves.easeInOut,
            child: title,
          ),
        ),
      ],
    );
  }
}
