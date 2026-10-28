#!/usr/bin/env python3
"""Render-tree probe via VM service evaluate; output written to a file by the
app itself (dart:io is in scope in app_bootstrap.dart), bypassing the VM's
128-char valueAsString truncation.

Usage: probe_file.py <vm_ws_uri> <out_path> [mode]
Modes:
  area:<maxy>   nodes with absY < maxy (default 260) with absolute offsets
  full          whole tree, relative offsets
"""
import asyncio
import json
import sys

import websockets

AREA = r'''(() { final out = StringBuffer(); final stack = <dynamic>[WidgetsBinding.instance.renderView]; final abs = <dynamic>[0.0]; final dep = <int>[0]; var count = 0; while (stack.isNotEmpty && count < 8000) { final ro = stack.removeLast(); final ay = abs.removeLast(); final d = dep.removeLast(); count = count + 1; final kids = <dynamic>[]; ro.visitChildren((dynamic c) { kids.add(c); }); var w = -1.0; var h = -1.0; try { w = ro.size.width; h = ro.size.height; } catch (e) {} if (ay < MAXY && ay > -0.5) { var off = ""; try { off = ro.parentData.offset.toString(); } catch (e) {} out.writeln("d" + d.toString() + " " + ro.runtimeType.toString() + " " + w.toString() + "x" + h.toString() + " absY=" + ay.toStringAsFixed(1) + " off=" + off); } var i = kids.length - 1; while (i >= 0) { final k = kids[i]; i = i - 1; var ky = ay; try { ky = ay + k.parentData.offset.dy; } catch (e) {} stack.add(k); abs.add(ky); dep.add(d + 1); } } File(OUTPATH).writeAsStringSync(out.toString()); return "wrote " + out.length.toString() + " chars, " + count.toString() + " nodes"; })()'''

FULL = r'''(() { final out = StringBuffer(); final stack = <dynamic>[WidgetsBinding.instance.renderView]; final dep = <int>[0]; var count = 0; while (stack.isNotEmpty && count < 9000) { final ro = stack.removeLast(); final d = dep.removeLast(); count = count + 1; final kids = <dynamic>[]; ro.visitChildren((dynamic c) { kids.add(c); }); var prefix = ""; var i0 = 0; while (i0 < d) { prefix = prefix + "."; i0 = i0 + 1; } var size = "?"; try { size = ro.size.toString(); } catch (e) {} var off = ""; try { off = ro.parentData.offset.toString(); } catch (e) {} out.writeln(prefix + ro.runtimeType.toString() + " size=" + size + " off=" + off); var i = kids.length - 1; while (i >= 0) { stack.add(kids[i]); dep.add(d + 1); i = i - 1; } } File(OUTPATH).writeAsStringSync(out.toString()); return "wrote " + out.length.toString() + " chars, " + count.toString() + " nodes"; })()'''


async def main():
    uri, out_path = sys.argv[1], sys.argv[2]
    mode = sys.argv[3] if len(sys.argv) > 3 else 'area:260'
    tpl = FULL if mode == 'full' else AREA
    maxy = float(mode.split(':')[1]) if ':' in mode else 260.0
    expr = tpl.replace('MAXY', str(int(maxy))).replace('OUTPATH', json.dumps(out_path))
    async with websockets.connect(uri, max_size=64 * 1024 * 1024) as ws:
        rid = 0

        async def call(method, params=None):
            nonlocal rid
            rid += 1
            await ws.send(json.dumps({'jsonrpc': '2.0', 'id': rid,
                                      'method': method, 'params': params or {}}))
            while True:
                msg = json.loads(await ws.recv())
                if msg.get('id') == rid:
                    return msg

        vm = await call('getVM')
        iso = vm['result']['isolates'][0]['id']
        info = await call('getIsolate', {'isolateId': iso})
        lib = next(l for l in info['result']['libraries']
                   if l['uri'].endswith('app_bootstrap.dart'))
        r = await call('evaluate', {'isolateId': iso, 'targetId': lib['id'],
                                    'expression': ' '.join(expr.split())})
        res = r.get('result', {})
        if 'valueAsString' in res:
            print(res['valueAsString'])
        else:
            print('ERR:', json.dumps(r)[:400])


asyncio.run(main())
