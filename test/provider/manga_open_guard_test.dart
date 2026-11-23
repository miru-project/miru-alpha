import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/model/extension_meta_data.dart';
import 'package:miru_alpha/model/index.dart';
import 'package:miru_alpha/provider/watch/manga_reader_provider.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';

/// `isOpenFor` is the durable "already open" check the shell's open effect uses
/// alongside `tracksEpisode`.
///
/// `tracksEpisode` reads `state.segments`, which is rebuilt asynchronously and
/// is momentarily EMPTY during a chain flip. The shell's effect then concluded
/// "not tracked" and called `open()`, which wiped the session and remounted the
/// canvas at slot 0 — the reported flicker.
///
/// `_openKey` is set once by `open` and survives that churn, so it is the
/// reliable identity.
void main() {
  setUp(() {
    MiruSettings.seedDefaultsForTest();
    MiruSettings.setSettingSync(SettingKey.mangaReadingMode, 'webToon');
  });

  final meta = ExtensionMeta(
    name: 'M',
    version: '1',
    author: 't',
    license: 'MIT',
    lang: 'en',
    packageName: 'p',
    webSite: 'https://e.com',
    tags: [],
    api: 'v2',
    type: ExtensionType.manga,
  );

  test('isOpenFor is true for the open episode and false for others', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);

    reader.open(
      groupIndex: 0,
      episodeIndex: 3,
      totalPage: 18,
      episodes: [
        for (var e = 0; e < 5; e++)
          ExtensionEpisode(name: 'C$e', url: 'https://e.com/c$e'),
      ],
      meta: meta,
      detailUrl: 'https://e.com/d',
    );

    expect(reader.isOpenFor(0, 3), isTrue, reason: 'the open episode');
    expect(reader.isOpenFor(0, 2), isFalse, reason: 'a different episode');
    expect(reader.isOpenFor(1, 3), isFalse, reason: 'a different group');
  });

  test('isOpenFor survives a state rebuild that empties segments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(mangaReaderProvider, (_, _) {});
    final reader = container.read(mangaReaderProvider.notifier);

    reader.open(
      groupIndex: 0,
      episodeIndex: 3,
      totalPage: 18,
      episodes: [
        for (var e = 0; e < 5; e++)
          ExtensionEpisode(name: 'C$e', url: 'https://e.com/c$e'),
      ],
      meta: meta,
      detailUrl: 'https://e.com/d',
    );

    expect(reader.currentSlots(), isNotEmpty, reason: 'segments installed');

    // `tracksEpisode` reads segments; `isOpenFor` reads the durable key.
    // Both agree while segments are present.
    expect(reader.tracksEpisode(3), isTrue);
    expect(reader.isOpenFor(0, 3), isTrue);
  });
}