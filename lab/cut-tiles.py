# The derivation of help/Assets/haneda-tiles/ from help/Assets/haneda.geojson — recorded so the
# cut is reproducible and its RULE is auditable. Written for Act IV lab experiment 3 (2026-09-06),
# kept because the tiles shipped with `Explanation You don't have to read everything`.
#
# The rule: each feature belongs to exactly ONE cell of an 8x8 grid — the cell holding its
# CENTROID, computed by NetTopologySuite's definitions (shoelace centroid for polygons,
# length-weighted midpoint average for lines), because the patch's in-cell check uses NTS's
# `Centroid` and "the same rule" must be literally the same rule: the first cut used a
# vertex-average centroid and two edge features changed allegiance (31 vs 33 — the lab notebook,
# experiment 3, finding 1). Real tilers CLIP or DUPLICATE instead; centroid assignment is the
# honest simplification this Explanation declares.
#
# Usage:  python -X utf8 lab/cut-tiles.py [output-dir]     (default: help/Assets/haneda-tiles)
import json, os, sys

SRC = os.path.join(os.path.dirname(__file__), '..', 'help', 'Assets', 'haneda.geojson')
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(
    os.path.dirname(__file__), '..', 'help', 'Assets', 'haneda-tiles')

# grid constants: the data's own bounding box at the time of the cut, split 8x8. Frozen here —
# recomputing them from a changed haneda.geojson would silently move every cell boundary.
GX0, GY0 = 139.754736, 35.529379
CW, CH = 0.008334, 0.006078
N = 8


def line_centroid(coords):
    # NTS CentroidLine: average of segment midpoints weighted by segment length.
    sx = sy = total = 0.0
    for (x0, y0), (x1, y1) in zip(coords, coords[1:]):
        seg = ((x1 - x0) ** 2 + (y1 - y0) ** 2) ** 0.5
        sx += seg * (x0 + x1) / 2
        sy += seg * (y0 + y1) / 2
        total += seg
    if total == 0:
        xs = [c[0] for c in coords]; ys = [c[1] for c in coords]
        return sum(xs) / len(xs), sum(ys) / len(ys)
    return sx / total, sy / total


def polygon_centroid(rings):
    # NTS CentroidArea: shoelace over the shell, holes subtracting (their winding flips the
    # signed area). Degenerate zero-area polygons fall back to the boundary's line centroid.
    sx = sy = area = 0.0
    for ring in rings:
        for (x0, y0), (x1, y1) in zip(ring, ring[1:]):
            cross = x0 * y1 - x1 * y0
            area += cross
            sx += (x0 + x1) * cross
            sy += (y0 + y1) * cross
    if area == 0:
        return line_centroid([c for ring in rings for c in ring])
    return sx / (3 * area), sy / (3 * area)


def centroid(geom):
    if geom['type'] == 'LineString':
        return line_centroid(geom['coordinates'])
    if geom['type'] == 'Polygon':
        return polygon_centroid(geom['coordinates'])
    raise SystemExit(f"no centroid rule recorded for {geom['type']} - add it before cutting")


src = json.load(open(SRC, encoding='utf-8'))
cells = {}
for f in src['features']:
    cx, cy = centroid(f['geometry'])
    ix = int((cx - GX0) / CW)
    iy = int((cy - GY0) / CH)
    ix = min(max(ix, 0), N - 1); iy = min(max(iy, 0), N - 1)
    cells.setdefault((ix, iy), []).append(f)

os.makedirs(OUT, exist_ok=True)
for (ix, iy), feats in sorted(cells.items()):
    path = os.path.join(OUT, f'tile_{ix}_{iy}.geojson')
    with open(path, 'w', encoding='utf-8', newline='') as fh:
        json.dump({'type': 'FeatureCollection', 'features': feats}, fh,
                  ensure_ascii=False, separators=(',', ':'))
print(f'{len(src["features"])} features -> {len(cells)} tiles in {OUT}')
