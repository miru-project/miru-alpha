import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:grpc/grpc.dart';

class ErrorDisplay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 30, vertical: 20),
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
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: FTooltip(
                      hoverEnterDuration: Duration(milliseconds: 300),
                      hover: true,
                      tipBuilder: (context, controller) => const Text('Reload'),
                      child: FButton.icon(
                        style: FButtonStyle.outline(),
                        onPress: onRefresh,
                        child: const Icon(FIcons.refreshCcw),
                      ),
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
    );
  }
}
