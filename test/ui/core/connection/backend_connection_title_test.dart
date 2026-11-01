import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:miru_alpha/provider/backend_connection_provider.dart';
import 'package:miru_alpha/ui/core/connection/backend_connection_title.dart';
import 'package:miru_alpha/utils/theme/miru_themes.dart';
import 'package:miru_alpha/utils/theme/theme.dart';

/// Never resolves: holds the provider in its connecting state for the whole
/// test (a bare Completer future — no timer, so teardown stays clean).
class _PendingConnection extends BackendConnection {
  @override
  Future<void> build() => Completer<void>().future;
}

class _OnlineConnection extends BackendConnection {
  @override
  Future<void> build() async {}
}

Future<void> _pump(
  WidgetTester tester,
  BackendConnection Function() factory,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [backendConnectionProvider.overrideWith(factory)],
      child: FTheme(
        data: ThemeUtils.getThemeData(MiruThemes.zinc.light),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: BackendConnectionTitle(title: Text('TITLE')),
        ),
      ),
    ),
  );
}

/// Slide offsets of the connecting block / the real title, read off the
/// AnimatedSlides the widget drives.
(double connectingDy, double titleDy) _offsets(WidgetTester tester) {
  final slides = tester
      .widgetList<AnimatedSlide>(
        find.descendant(
          of: find.byType(BackendConnectionTitle),
          matching: find.byType(AnimatedSlide),
        ),
      )
      .toList();
  expect(slides.length, 2);
  // Stack order: connecting first, title second.
  return (slides[0].offset.dy, slides[1].offset.dy);
}

void main() {
  testWidgets('connecting shows the status column and hides the title', (
    tester,
  ) async {
    await _pump(tester, _PendingConnection.new);

    // Raw-key regime: the harness loads no i18n assets.
    expect(find.text('common.connecting'), findsOneWidget);
    expect(find.text('127.0.0.1:3000'), findsOneWidget);
    expect(find.text('TITLE'), findsOneWidget);

    final (connectingDy, titleDy) = _offsets(tester);
    expect(connectingDy, 0.0, reason: 'status block in place');
    expect(titleDy, 1.1, reason: 'title parked below while connecting');
  });

  testWidgets('online: title rises into place as the status leaves upward', (
    tester,
  ) async {
    await _pump(tester, _OnlineConnection.new);
    await tester.pump(const Duration(milliseconds: 200));

    final (connectingDy, titleDy) = _offsets(tester);
    expect(connectingDy, -1.1, reason: 'status block slid upward out');
    expect(titleDy, 0.0, reason: 'title slid up into place');

    final opacities = tester
        .widgetList<AnimatedOpacity>(
          find.descendant(
            of: find.byType(BackendConnectionTitle),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .toList();
    expect(opacities.length, 2);
    expect(opacities[0].opacity, 0.0);
    expect(opacities[1].opacity, 1.0);
  });
}
