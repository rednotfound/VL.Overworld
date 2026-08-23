# Act III — designs for chapters 10–13, and the boundaries they stop at

Written 2026-08-23. **These are designs, not implementations.** Every capability the four chapters
need is classified below; two of them sit on package boundaries, and per the working brief those
stop at a proposal and wait for review. Nothing here adds a dependency, wraps an API, or creates a
package.

The door tests, the canvas grammar and the honesty clauses of chapters 01–09 apply unchanged
(CURRICULUM.md, PATCH-GRAMMAR.md). The standing theme continues: **data has contracts** — each
chapter below adds one line to that ledger.

| chapter | contract line |
|---|---|
| 10 | a coordinate is not a location until you know its system |
| 11 | a candidate is not a result |
| 12 | a pixel value means nothing without its metadata |
| 13 | proximity is not connectivity |

---

## Capability inventory (Step 2)

| chapter needs | classification | where it stands |
|---|---|---|
| 10: show one place as two number pairs | **Already available** | `ScreenToWorld` gives WGS84; WebMercator forward formula is six math nodes in the patch — a projection IS arithmetic, and computing it on the canvas is the lesson, not a workaround |
| 10: distance in degrees | **Already available** | `NTS.Operation Distance` (exists, tested) |
| 10: honest metric distance | **Already available** | haversine great-circle = plain trig, patch math nodes |
| 10: arbitrary CRS / EPSG / UTM | **Possibly requires new library** | nothing in the family reprojects (gap rank 2). **Library Scope Proposal: VL.Proj, below — recommendation: DELAY**, chapter 10 v1 does not need it |
| 11: 100,000 points | **Already available** | random spread, built once (`ParticipatingElements` idiom); NTS points via ForEach, cached |
| 11: brute-force Contains per frame | **Already available** | `Contains` in a ForEach — being honestly slow is half the chapter |
| 11: spatial index | **Available but awkward → missing small abstraction** | `NetTopologySuite.Index.Strtree.STRtree<T>` exists IN the NTS library, unwrapped. Category A: vl-nettopologysuite's ROADMAP already lists it under "Later" with the `[ProcessNode]` caveat, and names this very demo as its acceptance test. Belongs there; needs review before wrapping |
| 12: a field, a grid, a sampled value | **Already available** | `SimplexNoise` ships in VL.CoreLib; grid = spread arithmetic; rendering = Skia. Zero geospatial dependencies, fully offline |
| 12: real DEM / GeoTIFF **file** | **Missing major capability** | still true, and still out of scope for chapter 12 ON PURPOSE — the field concept teaches without a file. A GeoTIFF reader would be its own scope proposal |
| real DEM values as **raster tiles** | ~~Missing~~ → **Already available. Corrected 2026-08-23** | see "The correction" below: `HTTPGet`'s Body is already `Spread<Byte>`, `ImageDecoder` turns those bytes into an image, and `Pipet [Graphics.Skia.Imaging]` reads a pixel out of it. Zero new library capability. The row above was written thinking of files and wrongly closed the door on tiles |
| 13: hand-typed street network | **Already available** | LineStrings from WKT, chapter-07 style |
| 13: shortest path over it | **Missing major capability** | NTS has `PlanarGraph` (used internally by Polygonizer) but **no shortest-path algorithm anywhere in the family**. Category C boundary — options and mini-proposal below; stops for review |

Prompt-frontier readiness, same scale:

| prompt candidate | classification |
|---|---|
| Voronoi — who owns this space | Category A: `VoronoiDiagramBuilder` in NTS lib, unwrapped; ROADMAP already answers "output is geometry, so probably here" |
| Ask the same polygon 100,000 times | Category A: `PreparedGeometryFactory` in NTS lib; ROADMAP already carries the `[ProcessNode]` warning |
| Earth never stops moving (time windows) | Already available: `time` attribute + patch filtering over the existing earthquake feed |
| The file disappears (bbox queries) | Mostly available: `HTTPGet` + a URL built from the viewport (`VisibleRange` exists in VL.Mapsui); needs a server worth querying |
| GPS painting | Needs a GPS/GPX source — unclassified until a source is chosen |
| Sun and shadow | Category C/D: solar-position mathematics is a new domain. Delay |
| **Walk across a mountain** (real elevation under the cursor) | **Already available** — promoted out of "future" 2026-08-23. Designed below; must come AFTER chapter 10, whose tile/projection arithmetic it consumes |

