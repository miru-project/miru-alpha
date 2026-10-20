import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/data/services/extension_service.dart';
import 'package:miru_alpha/miru_core/proto/generate/proto/extension_model.pb.dart'
    as ext_model;
import 'package:miru_alpha/model/model.dart';

ext_model.ExtensionRepo repo(String url) => ext_model.ExtensionRepo(
  extensions: <ext_model.GithubExtension>[],
  url: url,
);

RepoConfig config(int id, String name, String link) =>
    RepoConfig(id: id, name: name, link: link);

void main() {
  group('ExtensionService.applyRepoNames', () {
    test('replaces urls with the configured names', () {
      const miruProject =
          'https://raw.githubusercontent.com/miru-project/repo/main/index.json';
      const mirror = 'https://miru-repo.example.com/index.json';

      final repos = ExtensionService.applyRepoNames(
        [repo(miruProject), repo(mirror)],
        configs: [
          config(1, 'Miru Project', miruProject),
          config(2, 'Mirror', mirror),
        ],
      );

      expect(repos.map((r) => r.name), ['Miru Project', 'Mirror']);
      expect(repos.map((r) => r.url), [miruProject, mirror]);
    });

    test('derives a readable label when the repo is unconfigured', () {
      final repos = ExtensionService.applyRepoNames([
        repo('https://github.com/miru-project/repo/blob/main/index.json'),
        repo('https://miru-repo.example.com/index.json'),
      ], configs: const []);

      expect(repos.map((r) => r.name), [
        'miru-project/repo',
        'miru-repo.example.com',
      ]);
    });

    test('keeps a configured repo whose index failed to fetch', () {
      const live = 'https://a.example.com/index.json';
      const broken = 'https://b.example.com/index.json';

      final repos = ExtensionService.applyRepoNames(
        [repo(live)],
        configs: [config(1, 'A', live), config(2, 'B', broken)],
      );

      expect(repos.map((r) => r.name), ['A', 'B']);
      expect(repos.last.url, broken);
      expect(repos.last.extensions, isEmpty);
    });

    test('disambiguates duplicate display names', () {
      const a = 'https://a.example.com/index.json';
      const b = 'https://b.example.com/index.json';

      final repos = ExtensionService.applyRepoNames(
        [repo(a), repo(b)],
        configs: [config(1, 'Official', a), config(2, 'Official', b)],
      );

      expect(repos.map((r) => r.name), ['Official', 'Official (2)']);
    });

    test('a configured name wins over the derived label', () {
      const miruProject =
          'https://github.com/miru-project/repo/blob/main/index.json';

      final repos = ExtensionService.applyRepoNames(
        [repo(miruProject)],
        configs: [config(1, 'Miru Alpha Repo', miruProject)],
      );

      expect(repos.single.name, 'Miru Alpha Repo');
    });
  });

  group('ExtensionService.repoDisplayLabel', () {
    test('renders github links as owner/repo', () {
      expect(
        ExtensionService.repoDisplayLabel(
          'https://github.com/miru-project/repo/blob/main/index.json',
        ),
        'miru-project/repo',
      );
      expect(
        ExtensionService.repoDisplayLabel(
          'https://raw.githubusercontent.com/miru-project/repo/main/index.json',
        ),
        'miru-project/repo',
      );
    });

    test('renders any other host by its hostname', () {
      expect(
        ExtensionService.repoDisplayLabel(
          'https://miru-repo.example.com/index.json',
        ),
        'miru-repo.example.com',
      );
      expect(
        ExtensionService.repoDisplayLabel('https://www.example.com/r.json'),
        'example.com',
      );
    });

    test('keeps the raw string when it is not a URL', () {
      expect(ExtensionService.repoDisplayLabel('not a url'), 'not a url');
    });
  });
}
