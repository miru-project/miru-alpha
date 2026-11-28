import 'package:dio/dio.dart';
import 'package:miru_alpha/utils/http/request.dart';

class SubtitleUtil {
  /// True when [url] points at an ASS/SSA track (which mdk renders with the
  /// file's own style and ignores `subtitle.*` color/size properties).
  static bool isAss(String url) {
    final path = url.split('?').first.toLowerCase();
    return path.endsWith('.ass') || path.endsWith('.ssa');
  }

  /// True when the track TEXT is ASS/SSA. The URL check cannot decide this on
  /// this app's proxy paths (the real suffix is percent-encoded inside the
  /// path), so the body is read once when the customize switch is on.
  static bool isAssText(String text) =>
      text.contains('[Script Info]') ||
      text.contains('[V4+ Styles]') ||
      text.contains('[Events]');

  /// Converts ASS/SSA or WebVTT [text] to SRT so mdk treats it as a text track
  /// and the `subtitle.*` style properties (color, size, bold …) take effect.
  /// The file's own styling is dropped; only cue text + timing survive. Plain
  /// SRT is returned trimmed. mdk's srt demuxer needs `HH:MM:SS,mmm` timing,
  /// so WebVTT's `MM:SS.mmm` / `WEBVTT` header must be normalized — passing
  /// raw VTT through makes mdk fail to demux it (read packet error).
  static String assToSrt(String text) {
    final isAss = isAssText(text);
    final isVtt = text.trimLeft().startsWith('WEBVTT');
    if (!isAss && !isVtt) return text.trim();
    if (isVtt) return _vttToSrt(text);
    final out = StringBuffer();
    var index = 0;
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('Dialogue:')) continue;
      // Dialogue: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
      final parts = trimmed.split(',');
      if (parts.length < 10) continue;
      final start = _assTimeToStamp(parts[1]);
      final end = _assTimeToStamp(parts[2]);
      final body = parts.sublist(9).join(',').replaceAll(r'\N', '\n');
      if (start == null || end == null) continue;
      out.writeln(++index);
      out.writeln('$start --> $end');
      out.writeln(body);
      out.writeln();
    }
    return out.toString();
  }

  /// WebVTT → SRT: each block is `timing\ntext…`; VTT times are `MM:SS.mmm`
  /// (hours optional) and must become `HH:MM:SS,mmm` for mdk's srt demuxer.
  static String _vttToSrt(String vtt) {
    final out = StringBuffer();
    var index = 0;
    for (final block in vtt.split('\n\n')) {
      final lines = block.split('\n');
      final tIdx = lines.indexWhere((l) => l.contains('-->'));
      if (tIdx < 0) continue;
      final timing = lines[tIdx].split('-->');
      final start = _vttTimeToStamp(timing[0]);
      final end = _vttTimeToStamp(timing[1]);
      final body = lines.skip(tIdx + 1).join('\n').trim();
      if (body.isEmpty) continue;
      out.writeln(++index);
      out.writeln('$start --> $end');
      out.writeln(body);
      out.writeln();
    }
    return out.toString();
  }

  /// WebVTT `MM:SS.mmm` or `HH:MM:SS.mmm` → SRT `HH:MM:SS,mmm`.
  static String _vttTimeToStamp(String raw) {
    final m = RegExp(r'(\d{1,2}:)?(\d{2}):(\d{2})\.(\d{3})')
        .firstMatch(raw.trim());
    if (m == null) return '00:00:00,000';
    final h = (m.group(1) ?? '').replaceAll(':', '');
    final hh = (h.isEmpty ? '00' : h).padLeft(2, '0');
    return '$hh:${m.group(2)}:${m.group(3)},${m.group(4)}';
  }

  /// ASS time is `H:MM:SS.cc` (centiseconds); SRT wants `HH:MM:SS,mmm`.
  static String? _assTimeToStamp(String raw) {
    final m = RegExp(r'(\d+):(\d{2}):(\d{2})\.(\d{2})').firstMatch(raw);
    if (m == null) return null;
    final h = m.group(1)!.padLeft(2, '0');
    final min = m.group(2)!;
    final s = m.group(3)!;
    final cs = int.parse(m.group(4)!);
    final ms = (cs * 10).toString().padLeft(3, '0');
    return '$h:$min:$s,$ms';
  }

  /// Parses a VTT subtitle from [url]. [headers] carries the watch
  /// result's HTTP headers (Referer/User-Agent/…): subtitle CDNs gate on
  /// the same headers the video stream needs — a bare request answers 403.
  static Future<List<Subtitle>> parseVttSubtitles(
    String url, {
    Map<String, String> headers = const {},
  }) async {
    final dynamic rawData = await MiruRequest.get(
      url,
      options: Options(headers: headers),
    );
    final String data = rawData as String;
    final List<Subtitle> subtitles = [];
    RegExp regExp = RegExp(
      r'(\d{2}:\d{2}:\d{2}\.\d{3}) --> (\d{2}:\d{2}:\d{2}\.\d{3})\n(.+)',
      multiLine: true,
    );

    for (final RegExpMatch match in regExp.allMatches(data)) {
      final start = _parseHours(match.group(1)!);
      final end = _parseHours(match.group(2)!);
      final text = match.group(3)!;
      subtitles.add(Subtitle(start: start, end: end, text: text));
    }
    if (subtitles.isNotEmpty) {
      return subtitles;
    }
    regExp = RegExp(
      r'(\d{2}:\d{2}\.\d{3}) --> (\d{2}:\d{2}\.\d{3})\n(.+)',
      multiLine: true,
    );
    for (final RegExpMatch match in regExp.allMatches(data)) {
      final start = _parseMinutes(match.group(1)!);
      final end = _parseMinutes(match.group(2)!);
      final text = match.group(3)!;
      subtitles.add(Subtitle(start: start, end: end, text: text));
    }
    return subtitles;
  }

  static Duration _parseHours(String time) {
    final parts = time.split(':');
    final secondsParts = parts[2].split('.');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(secondsParts[0]),
      milliseconds: int.parse(secondsParts[1]),
    );
  }

  static Duration _parseMinutes(String time) {
    final parts = time.split(':');
    final secondsParts = parts[1].split('.');
    return Duration(
      minutes: int.parse(parts[0]),
      seconds: int.parse(secondsParts[0]),
      milliseconds: int.parse(secondsParts[1]),
    );
  }
}

class Subtitle {
  final Duration start;
  final Duration end;
  final String text;

  Subtitle({required this.start, required this.end, required this.text});
}