---

## Chapter 10 — Same Place, Different Numbers

**First screen.** A map centred on Tokyo (tiles off as always; a marker drawn either way). Two
readout stacks, both labelled **Tokyo**: `139.767, 35.681` and `15,558,809, 4,257,062`. One marker.
The narrative's first line: *both of these are Tokyo, and neither is wrong.*

**Primary interaction: the mouse.** Hover anywhere and BOTH number pairs follow the cursor live —
the first from `ScreenToWorld`, the second computed **on the canvas, with math nodes you can read**:

```
x = R · lon°·π/180                 y = R · ln(tan(π/4 + lat°·π/360))       R = 6378137
```

That the patch-computed pair matches what the map engine uses internally is the proof that a
projection is arithmetic, not magic.

**The honest failure, in three numbers.** Tokyo and Osaka as NTS points, three distances side by
side, fontsize 14:

| | number | label it carries |
|---|---|---|
| raw lon/lat through `Distance` | ≈ 3.87 | **degrees — which is not a distance** |
| mercator-projected points through `Distance` | ≈ 490 km | **web-mercator metres — stretched ×1.22 at this latitude (1/cos 35°)** |
| haversine, patch trig | ≈ 397 km | great-circle metres |

Every algorithm computed correctly; two of the three answers are still wrong as *distances*. Even
"metres" lies until you know which metres. This is the chapter's whole argument, made of numbers
already on screen.

**Discovery before terminology**: the learner meets the contradiction (one place, two spellings)
and the three-distances table before any word is defined. **GIS WORDS** then: coordinate system,
geographic vs projected, projection, WGS84 / EPSG:4326, Web Mercator / EPSG:3857, transformation.
**Creative bridge**: local → world → view → screen is a pipeline every creative coder already owns;
GIS has the same pipeline, but the spaces describe the Earth — and chapter 08 already walked the
outer two layers of it. **Honesty clause**: this patch can cross exactly one pair of systems; the
real projection zoo (UTM, national grids, five-projections-of-one-country) needs an engine the
family does not have — the recorded gap rank 2, and the proposal below. **Instrumentation**: the
patch-computed mercator pair vs the engine's own (they must agree to the metre — a live integration
test of `SphericalMercator`'s arithmetic against first principles).

**Dependencies: VL.Mapsui + VL.NetTopologySuite. Nothing missing. Buildable today.**

### Built 2026-08-23 — and the design above was wrong about the subject

The chapter above got built, looked at by a person, and rejected — three times — before the actual
subject surfaced. The record matters more than the result, because the failure was a thinking
failure, not a patch failure.

**What was wrong.** The design put a *proof* on screen, not a *phenomenon*: a live cursor, ten
readouts, and an instrument (patch-mercator ≈ 1/cos φ, agreeing to four digits) that is evidence
for the author and nothing at all for the reader. Every Act I chapter that worked has one cause
you control and one thing in the picture that changes; this had a still picture and ten numbers
moving at once. Two intermediate rebuilds — a ground-distance cross, then that cross plus a
cursor-following Skia readout — each fixed a symptom the reader had named, and each left the
subject alone.

**The premise that had to break.** Every version assumed *we only have one projection, because the
family has no reprojection engine*. That is false, and the falseness is the chapter:

