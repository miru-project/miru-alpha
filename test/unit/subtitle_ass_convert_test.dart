import 'package:flutter_test/flutter_test.dart';
import 'package:miru_alpha/utils/watch/subtitle.dart';

void main() {
  group('isAss', () {
    test('detects ass/ssa by extension, ignores query', () {
      expect(SubtitleUtil.isAss('https://x/y.ass'), isTrue);
      expect(SubtitleUtil.isAss('https://x/y.SSA?token=1'), isTrue);
      expect(SubtitleUtil.isAss('https://x/y.srt'), isFalse);
      expect(SubtitleUtil.isAss('https://x/y.vtt'), isFalse);
    });
  });

  group('assToSrt', () {
    const ass =
        '[Script Info]\nScriptType: v4.00+\n\n'
        '[V4+ Styles]\nStyle: Default,Arial,24,&H00FFFFFF\n\n'
        '[Events]\n'
        'Dialogue: 0,0:00:01.50,0:00:03.00,Default,,0,0,0,,Hello\\NWorld\n'
        'Dialogue: 0,0:01:04.20,0:01:05.00,Default,,0,0,0,,Second line\n';

    test('converts dialogue lines to srt cues with ms timing', () {
      final srt = SubtitleUtil.assToSrt(ass);
      expect(srt, contains('1\n00:00:01,500 --> 00:00:03,000'));
      expect(srt, contains('Hello\nWorld'));
      expect(srt, contains('2\n00:01:04,200 --> 00:01:05,000'));
      expect(srt, isNot(contains('Dialogue:')));
      expect(srt, isNot(contains('[V4+ Styles]')));
    });

    test('passes non-ass text through trimmed', () {
      expect(
        SubtitleUtil.assToSrt('  1\n00:00:00,000 --> 00:00:01,000\nhi\n'),
        '1\n00:00:00,000 --> 00:00:01,000\nhi',
      );
    });

    test('converts WebVTT (MM:SS.mmm) to srt with HH:MM:SS,mmm', () {
      const vtt =
          'WEBVTT\n\n00:12.095 --> 00:16.015\nHello VTT\n\n'
          '01:02:03.500 --> 01:02:05.000\nSecond\n';
      final srt = SubtitleUtil.assToSrt(vtt);
      expect(srt, contains('1\n00:00:12,095 --> 00:00:16,015'));
      expect(srt, contains('Hello VTT'));
      expect(srt, contains('2\n01:02:03,500 --> 01:02:05,000'));
      expect(srt, isNot(contains('WEBVTT')));
    });
  });
}
