import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/data/services/extension_service.dart';

void main() {
  group('ExtensionService.parseRepoIndex', () {
    test('reads nsfw from the fetched repo index', () {
      final repos = ExtensionService.parseRepoIndex(
        jsonEncode({
          'https://example.com/index.json': [
            {'name': 'adult', 'package': 'adult.net', 'nsfw': true},
            {'name': 'clean', 'package': 'clean.net', 'nsfw': false},
          ],
        }),
      );

      expect(repos, hasLength(1));
      expect(repos.first.url, 'https://example.com/index.json');
      expect(
        repos.first.extensions.map((e) => e.nsfw).toList(),
        [true, false],
      );
    });

    test('accepts the string and 1 forms a repo may publish', () {
      expect(ExtensionService.parseNsfw('true'), isTrue);
      expect(ExtensionService.parseNsfw('True'), isTrue);
      expect(ExtensionService.parseNsfw('1'), isTrue);
      expect(ExtensionService.parseNsfw('false'), isFalse);
    });

    test('treats an absent flag as false', () {
      final repos = ExtensionService.parseRepoIndex(
        jsonEncode({
          'https://example.com/index.json': [
            {'name': 'clean', 'package': 'clean.net'},
          ],
        }),
      );

      expect(ExtensionService.parseNsfw(null), isFalse);
      expect(repos.first.extensions.single.nsfw, isFalse);
    });
  });
}
