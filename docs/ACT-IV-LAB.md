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

## The second unit shipped — `Explanation Sharper is a different question` (2026-09-07)

Experiment 2's ladder, rebuilt cursor-driven on the How-high chassis, **all four rungs the same
day**. What shipped beyond the prototype: an OSM map (Basemap toggle, off) with drag/wheel; the
place under the cursor asked at all six Terrarium zooms at once (Elevation toggle, off), each
column re-fetching only when ITS OWN tile number changes — so gliding the cursor makes the
pyramid's cost structure visible live (the sharp columns ask every ~4 km of ground, the coarse
ones every ~130); live m/px per column (`C_z · cos(latitude)`); the bytes-fall finding on the
picture and in the narrative; the asked place spoken as WKT (`Coordinate → Point → Write WKT` —
NTS's honest job here). The shared Mercator head is computed once; each column differs from its
neighbours by exactly one constant, 2^zoom — which is the chapter's argument made of wire.

Rung 4 in two halves again: **the camera caught the unit's one defect before any person** — with
`FontAndParagraph`'s Color unwired the default paint is WHITE, and on the consent-off white ground
every text vanished; How high wires an `Ink` pad (0.1, 0.1, 0.1) for exactly this reason (now a
PATCH-GRAMMAR row). Ink wired, labels shortened, credit moved off the bottom edge; then the person
flipped both toggles and watched the ladder answer ("似乎正常" — behaves as described).

The lab's queue is now exactly one item: experiment 4, the Range reconnaissance.

## Experiment 4 — read only what you need (built and measured 2026-09-07)

**Contradiction:** a big remote file, of which a question needs a sliver.

**The first question answered itself at the desk:** `HTTPGet` has had a `Headers` pin all along —
`IEnumerable<string>`, one `"Name: Value"` string per header, implemented by
`Webrequest.AddHeaders` on .NET's `HttpWebRequest` — and .NET 8 (vvvv's runtime) no longer
restricts the `Range` header the way .NET Framework did. Nobody in this course had ever wired it.
Ground truth first, in PowerShell on the identical .NET path: S3 answered `206 PartialContent,
content-range: bytes 0-99/134302, 100 bytes received`.

**Prototype:** `lab\Experiment read only what you need.vl` + `lab\probe-pmtiles.py`. The target:
Stamen's watercolor world map as a public PMTiles archive (maplibre demotiles, CC BY 3.0),
**18,588,472 bytes, never downloaded whole**. The probe script reads the archive's 127-byte header
and 3 KB root directory over Range requests and prints one tile's byte address — the directory
parsing lives in the script ON PURPOSE: the patch's claim is *a remote file can be read by
address*, not *vvvv can parse varints*, and saying which half is whose is part of the honesty.
The patch sends exactly two ranged requests on one FETCH toggle:

| request | asks for | receives | status |
|---|---|---|---|
| the header | bytes 0–126 | **127 bytes** | 206 PartialContent |
| one tile | bytes 66,585–80,015 | **13,431 bytes = 0.07%** | 206 PartialContent |

— and **draws the tile** (a z4 watercolor JPEG of the Alps; the archive stores tiles uncompressed,
so `ImageDecoder` eats the ranged bytes directly). Verified by the person the same day ("似乎是对
的" — the numbers and the picture as described).

**One finding from the building:** PMTiles stores directory offsets **as offset+1** (zero meaning
"immediately after the previous tile"); decoding the first entry without the −1 fetched a JPEG
missing its leading `ff` — one wrong byte, found because the probe checks the magic. Recorded in
the script's header. Also: `ToString` on a `String` is ambiguous to vvvvc (`Collections.Sequence`
vs `Primitive.Object`) — `Split`'s `Status` is already a String; wire it straight to `Text`.

