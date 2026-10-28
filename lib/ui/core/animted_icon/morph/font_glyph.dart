import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart' show IconData;
import 'package:flutter/services.dart' show rootBundle;

import 'icon_input.dart';

/// Runtime svg extraction from an already-bundled icon font.
///
/// Icon fonts store each glyph as a FILLED outline: the icon's stroke path
/// expanded by half the stroke width -> outer + inner ring per subpath.
/// The midline of the two rings IS the original stroke path. Recovering it
/// here turns packed glyphs into 24-grid path data for the morph engine —
/// no extra assets, no hand-copied path strings, exact source geometry.
class MorphGlyphs {
  MorphGlyphs._();

  static const String _defaultFontAsset =
      'packages/forui_lucide/assets/lucide.ttf';

  static final Map<String, Future<_GlyphFont>> _fonts = {};
  static final Map<String, SvgD> _cache = {};

  /// Extracted midline path data of `icon`'s glyph (cached).
  static Future<SvgD> icon(
    IconData icon, {
    String fontAsset = _defaultFontAsset,
  }) {
    final key = '$fontAsset#${icon.codePoint}';
    final cached = _cache[key];
    if (cached != null) return Future.value(cached);
    return _font(fontAsset).then((f) {
      final d = SvgD(f.midlineD(icon.codePoint));
      return _cache[key] = d;
    });
  }

  /// Pre-extracts several glyphs (mount paths, test warmup).
  static Future<void> warmup(
    Iterable<IconData> icons, {
    String fontAsset = _defaultFontAsset,
  }) => Future.wait([for (final i in icons) icon(i, fontAsset: fontAsset)]);

  static Future<_GlyphFont> _font(String asset) => _fonts.putIfAbsent(
    asset,
    () async => _GlyphFont(await rootBundle.load(asset)),
  );
}

class _GlyphFont {
  final ByteData bd;
  late final int _upem;
  late final int _indexToLoc;
  late final int _numGlyphs;
  late final int _locaOff;
  late final int _glyfOff;
  final List<int> _g12Start = [];
  final List<int> _g12End = [];
  final List<int> _g12First = [];
  // format 4 fallback state
  final List<int> _f4End = [];
  final List<int> _f4Start = [];
  final List<int> _f4Delta = [];
  final List<int> _f4Range = [];
  int _f4Base = 0;

  _GlyphFont(this.bd) {
    final numTables = bd.getUint16(4, Endian.big);
    final tables = <String, int>{};
    for (var i = 0; i < numTables; i++) {
      final o = 12 + 16 * i;
      final tag = String.fromCharCodes([
        for (var k = 0; k < 4; k++) bd.getUint8(o + k),
      ]);
      tables[tag] = bd.getUint32(o + 8, Endian.big);
    }
    final head = tables['head']!;
    _upem = bd.getUint16(head + 18, Endian.big);
    _indexToLoc = bd.getInt16(head + 50, Endian.big);
    _numGlyphs = bd.getUint16(tables['maxp']! + 4, Endian.big);
    _locaOff = tables['loca']!;
    _glyfOff = tables['glyf']!;

    final cmap = tables['cmap']!;
    final nSub = bd.getUint16(cmap + 2, Endian.big);
    var fmt12 = -1, fmt4 = -1;
    for (var i = 0; i < nSub; i++) {
      final o = cmap + 4 + 8 * i;
      final pid = bd.getUint16(o, Endian.big);
      final eid = bd.getUint16(o + 2, Endian.big);
      final off = bd.getUint32(o + 4, Endian.big);
      if ((pid == 3 && eid == 10) || (pid == 0 && eid == 4)) {
        fmt12 = cmap + off;
      } else if ((pid == 3 && eid == 1) || (pid == 0 && eid == 3)) {
        fmt4 = cmap + off;
      }
    }
    if (fmt12 > 0) {
      final nGroups = bd.getUint32(fmt12 + 12, Endian.big);
      for (var i = 0; i < nGroups; i++) {
        final o = fmt12 + 16 + 12 * i;
        _g12Start.add(bd.getUint32(o, Endian.big));
        _g12End.add(bd.getUint32(o + 4, Endian.big));
        _g12First.add(bd.getUint32(o + 8, Endian.big));
      }
    } else if (fmt4 > 0) {
      final segs = bd.getUint16(fmt4 + 6, Endian.big) ~/ 2;
      _f4Base = fmt4 + 16 + 3 * 2 * segs;
      final startsBase = fmt4 + 16 + 2 * segs;
      final endsBase = fmt4 + 14;
      for (var i = 0; i < segs; i++) {
        _f4End.add(_u16(endsBase + 2 * i));
        _f4Start.add(_u16(startsBase + 2 * i));
        _f4Delta.add(_s16(startsBase + 2 * segs + 2 * i));
        _f4Range.add(_u16(_f4Base + 2 * i));
      }
    } else {
      throw StateError('font: no usable cmap');
    }
  }

