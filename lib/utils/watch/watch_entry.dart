import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/model/index.dart';

// class WatchEntry {
//   static handlePageRoute(ExtensionApiV1 extension, BuildContext context) {
//     switch (extension.extension.type) {
//       case ExtensionType.bangumi:
//         context.go('/bangumi');
//         break;
//       case ExtensionType.manga:
//         context.go('/manga');
//         break;
//       case ExtensionType.fikushon:
//         context.go('/fikushon');
//         break;
//     }
//   }
// }

class WatchParams {
  const WatchParams({
    required this.meta,
    required this.type,
    required this.url,
    required this.selectedGroupIndex,
    required this.selectedEpisodeIndex,
    required this.name,
    required this.detailImageUrl,
    required this.detailUrl,
    required this.epGroup,
  });
  final ExtensionMeta meta;
  final String url;
  final List<ExtensionEpisodeGroup>? epGroup;
  final int selectedGroupIndex;
  final String detailImageUrl;
  final int selectedEpisodeIndex;
  final String detailUrl;
  final ExtensionType type;
  final String name;
}

class DetailParam {
  const DetailParam({required this.meta, required this.url});
  final ExtensionMeta meta;
  final String url;
}
