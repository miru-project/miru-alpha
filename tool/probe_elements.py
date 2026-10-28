#!/usr/bin/env python3
"""Element-tree probe: walks the Widget tree printing WIDGET runtimeType +
render size + absY, so a misrendering region can be attributed to exact
widget classes. Output written to a file via dart:io (VM truncates strings).

Usage: probe_elements.py <vm_ws_uri> <out_path> [miny] [maxy]
"""
import asyncio
import json
import sys

import websockets

PROBE = r'''(() { final out = StringBuffer(); final stack = <dynamic>[WidgetsBinding.instance.rootElement]; final dep = <int>[0]; final abs = <dynamic>[0.0]; var count = 0; while (stack.isNotEmpty && count < 9000) { final el = stack.removeLast(); final d = dep.removeLast(); final ay = abs.removeLast(); count = count + 1; final kids = <dynamic>[]; el.visitChildren((dynamic c) { kids.add(c); }); var w = -1.0; var h = -1.0; try { var ro = el.renderObject; if (ro is RenderBox) { if (ro.hasSize) { w = ro.size.width; h = ro.size.height; } } } catch (e) {} if (ay >= MINY && ay <= MAXY && w > 0) { out.writeln("d" + d.toString() + " " + el.widget.runtimeType.toString() + " " + w.toString() + "x" + h.toString() + " absY=" + ay.toStringAsFixed(1)); } var i = kids.length - 1; while (i >= 0) { final k = kids[i]; i = i - 1; var ky = ay; try { ky = ay + k.renderObject.parentData.offset.dy; } catch (e) { try { ky = ay + k.renderObject.size.height * 0.0; } catch (e2) {} } stack.add(k); abs.add(ky); dep.add(d + 1); } } File(OUTPATH).writeAsStringSync(out.toString()); return "wrote " + out.length.toString() + " chars, " + count.toString() + " elements"; })()'''


async def main():
    uri, out_path = sys.argv[1], sys.argv[2]
    miny = float(sys.argv[3]) if len(sys.argv) > 3 else 400.0
    maxy = float(sys.argv[4]) if len(sys.argv) > 4 else 915.0
    expr = (PROBE.replace('MINY', str(int(miny))).replace('MAXY', str(int(maxy)))
            .replace('OUTPATH', json.dumps(out_path)))
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
            print(res['valueAsString'][:200])
        else:
            print('ERR:', json.dumps(r)[:400])


asyncio.run(main())
