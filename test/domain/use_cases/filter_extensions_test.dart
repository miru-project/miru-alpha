import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/domain/models/extension.dart';
import 'package:miru_alpha/domain/use_cases/filter_extensions.dart';

void main() {
  group('FilterExtensionsUseCase', () {
    final sampleRepos = [
      DomainExtensionRepo(
        name: 'Repo A',
        url: 'https://example.com/a',
        extensions: [
          DomainExtensionMeta(
            name: 'Manga Ext',
            version: '1.0',
            author: 'Author',
            license: 'MIT',
            lang: 'en',
            packageName: 'manga.ext',
            webSite: '',
            type: ExtensionType.manga,
          ),
          DomainExtensionMeta(
            name: 'Bangumi Ext',
            version: '1.0',
            author: 'Author',
            license: 'MIT',
            lang: 'en',
            packageName: 'bangumi.ext',
            webSite: '',
            type: ExtensionType.bangumi,
          ),
        ],
      ),
    ];

    test('filters by repo name', () {
      final useCase = FilterExtensionsUseCase();
      final result = useCase(
        repos: sampleRepos,
        repoName: 'Repo A',
        installedPackages: const [],
      );

      expect(result.length, 1);
      expect(result.first.name, 'Repo A');
    });

    test('filters by query', () {
      final useCase = FilterExtensionsUseCase();
      final result = useCase(
        repos: sampleRepos,
        query: 'manga',
        installedPackages: const [],
      );

      expect(result.length, 1);
      expect(result.first.extensions.length, 1);
      expect(result.first.extensions.first.name, 'Manga Ext');
    });

    test('hides nsfw extensions when not allowed', () {
      final nsfwRepos = [
        DomainExtensionRepo(
          name: 'Repo A',
          url: 'https://example.com/a',
          extensions: [
            sampleRepos.first.extensions.first,
            sampleRepos.first.extensions.last.copyWith(nsfw: true),
          ],
        ),
      ];
      final useCase = FilterExtensionsUseCase();

      final blocked = useCase(
        repos: nsfwRepos,
        installedPackages: const [],
        allowNsfw: false,
      );
      expect(blocked.first.extensions.map((e) => e.name), ['Manga Ext']);

      final allowed = useCase(
        repos: nsfwRepos,
        installedPackages: const [],
        allowNsfw: true,
      );
      expect(allowed.first.extensions.length, 2);
    });

    test('filters by type', () {
      final useCase = FilterExtensionsUseCase();
      final result = useCase(
        repos: sampleRepos,
        typeFilter: ExtensionType.bangumi,
        installedPackages: const [],
      );

      expect(result.length, 1);
      expect(result.first.extensions.length, 1);
      expect(result.first.extensions.first.type, ExtensionType.bangumi);
    });

    test('filters by installed status', () {
      final useCase = FilterExtensionsUseCase();
      final result = useCase(
        repos: sampleRepos,
        installFilter: ExtensionInstallStatus.installed,
        installedPackages: const ['manga.ext'],
      );

      expect(result.length, 1);
      expect(result.first.extensions.length, 1);
      expect(result.first.extensions.first.packageName, 'manga.ext');
    });
  });
}