**Verdict:** the pipeline diagram's last box has evidence. All four now do — *where?* (exp 3),
*how detailed?* (exp 2), *how much?* (exp 1), *data access* (this) — which by the decision of
2026-09-06 makes Chapter 14 **proposable for the first time**: the diagram taught top to bottom,
with a shipped unit behind every box. Proposing it is a separate decision, not a consequence.

---

## Chapter 14 proposal — 2026-09-07 (the lab's second output; decision is the user's)

The 2026-09-06 decision set the bar: Chapter 14 becomes proposable when every box of the pipeline
diagram has evidence. As of experiment 4, every box does — *where?* shipped as an Explanation,
*how detailed?* shipped as an Explanation, *how much?* measured, *data access* measured and
person-verified. This is the proposal. **Nothing below is built until the ⊙ points are decided.**

### ⊙ Title

**`Tutorial 14 What if the world doesn't fit in memory`** — the same voice as Tutorial 12
(*What if space is not an object*), and the question the whole lab was opened on. The subtitle
carries the concept: *a remote file, read by address*.

### What the reader ends up with (the one new capability)

A patch that answers a spatial question about an **18.6 MB file it never downloads**: click a
place on a small world outline; the patch finds which watercolor tile covers that place, reads
that tile's BYTE ADDRESS out of a directory, sends one HTTP Range request, and draws the tile —
13,431 bytes, 0.07% of the archive, 206 PartialContent on screen. The chapter's single new
capability is the ranged read (`HTTPGet`'s Headers pin — shipped all along, taught for the first
time). Everything else is reuse, which is the point: the reader already owns every other step.

### The design that makes it a real chapter and not a demo

**The archive's directory ships as a GeoJSON asset** (`Assets\watercolor-directory.geojson`,
derived by extending `lab\probe-pmtiles.py`, derivation recorded like `cut-tiles.py`): one feature
per z4 tile — its bounding box as the geometry, its `offset` and `length` as attributes. Then the
question-to-address step is SPATIAL, and made of chapters the reader has passed:

    click (Tutorial 01)  →  Contains: which tile's bbox holds the point? (Tutorial 03)
    →  that feature's offset/length attributes (Tutorial 07 / Which door's TryGetValue)
    →  Concat a Range header  →  HTTPGet  →  ImageDecoder  →  the tile, drawn (How high)

