import 'dart:math' as math;
import 'dart:typed_data';

import 'icon_input.dart';

/// svg path data parser + serializers. Pure dart, no flutter.

const double _pi = math.pi;

String _fmt(double v, int decimals) {
  var s = v.toStringAsFixed(decimals);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  if (s == '-0') s = '0';
  return s;
}

/// Canonical `d` of real cubics, quantized to 4 decimals (stable bytes).
String cubicsToPathD(List<CubicPath> paths) {
  final sb = StringBuffer();
  for (final p in paths) {
    sb.write('M${_fmt(p.sx, 4)} ${_fmt(p.sy, 4)}');
    for (var i = 0; i < p.segments; i++) {
      final o = i * 6;
      sb.write(
        'C'
        '${_fmt(p.pts[o], 4)} ${_fmt(p.pts[o + 1], 4)} '
        '${_fmt(p.pts[o + 2], 4)} ${_fmt(p.pts[o + 3], 4)} '
        '${_fmt(p.pts[o + 4], 4)} ${_fmt(p.pts[o + 5], 4)}',
      );
    }
    if (p.closed) sb.write('Z');
  }
  return sb.toString();
}

/// Flight serializer: subpath samples -> smooth cubic `d` (Catmull-Rom).
String serialize(List<Float64List> outs, List<bool>? closed) {
  final sb = StringBuffer();
  for (var s = 0; s < outs.length; s++) {
    final pts = outs[s];
    final n = pts.length ~/ 2;
    if (n == 0) continue;
    final isClosed = closed?[s] ?? false;
    (double, double) pt(int i) {
      final j = (i % n + n) % n;
      return (pts[j * 2], pts[j * 2 + 1]);
    }

    (double, double) ptOpen(int i) => isClosed ? pt(i) : pt(i.clamp(0, n - 1));

    sb.write('M${_fmt(pts[0], 3)} ${_fmt(pts[1], 3)}');
    final segs = isClosed ? n : n - 1;
    for (var i = 0; i < segs; i++) {
      final cur = ptOpen(i), nxt = ptOpen(i + 1);
      final prev = ptOpen(i - 1), next2 = ptOpen(i + 2);
      final c1x = cur.$1 + (nxt.$1 - prev.$1) / 6;
      final c1y = cur.$2 + (nxt.$2 - prev.$2) / 6;
      final c2x = nxt.$1 - (next2.$1 - cur.$1) / 6;
      final c2y = nxt.$2 - (next2.$2 - cur.$2) / 6;
      sb.write(
        'C${_fmt(c1x, 3)} ${_fmt(c1y, 3)} '
        '${_fmt(c2x, 3)} ${_fmt(c2y, 3)} '
        '${_fmt(nxt.$1, 3)} ${_fmt(nxt.$2, 3)}',
      );
    }
    if (isClosed) sb.write('Z');
  }
  return sb.toString();
}

/// Reverses a cubic chain (winding fix): segments reversed, controls swapped.
CubicPath reverseCubics(CubicPath p) {
  final m = p.segments;
  final out = Float64List(p.pts.length);
  var x = p.sx, y = p.sy;
  for (var i = 0; i < m; i++) {
    final o = (m - 1 - i) * 6;
    final nx = p.pts[o + 4], ny = p.pts[o + 5];
    final w = i * 6;
    out[w] = p.pts[o + 2];
    out[w + 1] = p.pts[o + 3];
    out[w + 2] = p.pts[o];
    out[w + 3] = p.pts[o + 1];
    out[w + 4] = x;
    out[w + 5] = y;
    x = nx;
    y = ny;
  }
  return CubicPath(out, x, y, closed: p.closed);
}

// ---------------------------------------------------------------------------

