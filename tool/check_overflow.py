#!/usr/bin/env python3
"""Detect RenderFlex-style overflow in probe_file.py output.

Reads the depth/size/absY lines (dN Type WxH absY=... off=...), tracks the
ancestor chain by depth, and flags any child whose bottom edge exceeds its
parent's bottom edge — the geometric signature of a "RenderFlex OVERFLOWING"
error that window-bounds audits cannot see (the canvas sits inside the
window, so the spill stays on-screen).

Subtrees under scrollables (RenderViewport / _RenderTheater / scrollables)
are skipped: children taller than the viewport are normal there.

Usage: check_overflow.py <area_or_full_dump.txt>
"""
import re
import sys

NODE = re.compile(r'^d(\d+) (\S+) (-?[\d.]+)x(-?[\d.]+) absY=(-?[\d.]+)')
# Only real scroll containers: children taller than these are normal.
# (_RenderTheater is the Navigator overlay — NOT a scroller; matching it
# would skip the entire app tree, which is exactly what made the first
# version of this check blind.)
SCROLLABLE = ('RenderViewport', 'ShrinkWrappingViewport')


def main(path):
    stack = []  # (depth, absY, height, type)
    issues = 0
    in_scroll = 0
    for ln in open(path, encoding='utf-8', errors='replace'):
        m = NODE.match(ln)
        if not m:
            continue
        d, t, w, h, y = (int(m.group(1)), m.group(2), float(m.group(3)),
                         float(m.group(4)), float(m.group(5)))
        while stack and stack[-1][0] >= d:
            popped = stack.pop()
            if any(s in popped[3] for s in SCROLLABLE):
                in_scroll -= 1
        if not stack:
            in_scroll = 0
        parent = stack[-1] if stack else None
        if parent and in_scroll == 0 and h > 0 and parent[2] > 0:
            bottom = y + h
            pb = parent[1] + parent[2]
            # 1px: FittedBox scaleDown rounding produces sub-pixel spills
            # that Flutter itself never reports.
            if bottom > pb + 1.0:
                print(f'  OVERFLOW d{d} {t} bottom={bottom:.1f} > parent '
                      f'd{parent[0]} {parent[3]} bottom={pb:.1f} '
                      f'(spill {bottom - pb:.1f}px)')
                issues += 1
        stack.append((d, y, h, t))
        if any(s in t for s in SCROLLABLE):
            in_scroll += 1
    print(f'== parent-overflow issues: {issues}')
    return issues


if __name__ == '__main__':
    sys.exit(0 if main(sys.argv[1]) == 0 else 1)
