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

    test('filters by type', () {
      final useCase = FilterExtensionsUseCase();
      final result = useCase(
        repos: sampleRepos,
        typeFilter: 'bangumi',
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
        installFilter: 'extension.installed',
        installedPackages: const ['manga.ext'],
      );

      expect(result.length, 1);
      expect(result.first.extensions.length, 1);
      expect(result.first.extensions.first.packageName, 'manga.ext');
    });
  });
}
