#!/usr/bin/env python3
"""Audit a marionette get-interactive-elements dump for layout errors.

Usage: audit.py <dump.txt> [viewport_w] [viewport_h]
Viewport defaults to the MaterialApp node's bounds.
Flags: out-of-bounds, zero-size, text-overlap, raw-i18n-keys, suspicious dups.
"""
import re
import sys

NODE = re.compile(r'Type: (?P<type>[^,]+)(?:, Key: "(?P<key>[^"]*)")?(?:, Text: "(?P<text>.*)")?.*bounds: \{"x":(?P<x>-?\d+),"y":(?P<y>-?\d+),"width":(?P<w>-?\d+),"height":(?P<h>-?\d+)\}')
I18N = re.compile(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$')


def parse(path):
    nodes = []
    for line in open(path, encoding='utf-8', errors='replace'):
        m = NODE.search(line)
        if not m:
            continue
        nodes.append({
            'type': m.group('type'),
            'key': m.group('key') or '',
            'text': m.group('text') or '',
            'rect': tuple(int(m.group(k)) for k in ('x', 'y', 'w', 'h')),
            'line': line.strip(),
        })
    return nodes


def overlap(a, b):
    ax, ay, aw, ah = a
    bx, by, bw, bh = b
    ix = max(0, min(ax + aw, bx + bw) - max(ax, bx))
    iy = max(0, min(ay + ah, by + bh) - max(ay, by))
    return ix * iy


def audit(path):
    nodes = parse(path)
    if not nodes:
        print(f'FATAL: no nodes parsed from {path}')
        return 2
    vw = max(n['rect'][0] + n['rect'][2] for n in nodes)
    vh = max(n['rect'][1] + n['rect'][3] for n in nodes)
    print(f'== {path}: {len(nodes)} nodes, viewport ~{vw}x{vh}')
    issues = 0

    for n in nodes:
        x, y, w, h = n['rect']
        tag = f"[{n['type']}{':' + n['text'] if n['text'] else ''}] @({x},{y} {w}x{h})"
        if x < 0 or y < 0:
            print(f'  NEGATIVE-ORIGIN {tag}'); issues += 1
        if w <= 0 or h <= 0:
            print(f'  ZERO-SIZE {tag}'); issues += 1
        if x + w > vw + 1 or y + h > vh + 1:
            print(f'  OUT-OF-BOUNDS {tag} (viewport {vw}x{vh})'); issues += 1
        if n['type'] == 'Text' and I18N.match(n['text']) and n['text'].count('.') >= 1 and '_' in n['text']:
            print(f'  RAW-I18N-KEY {tag}'); issues += 1

    texts = [n for n in nodes if n['type'] in ('Text', 'RichText') and n['text']]
    for i in range(len(texts)):
        for j in range(i + 1, len(texts)):
            a, b = texts[i], texts[j]
            ar, br = a['rect'], b['rect']
            if ar == br:
                continue
            ov = overlap(ar, br)
            if ov == 0:
                continue
            frac = ov / min(ar[2] * ar[3], br[2] * br[3])
            if frac > 0.35:
                print(f'  TEXT-OVERLAP ({frac:.0%}) [{a["text"]}] {ar} vs [{b["text"]}] {br}')
                issues += 1
    print(f'== issues: {issues}')
    return issues


if __name__ == '__main__':
    sys.exit(0 if audit(sys.argv[1]) == 0 else 1)
