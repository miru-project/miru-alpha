// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:forui/forui.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:miru_app_new/pages/webview/desktop_webview.dart';
// import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
// import 'package:miru_app_new/utils/core/log.dart';
// import 'package:miru_app_new/utils/store/storage_index.dart';
// import 'package:miru_app_new/widgets/core/inner_card.dart';
// import 'package:miru_app_new/widgets/core/search_filter_card.dart';
// import 'package:miru_app_new/pages/search/widget/desktop_search_list_tile.dart';


// class DesktopExtensionSearch extends StatelessWidget {
//   final Set<String> pinnedExtensions;
//   final List<ExtensionMetaData> metaData;
//   const DesktopExtensionSearch({super.key,required this.pinnedExtensions, required this.meta});
//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(child: SizedBox(height: 150)),
//               if (pinnedExtensions.isNotEmpty)
//                 SliverToBoxAdapter(
//                   child: InnerCard(
//                     title: 'Pinned',
//                     subtitle: 'Pinned extensions ',
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemBuilder: (context, index) {
//                         final pinnedPkg = pinnedExtensions.value.elementAt(
//                           index,
//                         );
//                         final ext = metaData
//                             .where((ext) => ext.packageName == pinnedPkg)
//                             .first;
//                         logger.info('Pinned ext: ${ext.packageName}');
//                         return DesktopSearchListTile(
//                           ext: ext,
//                           trailing: FButton.icon(
//                             selected: true,
//                             onPress: () {
//                               final newSet = {...pinnedExtensions.value};
//                               if (newSet.contains(ext.packageName)) {
//                                 newSet.remove(ext.packageName);
//                               } else {
//                                 newSet.add(ext.packageName);
//                               }
//                               pinnedExtensions.value = newSet;
//                               MiruSettings.setSettingSync(
//                                 SettingKey.pinnedExtension,
//                                 newSet.toString(),
//                               );
//                             },
//                             child:
//                                 pinnedExtensions.value.contains(ext.packageName)
//                                 ? Icon(FIcons.pinOff)
//                                 : Icon(FIcons.pin),
//                           ),
//                         );
//                       },
//                       itemCount: pinnedExtensions.value.length,
//                     ),
//                   ),
//                 ),
//               SliverToBoxAdapter(child: SizedBox(height: 20)),
//               SliverToBoxAdapter(
//                 child: InnerCard(
//                   title: 'Extension',
//                   subtitle: 'Extensions that already installed',
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemBuilder: (context, index) {
//                       final ext = metaData[index];
//                       return DesktopSearchListTile(
//                         ext: ext,
//                         trailing: Row(
//                           children: [
//                             FButton.icon(
//                               style: FButtonStyle.ghost(),
//                               onPress: () => openWebview(ext),
//                               child: Icon(FIcons.globe),
//                             ),
//                             SizedBox(width: 8),
//                             FButton.icon(
//                               selected: true,
//                               onPress: () {
//                                 final newSet = {...pinnedExtensions.value};
//                                 if (newSet.contains(ext.packageName)) {
//                                   newSet.remove(ext.packageName);
//                                 } else {
//                                   newSet.add(ext.packageName);
//                                 }
//                                 pinnedExtensions.value = newSet;
//                                 MiruSettings.setSettingSync(
//                                   SettingKey.pinnedExtension,
//                                   newSet.toString(),
//                                 );
//                               },
//                               child:
//                                   pinnedExtensions.value.contains(
//                                     ext.packageName,
//                                   )
//                                   ? Icon(FIcons.pinOff)
//                                   : Icon(FIcons.pin),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                     itemCount: metaData.length,
//                   ),
//                 ),
//               ),
//             ],
//           )
//   }
// }