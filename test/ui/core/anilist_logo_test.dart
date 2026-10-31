import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/ui/core/widget/app_svgs.dart';

void main() {
  test('inlined AniList source carries the logo path', () {
    expect(kAniListSvg, contains('viewBox="0 0 24 24"'));
    expect(kAniListSvg, contains('M6.361 2.943 0 21.056'));
  });

  testWidgets('anilistLogo renders from source without any asset read', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: anilistLogo(size: 13, color: Colors.white)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SvgPicture), findsOneWidget);

    // The parsed picture must produce a non-empty layer: a broken source
    // would settle to a zero-sized render object.
    final picture = tester.renderObject<RenderBox>(find.byType(SvgPicture));
    expect(picture.size, const Size(13, 13));
  });
}