List<CubicPath> parsePath(String d) {
  final subs = <(_Buf, bool)>[];
  var buf = _Buf();
  var closed = false;
  double cx = 0, cy = 0, sx = 0, sy = 0;
  double lc2x = 0, lc2y = 0, lqx = 0, lqy = 0;
  var last = '';

  void flush() {
    if (buf.pts.isNotEmpty) subs.add((buf, closed));
    buf = _Buf();
    closed = false;
  }

  void line(double x1, double y1, double x2, double y2) {
    buf.cubic(
      x1,
      y1,
      x1 + (x2 - x1) / 3,
      y1 + (y2 - y1) / 3,
      x1 + 2 * (x2 - x1) / 3,
      y1 + 2 * (y2 - y1) / 3,
      x2,
      y2,
    );
  }

  void quad(double x1, double y1, double qx, double qy, double x2, double y2) {
    buf.cubic(
      x1,
      y1,
      x1 + 2 / 3 * (qx - x1),
      y1 + 2 / 3 * (qy - y1),
      x2 + 2 / 3 * (qx - x2),
      y2 + 2 / 3 * (qy - y2),
      x2,
      y2,
    );
  }

  final s = _Scan(d);
  while (!s.eof) {
    s.ws();
    final c = s.peek();
    if (c == null) break;
    if (_isCmd(c)) {
      s.i++;
    } else if (last.isEmpty || 'MmZz'.contains(last)) {
      break; // implicit repeats only after M/L-ish commands
    }
    final rel = c.toLowerCase() == c && _isCmd(c);
    final cmd = c.toLowerCase();
    switch (cmd) {
      case 'm':
        var x = s.num(), y = s.num();
        if (rel) x += cx;
        if (rel) y += cy;
        flush();
        cx = sx = x;
        cy = sy = y;
        buf.start(x, y);
        last = 'M';
        // trailing pairs are implicit line-tos
        while (s.peekNum()) {
          var lx = s.num(), ly = s.num();
          if (rel) lx += cx;
          if (rel) ly += cy;
          line(cx, cy, lx, ly);
          cx = lx;
          cy = ly;
          last = 'L';
        }
        continue;
      case 'l':
        while (s.peekNum()) {
          var x = s.num(), y = s.num();
          if (rel) {
            x += cx;
            y += cy;
          }
          line(cx, cy, x, y);
          cx = x;
          cy = y;
        }
        break;
      case 'h':
        while (s.peekNum()) {
          var x = s.num();
          if (rel) x += cx;
          line(cx, cy, x, cy);
          cx = x;
        }
        break;
      case 'v':
        while (s.peekNum()) {
          var y = s.num();
          if (rel) y += cy;
          line(cx, cy, cx, y);
          cy = y;
        }
        break;
      case 'c':
        while (s.peekNum()) {
          var x1 = s.num(), y1 = s.num(), x2 = s.num(), y2 = s.num();
          var x = s.num(), y = s.num();
          if (rel) {
            x1 += cx;
            y1 += cy;
            x2 += cx;
            y2 += cy;
            x += cx;
            y += cy;
          }
          buf.cubic(cx, cy, x1, y1, x2, y2, x, y);
          lc2x = x2;
          lc2y = y2;
          cx = x;
          cy = y;
        }
        break;
      case 's':
        while (s.peekNum()) {
          var x2 = s.num(), y2 = s.num(), x = s.num(), y = s.num();
          if (rel) {
            x2 += cx;
            y2 += cy;
            x += cx;
            y += cy;
          }
          final x1 = 'cs'.contains(last) ? 2 * cx - lc2x : cx;
          final y1 = 'cs'.contains(last) ? 2 * cy - lc2y : cy;
          buf.cubic(cx, cy, x1, y1, x2, y2, x, y);
          lc2x = x2;
          lc2y = y2;
          cx = x;
          cy = y;
        }
        break;
      case 'q':
        while (s.peekNum()) {
          var qx = s.num(), qy = s.num(), x = s.num(), y = s.num();
          if (rel) {
            qx += cx;
            qy += cy;
            x += cx;
            y += cy;
          }
          quad(cx, cy, qx, qy, x, y);
          lqx = qx;
          lqy = qy;
          cx = x;
          cy = y;
        }
        break;
      case 't':
        while (s.peekNum()) {
          var x = s.num(), y = s.num();
          if (rel) {
            x += cx;
            y += cy;
          }
          final qx = 'qt'.contains(last) ? 2 * cx - lqx : cx;
          final qy = 'qt'.contains(last) ? 2 * cy - lqy : cy;
          quad(cx, cy, qx, qy, x, y);
          lqx = qx;
          lqy = qy;
          cx = x;
          cy = y;
        }
        break;
      case 'a':
        while (s.peekNum()) {
          final r1 = s.num().abs(), r2 = s.num().abs();
          final rot = s.num();
          final large = s.num() != 0, sweep = s.num() != 0;
          var x = s.num(), y = s.num();
          if (rel) {
            x += cx;
            y += cy;
          }
          _arc(buf, cx, cy, r1, r2, rot, large, sweep, x, y, line);
          cx = x;
          cy = y;
        }
        break;
      case 'z':
        if (cx != sx || cy != sy) line(cx, cy, sx, sy);
        cx = sx;
        cy = sy;
        closed = true;
        break;
      default:
        return subs.map((e) => e.$1.build(e.$2)).toList();
    }
    last = cmd;
  }
  flush();
  return [for (final e in subs) e.$1.build(e.$2)];
}

class _Buf {
  late double sx, sy;
  final pts = <double>[];
  bool started = false;

  void start(double x, double y) {
    sx = x;
    sy = y;
    started = true;
  }

  void cubic(
    double x1,
    double y1,
    double c1x,
    double c1y,
    double c2x,
    double c2y,
    double x2,
    double y2,
  ) {
    pts.addAll([c1x, c1y, c2x, c2y, x2, y2]);
  }

  CubicPath build(bool closed) =>
      CubicPath(Float64List.fromList(pts), sx, sy, closed: closed);
}