  int _u16(int o) => bd.getUint16(o, Endian.big);
  int _s16(int o) => bd.getInt16(o, Endian.big);
  int _u32(int o) => bd.getUint32(o, Endian.big);

  int _glyphId(int cp) {
    for (var i = 0; i < _g12Start.length; i++) {
      if (cp >= _g12Start[i] && cp <= _g12End[i]) {
        return _g12First[i] + (cp - _g12Start[i]);
      }
    }
    for (var i = 0; i < _f4End.length; i++) {
      if (cp >= _f4Start[i] && cp <= _f4End[i]) {
        if (_f4Range[i] == 0) return (cp + _f4Delta[i]) & 0xFFFF;
        final g = _u16(_f4Base + 2 * i + 2 * (cp - _f4Start[i]));
        return g == 0 ? 0 : (g + _f4Delta[i]) & 0xFFFF;
      }
    }
    return 0;
  }

  (int, int) _locaSpan(int gid) {
    if (_indexToLoc == 0) {
      return (_u16(_locaOff + 2 * gid) * 2, _u16(_locaOff + 2 * gid + 2) * 2);
    }
    return (_u32(_locaOff + 4 * gid), _u32(_locaOff + 4 * gid + 4));
  }

  /// Contours as on/off-point cycles.
  List<List<(double, double, bool)>> _glyph(int gid) {
    final (a, b) = _locaSpan(gid);
    if (b <= a) return const [];
    final o = _glyfOff + a;
    final nc = _s16(o);
    if (nc <= 0) return const []; // composite: unsupported
    final endPts = [for (var i = 0; i < nc; i++) _u16(o + 10 + 2 * i)];
    final npts = endPts.last + 1;
    final instr = _u16(o + 10 + 2 * nc);
    var p = o + 12 + 2 * nc + instr;
    final flags = <int>[];
    while (flags.length < npts) {
      final f = bd.getUint8(p);
      p++;
      flags.add(f);
      if (f & 0x8 != 0) {
        final r = bd.getUint8(p);
        p++;
        for (var k = 0; k < r; k++) {
          flags.add(f);
        }
      }
    }
    final xs = List<int>.filled(npts, 0);
    var x = 0;
    for (var i = 0; i < npts; i++) {
      final f = flags[i];
      if (f & 0x2 != 0) {
        final dx = bd.getUint8(p);
        p++;
        x += f & 0x10 != 0 ? dx : -dx;
      } else if (f & 0x10 == 0) {
        x += _s16(p);
        p += 2;
      }
      xs[i] = x;
    }
    final ys = List<int>.filled(npts, 0);
    var y = 0;
    for (var i = 0; i < npts; i++) {
      final f = flags[i];
      if (f & 0x4 != 0) {
        final dy = bd.getUint8(p);
        p++;
        y += f & 0x20 != 0 ? dy : -dy;
      } else if (f & 0x20 == 0) {
        y += _s16(p);
        p += 2;
      }
      ys[i] = y;
    }
    final out = <List<(double, double, bool)>>[];
    var start = 0;
    for (final e in endPts) {
      out.add([
        for (var i = start; i <= e; i++)
          (xs[i].toDouble(), ys[i].toDouble(), flags[i] & 0x1 != 0),
      ]);
      start = e + 1;
    }
    return out;
  }

  /// TrueType on/off cycle -> dense on-curve polyline (wrap-closed).
  static List<(double, double)> _densify(List<(double, double, bool)> pts) {
    final n = pts.length;
    var s = 0;
    for (var i = 0; i < n; i++) {
      if (pts[i].$3) {
        s = i;
        break;
      }
    }
    final cyc = [...pts.sublist(s), ...pts.sublist(0, s)];
    const steps = 10;
    final out = <(double, double)>[];
    var i = 0;
    while (i < n) {
      final p0 = cyc[i % n];
      final nxt = cyc[(i + 1) % n];
      if (nxt.$3) {
        out.add((p0.$1, p0.$2));
        i++;
        continue;
      }
      final n2 = cyc[(i + 2) % n];
      final e = n2.$3
          ? (n2.$1, n2.$2)
          : ((nxt.$1 + n2.$1) / 2, (nxt.$2 + n2.$2) / 2);
      for (var k = 0; k < steps; k++) {
        final t = k / steps;
        final mt = 1 - t;
        out.add((
          mt * mt * p0.$1 + 2 * mt * t * nxt.$1 + t * t * e.$1,
          mt * mt * p0.$2 + 2 * mt * t * nxt.$2 + t * t * e.$2,
        ));
      }
      i += 2;
    }
    return out;
  }

