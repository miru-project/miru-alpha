import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:grpc/grpc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/application_controller_provider.dart';
import 'package:miru_alpha/widgets/index.dart';

class ErrorDisplay extends ConsumerWidget {
  final Object err;
  final StackTrace stack;
  final VoidCallback? onRefresh;
  final Widget? prefix;
  late final String errTitle;
  late final String errContent;

  ErrorDisplay({
    super.key,
    required this.err,
    required this.stack,
    this.onRefresh,
    this.prefix,
  }) {
    errTitle = "Error: $err";
    errContent = stack.toString();
  }

  ErrorDisplay.network({
    super.key,
    required this.err,
    required this.stack,
    this.onRefresh,
    this.prefix,
  }) {
    if (err is DioException) {
      final e = err as DioException;
      errTitle = "Extension Runtime Error ";
      final String? res = e.response?.data["message"];
      if (res != null) {
        errContent = res;
      } else {
        errContent = e.message ?? e.stackTrace.toString();
      }
      return;
    }
    errTitle = "Error: $err";
    errContent = stack.toString();
    return;
  }

  ErrorDisplay.grpc({
    super.key,
    required this.err,
    required this.stack,
    this.onRefresh,
    this.prefix,
  }) {
    if (err is GrpcError) {
      final e = err as GrpcError;
      errTitle = "GRPC Error ${e.code}: ${e.codeName}";
      errContent = e.message ?? "";
      return;
    }
    errTitle = "Error: $err";
    errContent = stack.toString();
    return;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlatformWidget(
      mobileWidget: MiruListView(
        padding: .symmetric(horizontal: 5),
        children: [
          Text(
            errTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(fontWeight: .bold, fontSize: 20),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 500,
            child: Text(
              errContent,
              style: TextStyle(color: context.theme.colors.mutedForeground),
            ),
          ),
          FButton(
            prefix: Icon(FLucideIcons.refreshCcw),
            onPress: () => onRefresh?.call(),
            child: Text('Reload'),
          ),
          SizedBox(height: 10),
          FButton(
            prefix: Icon(FLucideIcons.copy),
            variant: .secondary,
            onPress: () {
              Clipboard.setData(ClipboardData(text: errContent));
            },
            child: Text('Copy'),
          ),
          SizedBox(height: 100),
        ],
      ),
      desktopWidget: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 30, vertical: 20),
          child: FTheme(
            data: ref.watch(
              applicationControllerProvider.select((e) => e.themeData),
            ),
            child: FAccordion(
              children: [
                FAccordionItem(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      prefix ?? const SizedBox.shrink(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errTitle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Padding(
                        padding: .symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            FTooltip(
                              hover: true,
                              tipBuilder: (context, controller) =>
                                  const Text('Reload'),
                              child: FButton.icon(
                                variant: FButtonVariant.outline,
                                onPress: onRefresh,
                                child: const Icon(FLucideIcons.refreshCcw),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FTooltip(
                              hover: true,
                              tipBuilder: (context, controller) =>
                                  const Text('Copy'),
                              child: FButton.icon(
                                variant: FButtonVariant.outline,
                                onPress: () {
                                  Clipboard.setData(
                                    ClipboardData(text: errContent),
                                  );
                                },
                                child: const Icon(FLucideIcons.copy),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  child: Text(
                    errContent,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
