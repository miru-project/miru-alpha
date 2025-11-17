import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:miru_app_new/widgets/index.dart';

class MiruLicensePage extends StatelessWidget {
  MiruLicensePage({super.key});

  final licenseMap = <Iterable<String>, Iterable<LicenseParagraph>>{};
  @override
  Widget build(BuildContext context) {
    return MiruScaffold(
      mobileHeader: SnapSheetNested.back(title: 'License'),

      body: FutureBuilder(
        future: LicenseRegistry.licenses.toList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final licenses = snapshot.data!;
            for (var entry in licenses) {
              final paragraph = licenseMap[entry.packages] ?? [];
              if (!licenseMap.containsKey(entry.packages)) {
                licenseMap[entry.packages] = entry.paragraphs;
                continue;
              }
              licenseMap[entry.packages] = [...paragraph, ...entry.paragraphs];
            }

            final processedLicense = licenseMap.keys.toList();
            return FTileGroup.builder(
              count: processedLicense.length,
              tileBuilder: (context, index) {
                final pkg = processedLicense[index];
                final value = licenseMap[pkg]!;
                return FTile(title: Text(pkg.first));
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
