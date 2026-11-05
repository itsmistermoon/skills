#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["numpy", "svgelements", "resvg-py"]
# ///
"""Measure an SVG and render a deliberately designed construction plan."""
import argparse
import json
import math
from pathlib import Path as FilePath
import xml.etree.ElementTree as ET

import numpy as np
import resvg_py
from svgelements import SVG, Shape, Path, Move, Close

NS = 'http://www.w3.org/2000/svg'
ET.register_namespace('', NS)

def tag(name):
    return f'{{{NS}}}{name}'

def shapes(filename):
    paths = [Path(e) for e in SVG.parse(filename).elements() if isinstance(e, Shape) and e.bbox()]
    for path in paths:
        path.reify()
    return paths

def point(p):
    return [float(p.x), float(p.y)]

def measure(items):
    result = []
    for i, path in enumerate(items):
        segments = []
        for seg in path:
            if isinstance(seg, (Move, Close)) or seg.start is None or seg.end is None:
                continue
            samples = np.array([point(seg.point(t)) for t in np.linspace(0, 1, 60)])
            entry = {'type': type(seg).__name__, 'start': point(seg.start), 'end': point(seg.end)}
            for name in ('control1', 'control2', 'control'):
                if hasattr(seg, name):
                    entry[name] = point(getattr(seg, name))
            # A line has no finite circle; fitting one would invent a huge radius.
            if type(seg).__name__ != 'Line':
                A = np.c_[2 * samples, np.ones(len(samples))]
                x = np.linalg.lstsq(A, (samples ** 2).sum(1), rcond=None)[0]
                radius = math.sqrt(max(0, x[2] + x[:2] @ x[:2]))
                error = float(np.abs(np.linalg.norm(samples - x[:2], axis=1) - radius).max())
                entry['circle'] = {'center': x[:2].tolist(), 'radius': radius, 'max_error': error,
                                   'circular': bool(radius > 0 and error < .01 * radius)}
            segments.append(entry)
        result.append({'index': i, 'bbox': list(path.bbox()), 'segments': segments})
    return result

def render(items, plan, output):
    selected = [items[i] for i in plan['shapes']]
    boxes = [p.bbox() for p in selected]
    x0, y0 = min(b[0] for b in boxes), min(b[1] for b in boxes)
    x1, y1 = max(b[2] for b in boxes), max(b[3] for b in boxes)
    if x1 == x0 or y1 == y0:
        raise ValueError('Selected logo must have nonzero width and height')
    scale = min(612 / (y1-y0), 1500 / (x1-x0))
    tx, ty = 1280 - scale*(x0+x1)/2, 720 - scale*(y0+y1)/2
    root = ET.Element(tag('svg'), {'width':'2560', 'height':'1440', 'viewBox':'0 0 2560 1440'})
    ET.SubElement(root, tag('rect'), {'width':'2560', 'height':'1440', 'fill':'#f7f7f5'})
    styles = {'auxiliary': ('#999999', '1', None), 'guides': ('#0080dc', '.5', '5 5'),
              'construction': ('#4d4d4d', '1', None)}
    transform = f'translate({tx} {ty}) scale({scale})'
    for level in ('auxiliary', 'guides', 'construction'):
        group = ET.SubElement(root, tag('g'), {'id':level, 'transform':transform, 'fill':'none',
                              'stroke':styles[level][0], 'stroke-width':str(float(styles[level][1])/scale),
                              'stroke-linecap':'round', 'stroke-linejoin':'round'})
        if styles[level][2]:
            group.set('stroke-dasharray', ' '.join(str(float(v)/scale) for v in styles[level][2].split()))
        for primitive in plan.get(level, []):
            kind = primitive['type']
            if kind not in ('line', 'circle', 'rect', 'polyline', 'polygon', 'path'):
                raise ValueError(f'Unsupported primitive: {kind}')
            ET.SubElement(group, tag(kind), {k:str(v) for k,v in primitive.items() if k != 'type'})
    logo = ET.SubElement(root, tag('g'), {'id':'logo', 'transform':transform, 'fill':'#000000',
                         'fill-opacity':'.1', 'stroke':'#1f1f1f', 'stroke-width':str(2/scale),
                         'stroke-linejoin':'round'})
    for path in selected:
        ET.SubElement(logo, tag('path'), {'d':path.d(), 'fill-rule':path.values.get('fill-rule', 'nonzero')})
    anchors = ET.SubElement(root, tag('g'), {'id':'anchors', 'transform':transform, 'fill':'#f7f7f5',
                            'stroke':'#0080dc', 'stroke-width':str(1.5/scale)})
    for a in plan.get('anchors', []):
        x, y = a['x'], a['y']
        r = 6/scale
        if a.get('square'):
            ET.SubElement(anchors, tag('rect'), {'x':str(x-r), 'y':str(y-r), 'width':str(2*r), 'height':str(2*r)})
        else:
            ET.SubElement(anchors, tag('circle'), {'cx':str(x), 'cy':str(y), 'r':str(r)})
    svg = ET.tostring(root, encoding='unicode')
    output.with_suffix('.svg').write_text(svg)
    output.with_suffix('.png').write_bytes(resvg_py.svg_to_bytes(svg_string=svg))

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    a = sub.add_parser('measure'); a.add_argument('svg')
    r = sub.add_parser('render'); r.add_argument('svg'); r.add_argument('plan'); r.add_argument('output')
    args = parser.parse_args()
    items = shapes(args.svg)
    if args.command == 'measure':
        print(json.dumps(measure(items), indent=2))
    else:
        plan = json.loads(FilePath(args.plan).read_text())
        render(items, plan, FilePath(args.output))

if __name__ == '__main__':
    main()
