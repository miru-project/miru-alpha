import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fvp/src/video_player_mdk.dart';
import 'package:miru_alpha/provider/watch/video_player_provider.dart';
import 'package:miru_alpha/utils/store/miru_settings.dart';
import 'package:miru_alpha/utils/watch/subtitle_style.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Records the properties pushed through fvp's real extension code, so the
/// test asserts what mdk would receive rather than what a stand-in accepts.
class _CapturingMdkPlatform extends MdkVideoPlayerPlatform {
  final Map<String, String> props = {};

  @override
  void setProperty(int playerId, String name, String value) {
    props[name] = value;
  }
}

void main() {
  setUpAll(MiruSettings.seedDefaultsForTest);
  setUp(() {
    MiruSettings.setSettingSync(SettingKey.subtitleFontSize, '46.0');
    MiruSettings.setSettingSync(SettingKey.subtitleFontWeight, 'bold');
    MiruSettings.setSettingSync(SettingKey.subtitleFontColor, '0xFFFFCC00');
    MiruSettings.setSettingSync(
      SettingKey.subtitleBackgroundColor,
      0xFF000000.toString(),
    );
    MiruSettings.setSettingSync(SettingKey.subtitleBackgroundOpacity, '0.50');
    MiruSettings.setSettingSync(SettingKey.subtitleTextAlign, '1');
    MiruSettings.setSettingSync(SettingKey.subtitleVerticalAlign, 'bottom');
    MiruSettings.setSettingSync(SettingKey.subtitleFontFamily, '');
    MiruSettings.setSettingSync(SettingKey.subtitleItalic, 'false');
    MiruSettings.setSettingSync(SettingKey.subtitleUnderline, 'false');
    MiruSettings.setSettingSync(SettingKey.subtitleStrikeout, 'false');
    MiruSettings.setSettingSync(SettingKey.subtitleOutlineSize, '1.2');
    MiruSettings.setSettingSync(
      SettingKey.subtitleOutlineColor,
      0xFF000000.toString(),
    );
  });

  test(
    'yellow font colour reaches mdk as subtitle.color 0xffcc00ff (RGBA)',
    () {
      final props = SubtitleStyle.current().toMdkProperties();
      expect(props[SubtitleProperty.color], '0xffcc00ff');
    },
  );

  test('applySubtitleStyleToEngine pushes subtitle.color through fvp', () {
    final platform = _CapturingMdkPlatform();
    final previous = VideoPlayerPlatform.instance;
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = previous);

    final controller = VideoPlayerController.file(File('probe.mp4'));
    applySubtitleStyleToEngine(controller);

    expect(platform.props[SubtitleProperty.color], '0xffcc00ff');
    expect(platform.props[SubtitleProperty.fontSize], '46.0');
  });

  test('a non-fvp platform is a swallowed no-op', () {
    final controller = VideoPlayerController.file(File('probe.mp4'));
    expect(() => applySubtitleStyleToEngine(controller), returnsNormally);
  });
}