> A reprojection engine solves **arbitrary CRS by EPSG code**. A **forward** cylindrical
> projection is a line of arithmetic. Three of them differ only in what they do to a latitude:
>
> ```
> x = R · λ            ← all three identical
> y = R · φ                             equirectangular / plate carrée
> y = R · ln(tan(π/4 + φ/2))            Web Mercator
> y = R · sin(φ)                        Lambert cylindrical equal-area
> ```
>
> The third one is a single `Sin` node. "We need a library" was never true for this.

**What chapter 10 actually is now.** No map — a basemap can only draw ONE projection, and the
chapter is about there being more than one. On screen: 17 parallels and the world's coastlines.
One knob, `PROJECTION`, 0/1/2. Turn it and the world changes shape while every number in the file
stays put. Greenland is Africa-sized on 1 and shrinks to its real self on 2.

Setting 0 carries the sharpest line: **plate carrée is what you get by accident.** Feeding lon and
lat straight into a drawing — which Act I does for five chapters — is already a projection, with
real distortion, chosen without knowing a choice was being made.

**Data: Natural Earth 1:110m coastline** (134 LineStrings, 5128 coordinates, 140 KB, public domain,
recorded in THIRD-PARTY-NOTICES.md). The read path has no nested loops because
`GeometryCollection` flattens: features → `ForEach {Split}` → `GeometryCollection` → `Coordinates`
→ one flat spread → `ForEach {project, Circle}`. Drawing dots rather than polylines follows from
that flattening — joining the last vertex of one island to the first of the next would draw a line
across the Atlantic.

### Why the OSM basemap cannot come, and what that is worth teaching

Asked directly whether tiles could be combined with this. The answer is no, twice over, and both
halves are content:

- **A raster tile is already projected.** The XYZ scheme is *defined on* the Web Mercator square;
  there is no such thing as an equal-area OSM tile. Making one means resampling every pixel, which
  is what a WMS server or GDAL does offline. (WMTS permits other TileMatrixSets and EPSG:4326 tile
  sets exist — but the tiles anyone can reach for free are Mercator.)
- **Even "show the basemap in mode 1 only" is blocked**, by a gap already on record: the Mapsui
  layer draws in its own pixel space, `PixelSpace.Draw` resets the matrix, and it cannot be brought
  into the renderer space the graticule lives in (CLAUDE.md, known gaps). The only way to align is
  to hand the geometry to the map and let it project — which is the one projection again.

**The line that answers it properly, and which is now in the chapter:** *vectors reproject, rasters
do not — at least not for free.* Reprojecting a point is a line of arithmetic; reprojecting a
picture is moving every pixel and re-guessing the colours in between. That is why your basemap has
exactly one projection and your data can have as many as you like.

### The cross gets its own unit: `Explanation The map is not to scale`

Decided 2026-08-23 with the user, on the observation that the two patches teach different things
and that **nothing later in the course covers the second one** (11 is spatial indexing, 12 raster,
13 networks, and VL.Proj is delayed):

| | Tutorial 10 | the cross |
|---|---|---|
| question | why are there different maps? | how wrong is THIS map, HERE? |
| scale | global, three projections compared | local, one projection, at the cursor |
| distortion is | a property of the map | a number that moves as you move |
| basemap | impossible | **possible, and this is where it belongs** |

`Explanation` rather than `HowTo`: the patch proves a fact rather than handing over a recipe, and
the title is the assertion it proves. It also closes a loop chapter 08 left open — *"your circle is
really a slightly tall ellipse … nothing in this family reprojects yet"* — which no unit has picked
up since.

Shape, from the version that was built and then overwritten: an OSM basemap, a cross that follows
the cursor and is **200 km on the ground each way**, and a momentary switch (hold the right mouse
button) that redefines it as **2 degrees each way**. Held: the arms are visibly unequal on screen.
Released: they are equal on screen and unequal in degrees. Plus `STRETCH = 1 / cos(latitude)`, which
is the same number as the cross growing.

