import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:miru_alpha/utils/core/i18n.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:miru_alpha/widgets/index.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';

class SourceCodePage extends StatefulWidget {
  const SourceCodePage({super.key, required this.path});
  final String path;

  @override
  State<SourceCodePage> createState() => _SourceCodePageState();
}

class _SourceCodePageState extends State<SourceCodePage> {
  late final CodeForgeController controller;

  @override
  void initState() {
    super.initState();
    controller = CodeForgeController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return PopScope(
      canPop: bottomInset == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (bottomInset > 0) {
          FocusManager.instance.primaryFocus?.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        } else {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      },
      child: MiruScaffold(
        childPad: false,
        mobileHeader: SnapSheetNested.back(
          title: 'extension.source_code'.i18n,
          suffix: FButton.icon(
            variant: .ghost,
            child: Icon(FLucideIcons.save),
            onPress: () {
              controller.saveFile();
            },
          ),
        ),
        body: Material(
          child: CodeForge(
            controller: controller,
            editorTheme: atomOneDarkTheme,
            language: langJavascript,
            filePath: widget.path,
          ),
        ),
      ),
    );
  }
}