bool _isCmd(String c) => 'MmLlHhVvCcSsQqTtAaZz'.contains(c);

/// Endpoint arc -> cubic slices (svg spec F.6).
void _arc(
  _Buf buf,
  double x1,
  double y1,
  double r1,
  double r2,
  double angleDeg,
  bool largeArc,
  bool sweep,
  double x2,
  double y2,
  void Function(double, double, double, double) line,
) {
  if ((x1 - x2).abs() < 1e-12 && (y1 - y2).abs() < 1e-12) return;
  if (r1 <= 0 || r2 <= 0) {
    line(x1, y1, x2, y2);
    return;
  }
  final phi = angleDeg * _pi / 180;
  final cp = math.cos(phi), sp = math.sin(phi);
  final dx = (x1 - x2) / 2, dy = (y1 - y2) / 2;
  final x1p = cp * dx + sp * dy;
  final y1p = -sp * dx + cp * dy;
  var rx = r1, ry = r2;
  final lambda = x1p * x1p / (rx * rx) + y1p * y1p / (ry * ry);
  if (lambda > 1) {
    final s = math.sqrt(lambda);
    rx *= s;
    ry *= s;
  }
  final sign = largeArc != sweep ? 1 : -1;
  final num = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p;
  final den = rx * rx * y1p * y1p + ry * ry * x1p * x1p;
  final co = sign * math.sqrt(math.max(0, num / den));
  final cxp = co * rx * y1p / ry;
  final cyp = -co * ry * x1p / rx;
  final ccx = cp * cxp - sp * cyp + (x1 + x2) / 2;
  final ccy = sp * cxp + cp * cyp + (y1 + y2) / 2;

  double ang(double ux, double uy, double vx, double vy) {
    final dot = ux * vx + uy * vy;
    final len = math.sqrt(ux * ux + uy * uy) * math.sqrt(vx * vx + vy * vy);
    var a = math.acos((dot / len).clamp(-1.0, 1.0));
    if (ux * vy - uy * vx < 0) a = -a;
    return a;
  }

  final th1 = ang(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
  var dth = ang(
    (x1p - cxp) / rx,
    (y1p - cyp) / ry,
    (-x1p - cxp) / rx,
    (-y1p - cyp) / ry,
  );
  if (!sweep && dth > 0) {
    dth -= 2 * _pi;
  } else if (sweep && dth < 0) {
    dth += 2 * _pi;
  }
  final segs = (dth.abs() / (_pi / 2)).ceil().clamp(1, 4);
  final delta = dth / segs;
  final t = 4 / 3 * math.tan(delta / 4);
  var th = th1;
  var px = x1, py = y1;
  for (var i = 0; i < segs; i++) {
    final th2 = th + delta;
    final c1 = _arcPt(ccx, ccy, rx, ry, cp, sp, th, -t);
    final c2 = _arcPt(ccx, ccy, rx, ry, cp, sp, th2, t);
    final ex = _arcPt(ccx, ccy, rx, ry, cp, sp, th2, 0);
    buf.cubic(px, py, c1.$1, c1.$2, c2.$1, c2.$2, ex.$1, ex.$2);
    px = ex.$1;
    py = ex.$2;
    th = th2;
  }
}

(double, double) _arcPt(
  double cx,
  double cy,
  double rx,
  double ry,
  double cp,
  double sp,
  double th,
  double t,
) {
  final c = math.cos(th), s = math.sin(th);
  final x = rx * (c - t * s);
  final y = ry * (s + t * c);
  return (cp * x - sp * y + cx, sp * x + cp * y + cy);
}

class _Scan {
  final String s;
  int i = 0;

  _Scan(this.s);

  bool get eof => i >= s.length;

  void ws() {
    while (i < s.length && ' ,\t\n\r'.contains(s[i])) {
      i++;
    }
  }

  String? peek() {
    ws();
    return eof ? null : s[i];
  }

  bool peekNum() {
    ws();
    if (eof) return false;
    final c = s[i];
    return '0123456789'.contains(c) ||
        ((c == '-' || c == '+' || c == '.') &&
            i + 1 < s.length &&
            '0123456789'.contains(s[i + 1]));
  }

  double num() {
    ws();
    final start = i;
    if (i < s.length && (s[i] == '-' || s[i] == '+' || s[i] == '.')) i++;
    var dots = s[start] == '.' ? 1 : 0;
    while (i < s.length) {
      final c = s[i];
      if ('0123456789'.contains(c)) {
        i++;
      } else if (c == '.' && dots == 0) {
        dots++;
        i++;
      } else if ((c == 'e' || c == 'E') && i + 1 < s.length) {
        final n = s[i + 1];
        if ('0123456789+-'.contains(n)) {
          i += 2;
        } else {
          break;
        }
      } else {
        break;
      }
    }
    final r = double.tryParse(s.substring(start, i)) ?? 0;
    return r;
  }
}