**The file is gone and it is my fault**: the cross version was overwritten by a full-template
rewrite before it was ever committed. Rebuilding it is cheap — the design is above and both later
fixes are known (Skia `Text` `Size` is a Vector2, `0, 0.055`; the tiles toggle belongs in the first
paragraph) — but the rule earned is: **stash a working uncommitted patch before replacing it.**

---

## Chapter 11 — Do You Really Want to Ask 100,000 Points One by One?

**First screen.** 100,000 points as a starfield — **no map, Act-I style, renderer scene space**:
offline, instant, and free of the risk that Mapsui chokes on a 100k-feature layer (that risk is
real and unmeasured; keeping the chapter map-free sidesteps it and keeps the lesson pure). A query
rectangle follows the mouse. Points inside it light up teal.

**Primary interaction: the mouse** (the rectangle). One subordinate discovery knob: rectangle size.

**The visualization that matters** — work, not milliseconds:

```
Brute force        Tested   100,000     Accepted   427
Indexed            Candidates   612     Accepted   427
```

Both pipelines run live, side by side, every frame. The Accepted numbers are equal BY
CONSTRUCTION and the patch says so: **the index never answers the spatial question — it narrows
who gets asked.** Candidates ≠ results is the contract line, visible as 612 ≠ 427 (the envelope
overshoots; the exact `Contains` finishes the job). A frame-time readout may sit beneath as a
by-product, clearly subordinate.

**Discovery before terminology**: the two counters. **GIS WORDS** after: envelope, bounding box,
spatial index, R-tree, STRtree, candidate filter, exact predicate. **Creative bridge**: BVH,
octree, KD-tree, broad-phase collision — the learner has met this idea wearing other clothes.
**Honesty**: the brute-force half is genuinely evaluated (its cost is honest, not simulated), and
the counters are the instrument. **Instrumentation**: Tested / Candidates / Accepted ×2 + "Index
Built: 1" (the index is a resource with identity — rebuild-per-frame is the family's oldest
mistake, and the counter would expose it).

**Dependencies: VL.NetTopologySuite (+ VL.Skia). One capability missing — Category A:**

