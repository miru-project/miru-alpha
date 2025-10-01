import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/button.dart';

class ExtensionListTile extends StatefulWidget {
  const ExtensionListTile({
    super.key,
    required this.name,
    this.icon,
    required this.version,
    required this.author,
    required this.type,
    required this.onUninstall,
    required this.onInstall,
  });
  final String name;
  final String? icon;
  final String version;
  final String author;
  final String type;
  final VoidCallback onUninstall;
  final VoidCallback onInstall;

  @override
  State<ExtensionListTile> createState() => _ExtensionListTileState();
}

class _ExtensionListTileState extends State<ExtensionListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (widget.icon != null)
                  ExtendedImage.network(
                    widget.icon!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: const TextStyle(fontSize: 18)),
                    Text(
                      widget.author,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              widget.version,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              widget.type,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Button(onPressed: widget.onUninstall, child: const Text('Uninstall')),
        ],
      ),
    );
  }
}

class ExtensionGridTile extends StatelessWidget {
  const ExtensionGridTile({
    super.key,
    required this.name,
    required this.isNSFW,
    this.icon,
    required this.version,
    required this.author,
    required this.type,
    this.description,
    required this.onInstall,
    required this.onUninstall,
    required this.isInstalled,
    this.tags = const [],
  });
  final bool isNSFW;
  final String name;
  final String? icon;
  final String version;
  final String author;
  final String type;
  final String? description;
  final List<String> tags;
  final void Function() onInstall;
  final void Function() onUninstall;
  final bool isInstalled;
  @override
  Widget build(BuildContext context) {
    final badges = tags
        .map((e) => FBadge(style: FBadgeStyle.outline(), child: Text(e)))
        .toList();
    if (isNSFW) {
      badges.add(FBadge(style: FBadgeStyle.destructive(), child: Text('NSFW')));
    }
    return Center(
      child: SizedBox(
        width: 400,
        height: 240,
        child: FCard.raw(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.only(right: 15),
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: FCard.raw(
                          child: icon == null
                              ? Placeholder()
                              : ExtendedImage.network(
                                  icon!,
                                  cache: true,
                                  loadStateChanged: (state) {
                                    if (state.extendedImageLoadState ==
                                        LoadState.failed) {
                                      return Placeholder();
                                    }

                                    return null;
                                  },
                                ),
                        ),
                      ),
                    ),
                    FLabel(
                      label: Row(
                        children: [
                          FBadge(
                            style: FBadgeStyle.secondary(),
                            child: Text(version),
                          ),
                          SizedBox(width: 5),
                          FBadge(child: Text(type)),
                        ],
                      ),
                      axis: Axis.vertical,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 55,
                  child: Wrap(spacing: 5, runSpacing: 5, children: badges),
                ),
                if (isInstalled)
                  FButton(
                    onPress: onUninstall,
                    prefix: Icon(FIcons.trash2),
                    child: Text('Uninstall'),
                  )
                else
                  FButton(
                    onPress: onInstall,
                    prefix: Icon(FIcons.download),
                    child: Text('Install'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    // Container(
    //   margin: const EdgeInsets.all(10),
    //   clipBehavior: Clip.antiAlias,
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(8),
    //     border: Border.all(
    //       color:
    //           context.moonTheme?.tabBarTheme.colors.selectedPillTabColor
    //               .withAlpha(100) ??
    //           Colors.black12,
    //       width: 1,
    //     ),
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Expanded(
    //         child: Container(
    //           padding: const EdgeInsets.all(16),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Row(
    //                 children: [
    //                   if (icon != null)
    //                     ExtendedImage.network(
    //                       icon!,
    //                       cache: true,
    //                       width: 50,
    //                       height: 50,
    //                       fit: BoxFit.cover,
    //                     ),
    //                   const SizedBox(width: 8),
    //                   Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Text(name),
    //                       Text(
    //                         author,
    //                         style: const TextStyle(color: Colors.grey),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //               const SizedBox(height: 8),
    //               Text(description ?? 'No description'),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Container(
    //         padding: const EdgeInsets.all(8),
    //         color: context.moonTheme?.tabBarTheme.colors.selectedPillTabColor
    //             .withValues(alpha: .5),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               version,
    //               style: TextStyle(
    //                 color: context.moonTheme?.textInputTheme.colors.textColor,
    //               ),
    //             ),
    //             Row(
    //               children: [
    //                 if (isInstalled)
    //                   MoonButton(
    //                     padding: const EdgeInsets.symmetric(horizontal: 8),
    //                     onTap: onUninstall,
    //                     label: const Text('Uninstall'),
    //                   ),
    //                 MoonButton(
    //                   padding: const EdgeInsets.symmetric(horizontal: 8),
    //                   onTap: onInstall,
    //                   label: const Text('Install'),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
