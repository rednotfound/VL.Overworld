# Act IV laboratory — what if the world doesn't fit in memory?

Opened 2026-09-06, per the phase brief. This is a **lab notebook**, not a curriculum document:
experiments live in `lab\` (deliberately outside `help\` — not packed, not validated by
`Test-VLPackage.ps1`, compiled ad hoc with vvvvc), results live here, and **nothing gets a chapter
number until several prototypes show the same recurring mental-model shift**. Technologies
(COG, PMTiles, GeoParquet, STAC, COPC, Zarr) may appear only as answers to a contradiction the
learner has already felt — never as one-format-per-chapter.

The rules of the lab:

1. **The contradiction comes first.** Every experiment starts from a learner-visible absurdity
   ("the dataset is 100 GB; this view needs 0.2%"), not from a format name.
2. **No new permanent library surface.** An experiment that needs one stops and becomes a scope
   question (CLAUDE.md's architecture rule). Every node in every prototype below already shipped.
3. **Network consent as everywhere else** — a lab prototype fetches on a toggle, not on open.
   (The self-test variants that auto-fetch live in the session scratchpad and are not committed.)
4. **Results are numbers, recorded here**, so the eventual "does this deserve a unit?" decision is
   made against measurements rather than enthusiasm.

The candidate mental model, to be confirmed or killed by the experiments:

> **How much you read, and how sharp you read it, are part of the query — not properties of the
> file.** Space can be partitioned; resolution can be laddered; a well-organised dataset answers a
> small question with a small read.

---

## Experiment 1 — the tile ledger (measured 2026-09-06, no patch needed yet)

**Contradiction:** you have used this course's maps for weeks. How much of the world did that cost?

**Method:** count what actually sits in `%LOCALAPPDATA%\VL.Mapsui\tiles` after every session of
this course so far, against the size of the pyramids those tiles came from.

**Result:**

| source | tiles on disk | size |
|---|---|---|
| OpenStreetMap (two URL variants) | 1441 + 1509 | 25.9 + 32.2 MB |
| CyclOSM | 219 | 9.0 MB |
| OpenTopoMap | 126 | 5.0 MB |
| EOX (satellite / night / terrain) | 127 | 1.3 MB |
| **total, all sessions ever** | **3,422** | **≈ 73 MB** |

Against the world: zoom 17 alone holds 4^17 ≈ **17.2 billion** tiles; a full pyramid to z19 is
≈ 366 billion. The most-used folder (OSM, touched at every zoom 0–19) holds 1,509 of them —
**about 0.0000004%**, and the maps always felt complete. Nobody ever asked for the world; the
viewport asked for a window, at a sharpness, and the pyramid answered with exactly that.

**Concepts hiding underneath:** spatial partitioning + viewport culling — the entire motivation
for every cloud-native format. **Learner vehicle (not built yet):** a live request counter beside
a 06-style map — "this pan cost 6 tiles; the world has 17 billion". Zero new surface needed
(`Cache Status` names the folder; counting files is CoreLib IO).

## Experiment 2 — the resolution ladder (built and measured 2026-09-06)

**Prototype:** `lab\Experiment resolution ladder.vl` — one place (the summit of Fuji,
138.7274 E 35.3606 N, true height 3776 m) asked its height six times, once per Terrarium zoom
level 8–13. One FETCH toggle, six fetches; per column: the tile itself, metres per pixel, the
height read at the summit pixel, the bytes that answer cost. All existing nodes (`HTTPGet` →
`HoldLatest` → `Split` → `If`-guarded `ImageDecoder` → `Pipet`, the How-high chain, six times).

**Result (2026-09-06):**

| zoom | m/pixel | height read (m) | bytes fetched |
|---|---|---|---|
| 8 | 499 | 3705 | 121,606 |
| 9 | 249 | 3702 | 100,739 |
| 10 | 125 | 3702 | 65,113 |
| 11 | 62 | 3744 | 51,819 |
| 12 | 31 | 3754 | 48,801 |
| 13 | 16 | 3753 | 40,332 |

Three findings, two expected and one not:

1. **The ladder climbs toward the truth** — six zoom levels buy ~50 m of summit (a 500 m pixel
   averages the peak with its shoulders; a 16 m pixel almost doesn't). The picture makes the same
   argument by itself: the tile column goes from mush to concentric contour rings of one mountain.
2. **Any sharpness is one fetch away** — nothing was recomputed, no "full dataset" was ever
   touched; the pyramid stores the world pre-summarised at every level, for about ⅓ extra space.
   This is a mipmap; it is also COG overviews and the COPC hierarchy, and the prototype needed
   none of those words.
3. **Unexpected: per-tile bytes FALL as zoom rises** (121 KB → 40 KB) — close-up terrain is
   smoother, so PNG compresses better. "Sharper costs more" is wrong per tile; the real cost of
   sharpness is **tile count per area covered** (×4 per level). An experiment correcting the
   experimenter's own intuition is the lab working as intended.

**Verdict so far:** the mental model reads clearly ("resolution is part of access"), and the
prototype was legible without any format vocabulary. This is currently the strongest candidate to
grow into a concept unit — per the lab rule, **after** at least one more experiment points at the
same shift. Candidate framings if it ever ships: the fixed-place ladder as an `Explanation`
("Sharper is a different question"), or folded into a future conceptual chapter with Experiment 1.

## Experiment 3 — same data, two layouts (built and measured 2026-09-06)

**Prototype:** `lab\Experiment two layouts.vl` + `lab\Assets\haneda-tiles\` (the 754 Haneda
features recut into an 8 x 8 centroid grid: 32 files, median ~9 KB, derived from
`help/Assets/haneda.geojson`, same ODbL terms). Point at a cell; two pipelines answer *how many
features have their centre here* — the monolith re-reads and re-parses everything per query (on
purpose: that is what a fresh question against a remote file costs), the partitioned side reads
exactly one small file whose NAME the question's location computed.

**Result (cell 4,4 — the runway cluster):**

| | bytes read | features parsed | in cell |
|---|---|---|---|
| one file | 306,984 | 754 | **31** |
| many files | 11,659 | 31 | **31** |

Equal answers, **26x fewer bytes, 24x fewer features parsed** — and nothing about the data
changed, only its arrangement on disk. Chapter 11 one storey down: the index there pruned who gets
*asked*; the layout here prunes what gets *read*. Empty cell = no file = the reader fails and says
so: absence you can read off a directory.

**Three findings from the building, each a contract lesson in miniature:**

1. **"The same rule" must be literally the same rule.** First run: mono said 31 in-cell, tiles said
   33 — the preprocessing had used a vertex-average centroid while the patch's `Centroid` (NTS) is
   the area/length-weighted one, and two features near cell edges changed allegiance. The tiles
   were recut with NTS's definitions (shoelace for polygons, length-weighted for lines). A
   partition is a claim about the data, and the claim has to name its formula.
2. **A `Path` IOBox resolves against the document; a Path computed at runtime does not.** `ToPath`
   on a relative string resolved against the process working directory and silently read nothing —
   the fix is a Path *pad* for the folder (document-resolved at load) plus `Combine` with the
   computed filename (`Combine` takes Path + Path; the filename string goes through `ToPath`).
   Worth remembering anywhere a patch computes file names.
3. **vvvvc wants an absolute document path for documents outside `help\`** — a relative one dies
   in deserialisation with `The base path must be absolute` before compiling anything.

**Verdict:** second experiment, same recurring shift. Experiment 2 said *how sharp you read is part
of the query*; experiment 3 says *how much you read is part of the query, and the layout decides
it*. The lab's candidate mental model now has two independent confirmations — by the lab's own
rule, that is the threshold for proposing (not yet writing) a conceptual unit. The proposal
question for the next session: one unit or two, and which genre — the ladder wants to be an
`Explanation`, the layouts experiment might be the interactive heart of an eventual
*"What if the world doesn't fit in memory?"* chapter. **No number is claimed yet.**

## Experiment 4 — read only what you need (reconnaissance, not built)

**Contradiction:** a 50 GB file of which we read 30 KB.

**First question, before any design:** can vvvv's `HTTPGet` send a `Range` header at all? If not,
this experiment stops there and the finding is recorded here (a gap noted for a future scope
discussion — NOT implemented on the spot). If yes: fetch one tile out of a public PMTiles archive
by offset, draw it, and show the request log. Medium risk; everything stays prototype-only.

---

## Ledger of lab findings that already changed the course

- Experiment 2's finding 3 (bytes fall with zoom) is worth a sentence in `Prompt How high is here`
  the next time that patch is touched — not worth its own edit round.
