import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';

/// Tracks the extension currently displayed on the `/search/single` page.
///
/// The app-wide global search bar (window edge) reads this so it can switch
/// into single-extension mode — showing the extension name and offering
/// extension-specific filters — instead of the global search mode.
class CurrentSingleExtensionNotifier extends Notifier<ExtensionMeta?> {
  @override
  ExtensionMeta? build() => null;

  void setExtension(ExtensionMeta? meta) => state = meta;
}

final currentSingleExtensionProvider =
    NotifierProvider<CurrentSingleExtensionNotifier, ExtensionMeta?>(
  CurrentSingleExtensionNotifier.new,
);