A directory stops being an abstraction: it is a FeatureCollection you can open in a text editor,
draw as a grid (the first Explanation's picture, one storey up), and ask with `Contains`. The
honest edge is stated on the patch: real clients read this directory out of the archive's own
bytes (127-byte header → 3 KB root dir); ours was extracted by a recorded script because varint
parsing is bookkeeping, not the lesson — same numbers, auditable, reproducible.

**Packages:** VL.GeoJSON + VL.NetTopologySuite (+ CoreLib/Skia) — a genuine two-package spine
chapter, no exemption needed. **Consent:** one FETCH toggle, off; two requests per question.
**Numbers on the picture:** archive total, bytes asked, bytes received, status, percentage.

### Why a numbered chapter, and the cost said out loud

For: the lab's own bar is met, twice over — four experiments, two shipped units, every box
evidenced; the capability is exactly ONE (a ranged read); and the chapter closes the arc the
course has been walking since 09 — files arrive (09), asked in memory (11), partitioned on disk
(Explanation), laddered by sharpness (Explanation), and now **addressed over the wire**.

Against, honestly: **14 opens a second volume that would have one chapter.** The first volume
(01–13) stays frozen; 14 starts something. If a Volume 2 with one chapter reads as a broken
promise, the alternative shape is a third Explanation (*"You can read a file you never
download"*) — same patch, no number, no volume opened. The counter-argument: an Explanation
demonstrates a fact, and this unit hands the reader a CAPABILITY they compose themselves, which
is the definition of a Tutorial in this pack's own grammar.

### ⊙ Non-scope, stated now so the chapter cannot creep

No format parsing in the patch (no varints, no gzip, no new nodes anywhere); no PMTiles/COG/
GeoParquet reading beyond this one ranged fetch; no streaming or async machinery; no reprojection;
format names appear as one honest sentence each, as in both Explanations. The external dependency
is named as a risk in the chapter's own text: the archive is someone else's public file
(maplibre demotiles, CC BY 3.0); if it moves, the chapter breaks honestly and says where the
probe script points next.

### What it would touch

Design entry (this section) → extend probe-pmtiles.py to emit the directory GeoJSON →
THIRD-PARTY-NOTICES row (Stamen CC BY 3.0, directory as derived data) → generator → four rungs →
Help.xml (new spine entry — the first numbered chapter since the freeze; CURRICULUM.md gains the
Volume 2 note) → README (the spine table grows a row; the consent list grows one item).
Estimated: one session.

### Recommendation

**Build it as `Tutorial 14`.** The number is the honest claim here: this unit has prerequisites
(03, 07, 09, and both Explanations feed it) and hands over a capability — the two things the
pack's grammar says a number means. Volume 2 having one chapter is a true cost; the lab exists
to earn the next ones the same way.

### Chapter 14: decided 2026-09-07 — build it, with the user's design brief binding

The user chose **Tutorial 14**, on the argument that experiment 4 crossed from explanation to
capability: the learner can now DO something new — decide what is needed before reading, then
fetch only that. The brief that binds the build:

- **Exactly one capability:** *the question determines what gets read.* Flow: point somewhere →
  which piece answers? → locate it → request only those bytes → draw. Numbers are the main proof
  (remote file 18,588,472 B / this answer ~13 KB / read ~0.07%).
- **Vocabulary comes AFTER the experience** — no PMTiles/Range/cloud-native framing up front; the
  reveal names byte range, 206 Partial Content, and the format at the end.
- **The GeoJSON index's role stated honestly:** a simplified index for THIS lesson; real archives
  carry their own directory inside the file. If the simplification starts teaching a false model
  of PMTiles, stop and reconsider.
- **No new library surface**, no Range-specific node. **Zero requests on open.** **Failure states
  legible** (no piece found / request failed / not 206 / bad bytes — never silent empty success).
  Avoid exposing offset arithmetic prominently; the result that matters is the percentage.
- **Act IV opens with 14 as its only numbered chapter, and that is acceptable** — no Chapter 15
  invented for balance; future numbers must earn themselves.

Build notes fixed before generating: the index ships as `Assets\watercolor-directory.geojson` —
the archive's **z6 layer: a full 5×5 grid, 25 tiles, lon 0–28.1° lat 41.0–58.8°, 7,309–15,006 B
each** (chosen over z4's four tiles for a grid worth pointing at); drawn in plain lon/lat, so the
rows come out unequal on screen — chapter 10's lesson, visible again; the ask gesture is the
course's own (the cursor is the question, as in 01 and both Explanations); the matched piece's
ready-made `Range:` string and its share-of-archive live in the index as attributes, derived and
recorded by the probe script, so the patch does no offset arithmetic on screen.

## Unit proposal — 2026-09-06 (the lab's first output; **decided the same day: B + experiment 4**)

Two experiments confirmed the same mental-model shift, which is the lab's own threshold for
proposing units. This section is the proposal. **Nothing below is built until the ⊙ points are
decided.**

### The evidence, in one paragraph

The ledger (exp 1) showed that weeks of map use cost 73 MB of a 366-billion-tile world; the ladder
(exp 2) showed the same summit at six sharpnesses, each one fetch away, truth arriving by degrees;
the layouts (exp 3) showed the same 754 features answering the same question for 26x fewer bytes
when the disk arrangement matched the question. One sentence covers all three: **how much you read,
and how sharp, is part of the query — and the dataset's organisation decides what a small question
costs.** That is the entire conceptual payload of cloud-native GIS, reached without naming a
single format.

### The model, as the user drew it — 2026-09-06

Shown the proposal, the user answered first not with a choice but with a diagram:

```
question
   |
where?  how much?  how detailed?
   |
decides what to read
   |
data access
   |
answer
```

This is sharper than the lab's own sentence, and sharper in the place that matters: it states the
shift as an INVERSION OF ORDER. The pipeline every earlier chapter (and every desktop GIS) lives
in is `data access -> question -> answer` — load the whole file, then ask. The diagram moves the
question in front of the read, and inserts a stage the old pipeline does not have: *deciding what
to read*. The three interrogatives are exactly the three experiments:

| interrogative | experiment | what it proved |
|---|---|---|
| **where?** | exp 3, two layouts | partition by location -> read one cell, 26x less |
| **how detailed?** | exp 2, resolution ladder | the pyramid -> read one sharpness, truth by degrees |
| **how much?** | exp 1, the ledger | the measured consequence: 0.0000004% was ever needed |
| *(data access)* | **exp 4 — not yet run** | the only box in the diagram with no evidence behind it |

Two consequences for the options below. It gives each Explanation in option B its exact assertion
(one interrogative each). And it makes Chapter 14 concrete for the first time — the chapter, when
earned, is this diagram, taught top to bottom — while showing precisely why it is not earned yet:
its `data access` box is empty until experiment 4 runs against something genuinely remote.

### ⊙ The shape: three options

**A. Chapter 14 now** — a conceptual spine chapter (*"What if the world doesn't fit in memory?"*)
whose interactive heart is the layouts experiment, opened by the ledger's numbers, with the ladder
as its second half. Honest cost: it carries two capabilities (partition + pyramid), breaking the
one-capability rule that shaped 01–13; it opens a Volume 2 whose other chapters do not exist; and
the lab has run for one day. The phase brief allows proposing it, and also says a chapter must be
EARNED — three prototypes in one day is the minimum imaginable earning.

**B. Two Explanations now, the chapter stays unearned** *(recommended)* — the pack already has the
precedent: `The map is not to scale` is the split-off half of chapter 10, an assertion proved on
screen, unordered, skippable. Both experiments are exactly that shape — demonstrations, not
capabilities, not permissions:

| unit | from | the assertion it proves | packages |
|---|---|---|---|
| `Explanation You do not have to read everything` | exp 3 (+ exp 1's ledger as its opening numbers) | same data, same question, same answer — 26x less read, because the LAYOUT matched the question | GeoJSON + NTS (already true of the prototype) |
| `Explanation Sharper is a different question` | exp 2 | the same place answers at every sharpness; each level is one fetch; truth arrives by degrees and is priced in tiles, not bytes | Mapsui + NTS — the shipped form is cursor-driven on a real map (any summit, not just Fuji), which the prototype's fixed-place form is not; the fixed form has NO legitimate home (zero family packages, and Explanations get no single-package exemption) |
| *(the ledger)* | exp 1 | folded into the first Explanation's text as measured numbers — no patch of its own yet | — |

Chapter 14 then waits for what it actually lacks: the ANSWERS half (a real remote read — exp 4's
Range reconnaissance, a real cloud format touched once), and a second volume with more than one
chapter in it.

**C. Wait entirely** — keep both as lab prototypes, run exp 4 first. Costs nothing, but the two
confirmed lessons stay invisible to every learner, and the lab exists to feed the course.

### What B would touch (if decided)

Both units go through the full pipeline: design entry here → generator → four rungs → Help.xml
(`Explanations` topic — which stops being a one-entry topic) → README (the Explanation line
becomes a table of two) → THIRD-PARTY-NOTICES (the tiles folder becomes a help asset with its
derivation script recorded; Terrarium attribution as in How high). The layouts Explanation
inherits the prototype's machinery plus: the grid drawn fully, the selected cell's features drawn,
the ledger paragraph, PLAY (delete a tile file and point at its cell; recut with a different N),
GIS WORDS (partition, tiling scheme, hot/cold read, the centroid-contract lesson), and exits to
11, 09 and the ladder. The ladder Explanation is a rebuild on the How-high chassis (cursor →
lon/lat → six tile fetches), not a copy of the fixed-place prototype.

### ⊙ Non-scope, stated now so the units cannot creep

No PMTiles/COG/GeoParquet reading, no Range requests, no new nodes, no async/streaming machinery,
no "cloud" in any title. The word *pyramid* may appear; the word *mipmap* belongs in CREATIVE
CONNECTION; format names belong in a single honest sentence each ("this idea is why X exists"),
nowhere else.

### Decision — 2026-09-06

**Built 2026-09-06, the same evening** — `help\Explanation You do not have to read everything.vl`,
rungs 1–3 green on the first generated try (one content try; two filename tries — see the title
note below). Over the prototype it adds the full 8×8 grid (16 strip rectangles whose edges
coincide), the small file's features as teal centroid dots (`Split → Centroid → Bounds` per
feature — `Bounds` on a Point is its X/Y, no coordinate lists needed), readouts and the ODbL
credit drawn on the picture. Rung 4's camera: cursor at the renderer's centre landed in cell 3,4 —
screen said ONE FILE 306,984 read / 754 parsed / 6 in cell, MANY FILES 2,447 / 6 / 6, file
`tile_3_4.geojson`; every number matches the disk (that cell's gap is 125×, wider than the runway
cell's 26×). The dots sat inside the orange cell. The human half of rung 4 — a person moving the
mouse, watching the file change, trying PLAY — is still owed.

**Rung 4's person found the first defect (2026-09-06):** moving the mouse made the tile FileReader
flash purple - half the 64 cells have no file, and the patch was using the reader's EXCEPTION as
its absence signal. Absence is the lesson, so it must be data, not an error: `Exists [IO.Path]`
now gates the Read (`Changed AND Exists`) and a `Switch (Boolean)` feeds the parser '' when there
is nothing to read - same zeros on screen, no exception as control flow. One compile fault on the
way: **`AND`'s output pin is `Output`, not `Result`** (OR's is Result; the compiler names the
missing pin). Re-verified through rungs 1-3, then **rung 4's human half passed the
same evening**: the person moved the mouse across the grid - filename following the cell, the two
in-cell numbers equal, empty cells reading 0, and the reader quiet throughout ("seems much
better"). All four rungs discharged.

*(Title amended during the build: the proposed `You don't have to read everything` was the pack's
first filename with an apostrophe, and vvvvc CRASHES on it — unhandled exception 0xE0434352 in
`ProjectBuilder.BuildAsync`, no diagnostic; the identical content compiled green under a
no-apostrophe probe name. So: `You do not have to read everything`, which also matches the pack's
existing title voice — `Close does not mean reachable`. Recorded in PATCH-GRAMMAR.)*

**B, then experiment 4** — chosen by the user after drawing the pipeline diagram above. The two
Explanations each prove one interrogative of that diagram; experiment 4 then goes after the one
box with no evidence (`data access`, remote). Chapter 14 is neither promised nor scheduled: it
becomes proposable only when all four boxes have evidence, and it would be the diagram taught top
to bottom. Build order: `You don't have to read everything` first (machinery 90% proven in the
prototype), `Sharper is a different question` second (needs the cursor-driven rebuild), then the
Range reconnaissance. The non-scope list above binds both units.

### Recommendation

**B**, ladder second: build `You don't have to read everything` first (its machinery is 90%
proven in the prototype), then `Sharper is a different question` (needs the cursor-driven
rebuild). Two sessions. Chapter 14 remains a question the lab has not finished asking.

## Ledger of lab findings that already changed the course

- Experiment 2's finding 3 (bytes fall with zoom) is worth a sentence in `Prompt How high is here`
  the next time that patch is touched — not worth its own edit round.