> **STRtree wrap in VL.NetTopologySuite.** Underlying API: `NetTopologySuite.Index.Strtree.STRtree<T>`
> (also `Quadtree`; STRtree first). VL-facing shape: a `[ProcessNode]` (`SpatialIndex`? name at
> review) — geometries in, built ONCE, rebuilt only when the set changes (ROADMAP's own caveat);
> `Query (Envelope)` returning candidates + a `Candidates` count; `Indexes Built` readout pin.
> Why the patch needs it: the entire right-hand pipeline. Belongs in VL.NetTopologySuite: its
> ROADMAP already claims it and names this chapter as the acceptance test. **Not implemented —
> awaiting review.**

The optional prompt **Ask the Same Polygon 100,000 Times** (`PreparedGeometry`, same package, same
`[ProcessNode]` reasoning) stays a prompt unless review says otherwise.

---

## Chapter 12 — What If Space Is Not an Object?

**First screen.** A landscape of grey — `SimplexNoise` evaluated over the canvas, rendered as a
grid of Skia rects. The cursor glides over it; a fontsize-14 readout shows `X  Y  Value`. First
narrative line: *every place here has a value — there are no objects on this screen at all.*

**Primary interaction: the mouse** reads the field. **The one knob: Resolution.** Drag it from 200
down to 8 and watch the same field pixelate — the value under the cursor starts snapping to cell
centres. Drag it up and the field seems continuous again. **Sampling is where a field becomes a
raster**, and the knob IS that sentence.

**Dataflow**: noise function → (grid of samples at Resolution) → Skia rects; cursor → sample at
cursor (nearest cell, and the narrative names the choice: nearest vs bilinear is a real decision
raster people make). Everything offline, everything VL-native — no geospatial package appears at
all, and VL.NetTopologySuite is declared only so the spine exemption paragraph can explain why a
map course suddenly has no map (or: one NTS node marks a point-object ON the field to sharpen the
object-vs-field contrast — decide at build time).

**Discovery before terminology**: field, then sampling, then the word. **GIS WORDS**: raster, cell,
resolution, nodata, DEM, and georeferencing as the four-part contract — `grid + origin + pixel size
+ CRS` — *a raster is a field that signed a contract about where it is.* **Creative bridge**:
texture, height map, scalar field, simulation grid — the learner has been doing raster GIS in
shaders for years without the vocabulary. **Honesty**: this field was born digital; nothing in the
family can read a GeoTIFF or a DEM, and the pixel-value contract line (value ≠ meaning without
metadata) is exactly why casually bolting on a reader would be wrong. **Instrumentation**: sample
count = Resolution², shown; a cell-size readout in canvas units.

**Dependencies: VL.CoreLib + VL.Skia (+ VL.NetTopologySuite, see above). Nothing missing.
Buildable today.** Real raster IO is deliberately NOT this chapter and gets proposed only when the
Walk-Across-a-Mountain prompt is genuinely wanted.

### Built 2026-08-23 — what the patch actually does, and the one deviation

All four rungs passed the same day. The build took the parenthetical option above:
**VL.NetTopologySuite earns its place** with `Coordinate` → `Point` → `Write WKT` on the cursor, so
the only object on screen sits on a field made of nothing but values. The validator would have
failed a chapter declaring no family package at all, but that is not why the nodes are there.

Two facts the build paid for, both cheap only because rung 2 is loud:

- **`Vector (Join)` does not exist for `Int2`.** The node is `Int2 (Create) [Primitive.Int2]`
  (pins X, Y, Output). `2D.Int2` is not a category. Costs one compile to find, so it is written
  down here.
- The grid is `GridSpread (2D) [Collections.Spread]` (Center, Width `1.8, 1.8`, **Alignment
  `Block`**, Phase, Count) → one `ForEach` → `SimplexNoise` → `MapClamp` → `RGBA (Join)` → `Fill`
  → `Rectangle` → `Group (Spectral)`. Reading the generated C# confirms the loop compiles to a
  native `foreach` and that `Fill`/`Rectangle` keep **per-slice state**, so a 64×64 grid is 4096
  persistent process nodes rather than 4096 allocations a frame.
- **`Block` is not a detail — it is the raster.** The first rung-4 run showed hairline seams
  between every pair of cells, because `Alignment` defaults to `Centered`, which puts the first and
  last samples ON the edges (spacing `Width/(Count-1)`) while the cells were sized `Width/Count`.
  `Block` cuts the width into Count equal blocks and samples each block's centre — spacing
  `Width/Count` exactly, which is what a raster cell IS. Seams gone on the second run, grid still
  centred. Both a rendering fix and the conceptually correct one, and no automated rung could have
  raised it: the patch compiled, the counters were right, and only the picture was wrong.

**Deviation from the design above: the snapped cursor readout and the cell highlight are not in
v1.** The design called for the value under the cursor to step to cell centres. Doing that honestly
needs `p → /cell → floor → *cell → +cell/2` in Vector2 arithmetic — five nodes whose names in
`2D.Vector2` (`Floor (Float)` among them) are unverified, on a first draft that already had one
unknown in it. The lesson survives without them: at Resolution 8 the **Field Here** number slides
continuously while the block underneath it stays one flat grey, and that gap IS the sampling loss.
The snap is now cheap to add and worth adding: rung 4 confirmed the grid tiles, and with `Block`
the arithmetic is exactly `snapped = (floor(p / cell) + 0.5) * cell`. The orange highlight would
then double as the instrument proving that arithmetic and `GridSpread`'s layout agree.

---

## The correction — real raster arrives as TILES, and the family can already read them

Written 2026-08-23, immediately after chapter 12 passed rung 4, prompted by the right question:
*having explained the idea, shouldn't we now look at some real data — raster tiles?*

**The capability inventory above was wrong, and wrong in a specific way: it reasoned about raster
IO as a FILE problem.** Read as files, "nothing in this family can open a GeoTIFF" is still true.
But a DEM does not have to arrive as a file. It arrives every day as ordinary XYZ PNG tiles, and
every piece of that path already ships:

| step | node | note |
|---|---|---|
| fetch the tile | `HTTPGet` | its `Body` is **`Spread<Byte>`**, not a string — the raw PNG is already in hand. `Prompt Live earthquakes` proved the fetch-only-on-Refresh discipline |
| bytes → image | `ImageDecoder [Graphics.Skia.Imaging]` | wraps `SKImage.FromEncodedData`; takes a `Byte[]`, so one `ToArray` sits in between |
| read a pixel | **`Pipet [Graphics.Skia.Imaging]`** (and `Pipet (Spread)`) | internally `SKBitmap.GetPixel` → `SKColor`. This is the node the inventory did not know about |

**No new library, no new node, no scope proposal.** The door the inventory closed was never shut.

### The data: Terrarium tiles

`https://s3.amazonaws.com/elevation-tiles-prod/terrarium/{z}/{x}/{y}.png` — AWS Open Data,
**no token and no signup**, which is what makes it usable in a chapter at all. (Mapbox Terrain-RGB
encodes the same idea with a different offset and is disqualified by its API key: a chapter that
cannot run on a fresh install is not a chapter.)

Elevation is a 24-bit fixed-point number split across the channels:

```
elevation_metres = (R * 256 + G + B / 256) - 32768
```

R is the 256s place, G the ones, B the 1/256 fraction. Range −11000 … 8900 m. Tiles are
256×256 in EPSG:3857 — the same Web Mercator chapter 10 computes by hand.

**Licence and attribution.** The tiles are a mosaic of national open datasets — USGS 3DEP / SRTM /
GMTED2010, Copernicus EU-DEM, Geoscience Australia, LINZ, Kartverket, INEGI, ArcticDEM and more —
under a mix of CC-BY, public domain and open government licences. Attribution is required, and
tilezen's own `attribution.md` **does not distinguish display from analysis**: reading a value out
counts. That row goes in `THIRD-PARTY-NOTICES.md` and the credit goes on the patch, which is
exactly the lesson chapter 09 already teaches.

### Why this is the right follow-up, and where it goes

Chapter 12 SAYS *a value means nothing without its metadata*. A terrarium tile MAKES that true:
opened on its own the PNG is meaningless pink-green noise, and becomes terrain only once you know
the decode formula, where the tile sits in EPSG:3857, and that a pixel is an area. The four-part
contract stops being a line of narrative and becomes something the reader performs.

It also has a hard prerequisite. lon/lat → tile z/x/y → pixel-within-tile IS chapter 10's
WebMercator arithmetic with two more steps on the end. **So: after 10, not before.** Filed as
`Prompt Walk across a mountain` (name provisional) rather than a spine chapter, because it adds no
new capability to the sequence — it spends chapters 10 and 12 together.

### Precedent — this is the industry's normal move, not our invention

deck.gl's `TerrainLayer` decodes terrarium with exactly these constants
(`rScaler 256, gScaler 1, bScaler 1/256, offset −32768`); MapLibre's `raster-dem` source takes
`encoding: "terrarium" | "mapbox"`; reading terrain-RGB as an ordinary texture is routine in
three.js work. `watergis/terrain-rgb` is a small library doing precisely our task — elevation from
a terrain-RGB/terrarium tileset by longitude and latitude — and is the closest reference
implementation. `reearth/reearth-terrain` (terrain.reearth.land) is an open terrain-tile service in
the same shape; AWS Terrarium is the chosen source for now.

### Not yet verified — these are rung 2/3/4 questions, not facts

- **`Pipet`'s `Position` semantics**: normalised 0–1 or pixel coordinates, and how it clamps at the
  edges. Not read; the node's internals were only grepped far enough to prove `GetPixel` is there.
- **`Spread<Byte>` → `Byte[]`**: needs a `ToArray`; untried.
- **The endpoint**: no request has been made from here. Live-ness is assumed, not measured.
- **Politeness**: one tile per click, never per frame. `HTTPGet` fires only on its Refresh pin —
  the discipline exists and must be kept.
- **Where a cached tile lands.** `Test-VLPackage.ps1`'s rule 10 fails the pack if any file shaped
  `\<z>\<x>\<y>.png` appears anywhere in the repository — a tile cache wrote into a sibling repo
  once already (vl-mapsui NOTES.md, 2026-08-14). A URL template in a string is fine and trips
  nothing; a cache folder inside the repo is not. Keep any cache out of the working tree, as
  chapter 06 already does.

### Knock-on: chapter 12's honesty clause is now slightly misleading

It reads *nothing in this family can read a GeoTIFF or a DEM yet*. The GeoTIFF half is still true;
the DEM half is not, now that a DEM delivered as tiles is readable. Amended in the patch to say so
and to point forward — an honesty clause that has quietly gone stale is worse than none, because
the reader has no way to tell.

---

## Chapter 13 — Close Does Not Mean Reachable

**First screen.** A small hand-typed street network (chapter-07 discipline: real coordinates,
typed, checkable) on either side of a river. Two markers 80 metres apart. Two lines: the straight
one (grey, dashed feel — chapter 04's `Nearest Points`, literally) crossing the water, and the real
path (teal, thick) running 480 metres to the bridge and back. Two fontsize-14 readouts:
`Straight: 80 m` / `Along the streets: 480 m`.

**Primary interaction**: click (or drag) the destination among a handful of marked places; both
lines and both numbers follow. One pre-authored discovery: a **Bridge Closed** toggle removes one
edge — the path number jumps, the straight number does not move at all, which is the entire lesson
in one click.

**Discovery before terminology**: the two numbers refusing to agree. **GIS WORDS**: node, edge,
graph, connectivity, network distance, shortest path — and the conceptual ladder the earlier
chapters climbed: where is it → how far → is it inside → **how is it connected**. **Creative
bridge**: pathfinding, game navigation, agents, node networks — A* is the one algorithm every
creative coder has met. **Honesty**: the network is ten streets typed by hand; real road networks
arrive as data (OSM) and bring a dozen contracts of their own — recorded as future, not promised.
**Contract line**: geometric proximity ≠ connectivity. **Instrumentation**: node/edge counts,
`Paths Computed` (should move on interaction, never per frame), unreachable → the path readout says
"no path — and that IS an answer", never an empty screen.

**Dependencies: blocked on one missing capability — Category C, stops here.**

> **Shortest path exists nowhere in the family.** NTS ships `PlanarGraph` (its Polygonizer's
> internal skeleton) but no routing algorithm; the course repo can hold no C#; and a
> patch-authored Dijkstra in dataflow is a feedback-loop exercise that would bury the chapter's
> lesson under its own implementation. Three options, in the order considered:
>
> 1. **Extend VL.NetTopologySuite with a minimal network surface** (working name `NTS.Network`):
>    `Network` — a `[ProcessNode]` built from LineStrings (nodes at shared endpoints, weight =
>    length, built once); `ShortestPath (Network, Point, Point)` returning a LineString + length +
>    found/not. Geometry in, geometry out, no new public types beyond the `Network` handle; Dijkstra
>    over ~dozens of nodes is ~80 lines with no dependency. *For*: the input and output are
>    geometry, which is that package's one-sentence identity; NTS itself already holds a planar
>    graph. *Against*: "routing" is a domain with a long tail (turn costs, directions, OSM), and a
>    package's first routing node is a promise someone will ask it to keep.
> 2. **A new geometry-agnostic VL.Graph package.** Clean in theory; but its one-sentence scope is
>    hard to state, its non-scope list is enormous, and one ten-node lesson is not evidence that
>    general graph infrastructure is wanted. Fragmentation risk outweighs it today.
> 3. **Delay chapter 13** until 10–12 have shipped and the network question returns with more
>    evidence.
>
> **Recommendation: option 1, scoped exactly to the two nodes above, with the long tail named as
> explicit non-scope in the package's ROADMAP ("no turn costs, no directions, no OSM import, no
> A* until a chapter needs it"). Awaiting review — nothing implemented.**

---

## Library Scope Proposal — VL.Proj (recommendation: DELAY)

Filed because chapter 10 walks up to the boundary; filed WITH a delay recommendation because
chapter 10 as designed does not cross it.

- **Proposed name**: `VL.Proj` (proposal only).
- **Problem it solves**: the curriculum will eventually put one country into five projections and
  watch Greenland eat Africa (GST 101 Lab 3, 30DMC day 19 — a prompt in every year), and let a
  learner buffer in honest metres via a local projected CRS. That needs arbitrary CRS→CRS
  transformation, which nothing in the family can do: `SphericalMercator` is one hard-wired pair.
- **Why existing packages are insufficient**: VL.NetTopologySuite deliberately knows nothing about
  the Earth (a `Geometry` has no CRS); VL.Mapsui draws maps and its projection use is an internal
  detail of drawing; VL.GeoJSON is IO for a format that mandates WGS84. A CRS engine inside any of
  them would break that package's one-sentence identity.
- **Proposed scope**: CRS representation; WKT CRS parsing; a small set of well-known CRS (WGS84,
  WebMercator, UTM-by-zone); coordinate transformation; NTS-geometry transformation (copy, never
  mutate — the family rule).
- **Explicit non-scope**: map rendering, GeoJSON, spatial predicates, raster IO, datum-grid files,
  full EPSG database hosting, vertical CRS.
- **Primary users**: the curriculum first; any VL patch measuring in metres second.
- **Core types**: ProjNet's `CoordinateSystem` forwarded (as vvvv-gis did), NTS `Geometry` shared —
  no new wrapper types.
- **Dependencies**: `ProjNet` 2.x — pure managed .NET, no natives, small; MIT-family licence
  (verify at review). Known limitation: ProjNet carries no full EPSG database — CRS arrive as WKT
  or well-known constructors, and "EPSG lookup" beyond a curated handful is out of scope v1.
- **Minimum useful surface**: `Wgs84`, `WebMercator`, `Utm(zone, north)`, `ParseWkt`,
  `CoordinateSystemInfo`, `Transform (Coordinate)`, `Transform (Geometry)`. **This exact surface
  already exists as measured salvage in retired vvvv-gis (`VL.GIS.Core/ProjectionNodes.cs`,
  ProjNet 2.1.0)** — the proposal is largely a resurrection, not an invention.
- **Future expansion**: five-projections prompt; honest-area/length helpers; EPSG-code
  convenience table (curated, not the registry).
- **Risks**: a second "which CRS is this geometry in?" ambiguity enters the family (NTS geometry
  stays CRS-naive — the contract must be documentation + naming, as FeatureLayer already does with
  "WGS84 in"); ProjNet accuracy limits vs PROJ (documented, acceptable for teaching); version
  conflicts low.
- **Recommendation**: **Delay capability.** Chapter 10 v1 teaches the mental model with zero new
  packages. Revisit when the five-projections unit is actually scheduled; the salvage keeps the
  cost of waiting near zero.

---

## Suggested order of work

1. **Chapter 12** — zero missing capability, fully offline, and the biggest mental-model jump.
2. **Chapter 10** — zero missing capability; wants a `Line` style dash or nothing at all.
3. **Chapter 11** — after the STRtree wrap is reviewed and lands in vl-nettopologysuite.
4. **Chapter 13** — after the `NTS.Network` decision.

Success for this stage is the four designs above surviving review with the boundaries intact —
not any of them being built.
