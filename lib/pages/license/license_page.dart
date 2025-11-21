import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/index.dart';

class MiruLicensePage extends StatefulWidget {
  const MiruLicensePage({super.key});

  @override
  State<MiruLicensePage> createState() => _MiruLicensePageState();
}

class _MiruLicensePageState extends State<MiruLicensePage> {
  late final Future<List<LicenseEntry>> _licensesFuture;

  @override
  void initState() {
    super.initState();
    _licensesFuture = LicenseRegistry.licenses.toList();
  }

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      mobileHeader: SnapSheetNested.back(title: 'License'),
      body: FutureBuilder<List<LicenseEntry>>(
        future: _licensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No licenses found'));
          }

          final licenses = snapshot.data!;
          final Map<String, List<LicenseParagraph>> packageLicenses = {};

          for (final entry in licenses) {
            for (final package in entry.packages) {
              if (!packageLicenses.containsKey(package)) {
                packageLicenses[package] = [];
              }
              packageLicenses[package]!.addAll(entry.paragraphs);
            }
          }

          final sortedPackages = packageLicenses.keys.toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

          return FTileGroup.builder(
            count: sortedPackages.length,
            tileBuilder: (context, index) {
              final packageName = sortedPackages[index];
              final paragraphs = packageLicenses[packageName]!;

              return FTile(
                title: Text(packageName),
                subtitle: Text('${paragraphs.length} paragraphs'),
                onPress: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _LicenseDetailPage(
                        packageName: packageName,
                        paragraphs: paragraphs,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LicenseDetailPage extends StatelessWidget {
  final String packageName;
  final List<LicenseParagraph> paragraphs;

  const _LicenseDetailPage({
    required this.packageName,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      mobileHeader: SnapSheetNested.back(title: packageName),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: paragraphs.length,
        itemBuilder: (context, index) {
          final paragraph = paragraphs[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: 12,
              left: paragraph.indent == LicenseParagraph.centeredIndent
                  ? 0
                  : paragraph.indent * 16.0,
            ),
            child: Text(
              paragraph.text,
              textAlign: paragraph.indent == LicenseParagraph.centeredIndent
                  ? TextAlign.center
                  : TextAlign.left,
            ),
          );
        },
      ),
    );
  }
}
