import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as pb_extension;

class WatchResult {
  final dynamic data;
  final pb_extension.ExtensionWatch? v2watch;

  WatchResult({required this.data, this.v2watch});
}
