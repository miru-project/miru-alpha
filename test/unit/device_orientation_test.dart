import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/watch/device_orientation.dart';

void main() {
  group('gravityIsLandscape / gravityIsPortrait', () {
    test('portrait hold: vertical gravity dominates', () {
      expect(gravityIsLandscape(0.2, 9.6), isFalse);
      expect(gravityIsPortrait(0.2, 9.6), isTrue);
    });

    test('landscape hold: horizontal gravity dominates', () {
      expect(gravityIsLandscape(9.5, 0.4), isTrue);
      expect(gravityIsPortrait(9.5, 0.4), isFalse);
      // Either side down is landscape.
      expect(gravityIsLandscape(-9.5, 0.8), isTrue);
    });

    test('flat on table: neither axis dominant, both predicates false', () {
      expect(gravityIsLandscape(0.3, -0.4), isFalse);
      expect(gravityIsPortrait(0.3, -0.4), isFalse);
    });

    test('tilted ~45 deg: ambiguous, neither predicate fires', () {
      // Both axes ~7: the +1.0 dominance margin rejects the flip either way,
      // so a mid-rotation wobble cannot toggle the state.
      expect(gravityIsLandscape(7.0, 6.8), isFalse);
      expect(gravityIsPortrait(7.0, 6.8), isFalse);
    });

    test('mildly tilted portrait still reads portrait', () {
      expect(gravityIsPortrait(3.0, 9.0), isTrue);
      expect(gravityIsLandscape(3.0, 9.0), isFalse);
    });
  });
}
