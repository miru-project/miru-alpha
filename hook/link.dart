import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await link(args, (input, output) async {
    // The build hook already outputs the necessary code assets (libffmpeg.so)
    // No additional linking is needed - just pass through the assets
    // Copy all code assets from build to link output
    for (final asset in input.assets.code) {
      output.assets.code.add(asset);
    }
  });
}
