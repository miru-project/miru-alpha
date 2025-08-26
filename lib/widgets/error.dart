import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class ErrorDisplay extends StatelessWidget {
  final Object err;
  final StackTrace stack;
  final VoidCallback? callback;

  const ErrorDisplay({super.key, required this.err, required this.stack, this.callback});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            FAccordion(
              children: [
                FAccordionItem(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Error: $err"),
                      Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                        child: FTooltip(
                          hoverEnterDuration: Duration(milliseconds: 300),
                          hover: true,
                          tipBuilder: (context, controller) => const Text('Reload'),
                          child: FButton.icon(style: FButtonStyle.outline(), onPress: callback, child: const Icon(FIcons.refreshCcw)),
                        ),
                      ),
                    ],
                  ),
                  child: Text(stack.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
