import 'package:miru_app_new/utils/network/request.dart';

class SubtitleUtil {
  static Future<List<Subtitle>> parseVttSubtitles(String url) async {
    // #todo
    final String data = (await dio.get<String>(url)).data!;
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