  static List<(double, double)> _resampleClosed(
    List<(double, double)> poly,
    int n,
  ) {
    final m = poly.length;
    final cum = Float64List(m + 1);
    for (var i = 1; i <= m; i++) {
      final a = poly[i - 1], b = poly[i % m];
      final dx = b.$1 - a.$1, dy = b.$2 - a.$2;
      cum[i] = cum[i - 1] + math.sqrt(dx * dx + dy * dy);
    }
    final total = cum[m];
    final first = poly.isEmpty ? (0.0, 0.0) : poly[0];
    if (total <= 0) return List.filled(n, first);
    final out = <(double, double)>[];
    var j = 0;
    for (var k = 0; k < n; k++) {
      final t = total * k / n;
      while (j < m - 1 && cum[j + 1] < t) {
        j++;
      }
      final a = poly[j], b = poly[(j + 1) % m];
      final seg = cum[j + 1] - cum[j];
      final u = seg <= 0 ? 0.0 : (t - cum[j]) / seg;
      out.add((a.$1 + u * (b.$1 - a.$1), a.$2 + u * (b.$2 - a.$2)));
    }
    return out;
  }

  /// Nearest-point average of the two rings (uniform stroke -> midline).
  static List<(double, double)> _midline(
    List<(double, double)> outer,
    List<(double, double)> inner,
  ) {
    final o = _resampleClosed(outer, 192);
    final i = _resampleClosed(inner, 192);
    return [
      for (final p in o)
        () {
          var best = i[0];
          var bd = double.infinity;
          for (final q in i) {
            final d =
                (q.$1 - p.$1) * (q.$1 - p.$1) + (q.$2 - p.$2) * (q.$2 - p.$2);
            if (d < bd) {
              bd = d;
              best = q;
            }
          }
          return ((p.$1 + best.$1) / 2, (p.$2 + best.$2) / 2);
        }(),
    ];
  }

  /// 24-grid path data: midlines of every ring pair, y-flipped, 2 decimals.
  String midlineD(int codePoint) {
    final gid = _glyphId(codePoint);
    if (gid <= 0 || gid >= _numGlyphs) {
      throw StateError(
        'font: codepoint U+${codePoint.toRadixString(16)} '
        'has no simple glyph',
      );
    }
    final cs = _glyph(gid);
    if (cs.isEmpty) {
      throw StateError('font: empty glyph');
    }
    final dense = [for (final c in cs) _densify(c)];
    final boxes = [for (final c in dense) _bbox(c)];
    final areas = [for (final c in dense) _areaAbs(c)];
    final midlines = <List<(double, double)>>[];
    for (var i = 0; i < dense.length; i++) {
      int? parent;
      var best = double.infinity;
      for (var j = 0; j < dense.length; j++) {
        if (j == i || areas[j] <= areas[i]) continue;
        if (!_contains(boxes[j], boxes[i])) continue;
        if (areas[j] < best) {
          best = areas[j];
          parent = j;
        }
      }
      if (parent != null) midlines.add(_midline(dense[parent], dense[i]));
    }
    if (midlines.isEmpty) {
      throw StateError('font: glyph has no ring pair');
    }
    final s = _upem / 24.0;
    final sb = StringBuffer();
    for (final mid in midlines) {
      final pts = _resampleClosed(mid, 64);
      sb.write('M');
      for (var k = 0; k < pts.length; k++) {
        if (k > 0) sb.write('L');
        sb.write('${_f(pts[k].$1 / s)} ${_f(24 - pts[k].$2 / s)}');
      }
      sb.write('Z');
    }
    return sb.toString();
  }

  static String _f(double v) {
    var s = v.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s == '-0' ? '0' : s;
  }

  static (double, double, double, double) _bbox(List<(double, double)> poly) {
    var x0 = double.infinity, y0 = double.infinity;
    var x1 = -double.infinity, y1 = -double.infinity;
    for (final (x, y) in poly) {
      x0 = math.min(x0, x);
      y0 = math.min(y0, y);
      x1 = math.max(x1, x);
      y1 = math.max(y1, y);
    }
    return (x0, y0, x1, y1);
  }

  static bool _contains(
    (double, double, double, double) outer,
    (double, double, double, double) inner,
  ) {
    final pad = 1e-6;
    return outer.$1 <= inner.$1 + pad &&
        outer.$2 <= inner.$2 + pad &&
        outer.$3 >= inner.$3 - pad &&
        outer.$4 >= inner.$4 - pad;
  }

  static double _areaAbs(List<(double, double)> poly) {
    var s = 0.0;
    for (var i = 0; i < poly.length; i++) {
      final (x0, y0) = poly[i];
      final (x1, y1) = poly[(i + 1) % poly.length];
      s += x0 * y1 - x1 * y0;
    }
    return (s / 2).abs();
  }
}
