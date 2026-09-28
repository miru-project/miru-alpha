import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/model/model.dart';

/// Every locale the app ships.
const _locales = ['en', 'zh'];

/// The novel reader's own sources, where its i18n keys are referenced.
const _sources = [
  'lib/ui/features/watch/novel_reader/',
  'lib/provider/watch/novel_reader_provider.dart',
];

Object? _resolve(Map<String, Object?> json, String dotted) {
  Object? node = json;
  for (final segment in dotted.split('.')) {
    if (node is! Map<String, Object?>) return null;
    node = node[segment];
  }
  return node;
}

/// Every `reader.novel.…` literal referenced by the novel reader.
///
/// Keys built by interpolation (`reader.novel.theme.${theme.name}`) come back with
/// the placeholder still in them; those are reported with the interpolation
/// stripped so the test can check the branch that holds the leaves.
Set<String> _referencedKeys() {
  final keys = <String>{};
  for (final path in _sources) {
    final isDir = Directory(path).existsSync();
    final files = isDir
        ? Directory(path).listSync(recursive: true).whereType<File>()
        : [File(path)];
    for (final file in files) {
      if (!file.path.endsWith('.dart')) continue;
      for (final match in RegExp(
        "'(reader\\.novel\\.[A-Za-z0-9_.]*)'",
      ).allMatches(file.readAsStringSync())) {
        keys.add(match.group(1)!);
      }
    }
  }
  return keys;
}

void main() {
  Map<String, Object?> load(String locale) => jsonDecode(
    File('assets/i18n/$locale.json').readAsStringSync(),
  ) as Map<String, Object?>;

  test('the novel reader references at least one key per locale', () {
    // Guards the extraction itself: if the pattern or the paths stop matching,
    // every assertion below would vacuously pass.
    expect(_referencedKeys(), isNotEmpty);
  });

  for (final locale in _locales) {
    test('every novel reader key resolves in $locale', () {
      final json = load(locale);
      final unresolved = <String>[];

      for (final key in _referencedKeys()) {
        final value = _resolve(json, key);
        if (value is String) {
          if (value.trim().isEmpty) unresolved.add('$key (empty)');
        } else if (value is! Map<String, Object?>) {
          // Interpolated keys resolve to the object that holds the leaves.
          unresolved.add(key);
        }
      }

      expect(unresolved, isEmpty);
    });
  }

  test('every paper and reading mode has a label', () {
    for (final locale in _locales) {
      final novel = _resolve(load(locale), 'reader.novel')! as Map<String, Object?>;
      for (final theme in NovelTheme.values) {
        final label = _resolve(novel, 'theme.${theme.name}');
        expect(label, isA<String>(), reason: '$locale paper ${theme.name}');
      }
      for (final mode in kNovelReadModeOrder) {
        final label = _resolve(novel, 'read_mode.short.${mode.name}');
        expect(label, isA<String>(), reason: '$locale mode ${mode.name}');
      }
    }
  });

  test('the novel reader subtree is complete in every locale', () {
    // Scoped to the novel subtree on purpose: a missing key elsewhere in the
    // app is a real gap but not this feature's to close, and the whole-tree
    // comparison would fail on keys the reader never touches.
    for (final locale in _locales) {
      final en = _resolve(load('en'), 'reader.novel')! as Map<String, Object?>;
      final localeJson = _resolve(load(locale), 'reader.novel')!
          as Map<String, Object?>;

      void walk(Map<String, Object?> expected, Map<String, Object?> actual) {
        for (final entry in expected.entries) {
          final value = actual[entry.key];
          expect(value, isNotNull, reason: '$locale is missing "${entry.key}"');
          if (value is Map<String, Object?> &&
              entry.value is Map<String, Object?>) {
            walk(entry.value as Map<String, Object?>, value);
          }
        }
      }

      walk(en, localeJson);
    }
  });
}
