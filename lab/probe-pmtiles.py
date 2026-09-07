# The address-finder for Act IV lab experiment 4 (read only what you need), 2026-09-07.
# Reads a public PMTiles archive's header (127 bytes) and root directory (a few KB) over HTTP
# Range requests, and prints the byte address of one tile - the constant the experiment patch
# fetches BY OFFSET and draws. Kept so the address is reproducible and the parsing auditable,
# like lab/cut-tiles.py for the layouts Explanation.
#
# The directory parsing lives HERE, outside the patch, on purpose: the experiment's claim is
# "a remote file can be read by address", not "vvvv can parse varints" - and being honest about
# which half the patch does is part of the lab's rules.
#
# PMTiles v3 facts this script encodes (spec: github.com/protomaps/PMTiles):
#   header: magic 'PMTiles' + version, then little-endian u64 pairs - root dir offset/len at 8,
#     metadata at 24, tile data at 40; bytes 97/98/99 = internal/tile compression, tile type;
#   directories: gzip if internal compression = 2; varint streams - n, then n tile-id deltas,
#     n run lengths, n lengths, n offsets, where a NON-ZERO offset is stored as offset+1 and a
#     zero means "immediately after the previous tile" (the +1 cost this lab one wrong byte:
#     the first fetch returned d8ffe0.. instead of ffd8ff.. - a JPEG missing its first byte);
#   tile ids: cumulative per zoom, Hilbert-ordered within each zoom.
#
# Usage: python -X utf8 lab/probe-pmtiles.py [url] [zoom]
import sys, urllib.request, struct, gzip, json

URL = sys.argv[1] if len(sys.argv) > 1 else \
    'https://raw.githubusercontent.com/maplibre/demotiles/gh-pages/pmtiles/raster/watercolor.pmtiles'
WANT_Z = int(sys.argv[2]) if len(sys.argv) > 2 else 4


def rng(start, length):
    req = urllib.request.Request(URL, headers={'Range': f'bytes={start}-{start + length - 1}'})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read(), r.headers.get('Content-Range', '?')


def varints(b):
    out, shift, val = [], 0, 0
    for byte in b:
        val |= (byte & 0x7f) << shift
        if byte & 0x80:
            shift += 7
        else:
            out.append(val); val = 0; shift = 0
    return out


def id_to_zxy(tid):
    z, acc = 0, 0
    while acc + (1 << (2 * z)) <= tid:
        acc += 1 << (2 * z); z += 1
    pos = tid - acc
    n2 = 1 << z; x = y = 0; t = pos; s = 1
    while s < n2:                      # Hilbert d2xy
        rx = 1 & (t // 2); ry = 1 & (t ^ rx)
        if ry == 0:
            if rx == 1:
                x = s - 1 - x; y = s - 1 - y
            x, y = y, x
        x += s * rx; y += s * ry
        t //= 4; s *= 2
    return z, x, y


hdr, cr = rng(0, 127)
assert hdr[:7] == b'PMTiles', hdr[:12]
total = int(cr.split('/')[-1])
root_off, root_len = struct.unpack('<QQ', hdr[8:24])
meta_off, meta_len = struct.unpack('<QQ', hdr[24:40])
td_off = struct.unpack('<Q', hdr[40:48])[0]
ic, tc, tt = hdr[97], hdr[98], hdr[99]
print(f'archive : {URL}')
print(f'total   : {total:,} bytes | tile type {tt} (2=png 3=jpg 4=webp) | tile compression {tc} (1=none 2=gzip)')

mraw, _ = rng(meta_off, meta_len)
meta = json.loads(gzip.decompress(mraw) if ic == 2 else mraw)
print(f'credit  : {meta.get("attribution", "?")}')

draw, _ = rng(root_off, root_len)
d = gzip.decompress(draw) if ic == 2 else draw
vs = varints(d)
n = vs[0]
dids, runl, lens, offs = vs[1:1 + n], vs[1 + n:1 + 2 * n], vs[1 + 2 * n:1 + 3 * n], vs[1 + 3 * n:1 + 4 * n]
ids, cur = [], 0
for i in range(n):
    cur += dids[i]; ids.append(cur)
abs_off = []
for i in range(n):
    if offs[i] == 0 and i > 0:
        abs_off.append(abs_off[-1] + lens[i - 1])
    else:
        abs_off.append(offs[i] - 1)

print(f'root dir: {n} entries read from {root_len:,} bytes at offset {root_off}')
for i in range(n):
    z, x, y = id_to_zxy(ids[i])
    if z == WANT_Z and runl[i] == 1:
        start = td_off + abs_off[i]
        tile, cr2 = rng(start, lens[i])
        magic = tile[:4].hex()
        ok = magic in ('ffd8ffe0', 'ffd8ffe1', '89504e47', '52494646')
        print(f'tile    : z{z} x{x} y{y}')
        print(f'address : bytes {start}-{start + lens[i] - 1}  ({lens[i]:,} bytes, '
              f'{lens[i] / total * 100:.2f}% of the archive)')
        print(f'range   : "Range: bytes={start}-{start + lens[i] - 1}"   <- the patch constant')
        print(f'fetched : magic {magic} {"(valid image)" if ok else "(NOT an image - check the offsets)"}')
        break
else:
    raise SystemExit(f'no leaf entry at z{WANT_Z} in the root directory')
