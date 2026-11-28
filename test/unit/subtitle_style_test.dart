import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/watch/subtitle_style.dart';

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() {
    MiruSettings.setSettingSync(SettingKey.subtitleFontSize, '46.0');
    MiruSettings.setSettingSync(SettingKey.subtitleFontWeight, 'bold');
    MiruSettings.setSettingSync(
      SettingKey.subtitleFontColor,
      0xFFFFFFFF.toString(),
    );
    MiruSettings.setSettingSync(
      SettingKey.subtitleBackgroundColor,
      0xFF000000.toString(),
    );
    MiruSettings.setSettingSync(SettingKey.subtitleBackgroundOpacity, '0.50');
    MiruSettings.setSettingSync(SettingKey.subtitleTextAlign, '1');
  });

  test('style reads the persisted settings', () {
    final style = SubtitleStyle.current();
    expect(style.fontSize, 46.0);
    expect(style.bold, isTrue);
    expect(style.fontColor, const Color(0xFFFFFFFF));
    expect(style.backgroundOpacity, 0.5);
    expect(style.textAlign, 1);
  });

  test('mdk properties carry the documented keys and rgba form', () {
    final props = SubtitleStyle.current().toMdkProperties();
    expect(props[SubtitleProperty.fontSize], '46.0');
    expect(props[SubtitleProperty.bold], '1');
    expect(props[SubtitleProperty.color], '0xffffffff');
    expect(props[SubtitleProperty.colorBackground], '0x00000080');
    expect(props[SubtitleProperty.alignmentY], '1');
    // setProperty takes strings only.
    expect(props[SubtitleProperty.alignmentY], isA<String>());
  });

  test('a transparent background turns the box off', () {
    MiruSettings.setSettingSync(SettingKey.subtitleBackgroundOpacity, '0');
    final props = SubtitleStyle.current().toMdkProperties();
    expect(props[SubtitleProperty.box], '-1');
  });

  test('a visible background turns the box on', () {
    final props = SubtitleStyle.current().toMdkProperties();
    expect(props[SubtitleProperty.box], '1');
  });

  test('delay is pushed in seconds, and negative moves cues earlier', () {
    MiruSettings.setSettingSync(SettingKey.subtitleDelay, '-1.5');
    expect(
      SubtitleStyle.current().toMdkProperties()[SubtitleProperty.delay],
      '-1.50',
    );
    MiruSettings.setSettingSync(SettingKey.subtitleDelay, '0');
    expect(
      SubtitleStyle.current().toMdkProperties()[SubtitleProperty.delay],
      '0.00',
    );
  });

  test('a zero-alpha background removes the box even with opacity above 0', () {
    // The "none" swatch stores 0x00000000 while the opacity slider keeps its
    // own value: the transparent choice has to win, or the box comes back.
    MiruSettings.setSettingSync(SettingKey.subtitleBackgroundColor, '0');
    MiruSettings.setSettingSync(SettingKey.subtitleBackgroundOpacity, '0.50');
    final props = SubtitleStyle.current().toMdkProperties();
    expect(props[SubtitleProperty.box], '-1');
    expect(props[SubtitleProperty.colorBackground], '0x00000000');
  });
}
