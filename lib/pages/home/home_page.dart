import 'package:collection/collection.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_app_new/model/extension_meta_data.dart';
import 'package:miru_app_new/provider/extension_page_notifier_provider.dart';
import 'package:miru_app_new/model/index.dart';
import 'package:miru_app_new/utils/core/device_util.dart';

export 'library_page.dart';

class HomePageCarousel extends ConsumerWidget {
  const HomePageCarousel({super.key, required this.item});
  final History item;

  String convertTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.read(extensionPageProvider).metaData;
    final ExtensionMeta? ext = meta.firstWhereOrNull(
      (element) => element.packageName == item.package,
    );
    return FCard.raw(
      child: Row(
        children: [
          Flexible(
            child: ExtendedImage.network(
              fit: BoxFit.fitHeight,
              item.cover ?? '',
            ),
          ),
          const SizedBox(width: 15),
          SizedBox(
            // width: DeviceUtil.getWidth(context) * .2,
            child: DefaultTextStyle(
              style: TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              child: SizedBox(
                width: DeviceUtil.device(
                  mobile: DeviceUtil.getWidth(context) - 200,
                  desktop: DeviceUtil.getWidth(context) * .25,
                  context: context,
                ),
                child: Padding(
                  padding: .all(10),
                  child: Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.title,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Text(
                        item.episodeTitle,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            ExtendedImage.network(
                              loadStateChanged: (state) {
                                if (state.extendedImageLoadState ==
                                    LoadState.failed) {
                                  return const Icon(Icons.error);
                                }
                                return null;
                              },
                              cache: true,
                              ext?.icon ?? '',
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ext?.name ?? "Name Not Found",
                              style: const TextStyle(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(convertTime(item.date)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
