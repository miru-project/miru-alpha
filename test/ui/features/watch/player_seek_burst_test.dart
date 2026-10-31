import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:miru_alpha/ui/core/animted_icon/morph/font_glyph.dart';
import 'package:miru_alpha/ui/features/watch/video_player/widget/player_overlay_atoms.dart';

// The burst is self-ticking (its own tickers + glyph extraction): warmup fills
// the MorphGlyphs cache inside runAsync so the first build already renders
// the extracted jog painter, not the plain-icon fallback.
Widget _host(bool forward) => MaterialApp(
  home: Scaffold(
    body: Center(child: PlayerSeekBurst(forward: forward)),
  ),
);

void main() {
  testWidgets('seek burst fades in, jogs, settles by 700ms (forward)', (
    tester,
  ) async {
    await tester.runAsync(() => MorphGlyphs.warmup([FLucideIcons.fastForward]));
    await tester.pumpWidget(_host(true));
    await tester.pump();
    expect(find.text('+10s'), findsOneWidget);

    // Mid-burst frame: the jog painter must render clean.
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('seek burst renders rewind variant clean', (tester) async {
    await tester.runAsync(() => MorphGlyphs.warmup([FLucideIcons.rewind]));
    await tester.pumpWidget(_host(false));
    await tester.pump();
    expect(find.text('-10s'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
