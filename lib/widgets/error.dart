import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class ErrorDisplay extends StatelessWidget {
  final Object err;
  final StackTrace stack;
  final VoidCallback? onRefresh;
  late final String errTitle;
  late final String errContent;

  ErrorDisplay({
    super.key,
    required this.err,
    required this.stack,
    this.onRefresh,
  }) {
    errTitle = "Error: $err";
    errContent = stack.toString();
  }

  ErrorDisplay.network({
    super.key,
    required this.err,
    required this.stack,
    this.onRefresh,
  }) {
    if (err is! DioException) {
      errTitle = "Error: $err";
      errContent = stack.toString();
      return;
    }
    final e = err as DioException;
    errTitle = "Extension Network Error ";
    if (e.response != null) {
      errContent = e.response?.data;
    } else {
      errContent = e.message ?? e.stackTrace.toString();
    }
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
