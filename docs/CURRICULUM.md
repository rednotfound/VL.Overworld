# What this course is based on

This document has now been wrong twice — three times, counting the one below — in the same way
each time, and the corrections are the reason it is worth reading.

**First version.** The outline was *invented* — assembled from whatever the libraries had just run
into. Asked what it was based on, the honest answer was "nothing". So the field was searched, and
FOSS4G GeoAcademy's **GST 101** became the spine. That research was real and most of it survives
below.

**Second version — this one.** GST 101 is a graded university course. Its reader is enrolled, and
as this document already observed about Lab 3, it suits "an academic course where nobody leaves
after week two". A vvvv reader is **voluntary, visual, arrives through the Help Browser, and leaves
the moment nothing is on screen.** Optimising the sequence for coverage produced, twice running, a
vocabulary lesson at the door: first *"a coordinate is not a position"*, then — after congratulating
ourselves for moving that to chapter 06 — *"Vector and raster: your two kinds of layer"*. A better
taxonomy is still a taxonomy.

**So GST 101 is not discarded. It is demoted**, from *sequencing authority* to **coverage
checklist**: it answers "does this course teach what the field considers core?" It does not get to
order the chapters or name them. Those now come from evidence about how people voluntarily learn to
make things.

**Third version — 2026-08-22.** The first two corrections were about the *door*; this one is about
the *subject*. The course had equated "a payoff inside five minutes" with "a map on screen" — and a
map is the one payoff in this stack that opens with a consent gate: `Enabled` is off by default on
anything that fetches (OSM's tile policy is a constraint, not etiquette), so the old chapter 1
rendered nothing until the reader agreed to network traffic. Meanwhile the audience this course is
actually for — creative coders, who already hold vectors, transforms, fields and collision tests —
was being introduced to GIS through its *cartographic* surface instead of through the half they
already understand: **spatial computation.** A polygon that answers `Contains` under the cursor
renders instantly, offline, with zero consent gates, and passes the seven door tests below *better*
than the basemap did. So the spine now runs in **two acts: geometry first (01–05, no basemap, no
network, no files), maps second (06–09)** — the same demotion GST 101 received, applied to
cartography itself. The reframe follows the project brief (*teach spatial thinking through creative
coding*) and mirrors how the field's own libraries layer: JTS, Shapely and NetTopologySuite all put
computation below and rendering above. What did **not** change: every door still renders in the
first screenful, still has one obvious knob, and outcome-naming still rules — the corrections
compound, they do not replace each other.

---

## The sources, and what we may legally do with each

| source | what it is | licence | what we may do |
|---|---|---|---|
| [FOSS4G GeoAcademy](https://github.com/FOSS4GAcademy) — GST 101–105 | the FOSS4G community's own curriculum: 35 hands-on labs, funded by the US Department of Labor, aligned to the Geospatial Technology Competency Model | **CC-BY 3.0** | **adapt, and borrow wording**, with attribution. Now used as the coverage checklist |
| [#30DayMapChallenge](https://github.com/tjukanovt/30DayMapChallenge) | the community's own annual event, begun by Topi Tjukanov in 2019. One prompt a day through November; **over 50,000 maps posted** | **licence unverified — see below** | learn from the *sequence* and the *prompt grammar*. **Do not copy a prompt description** until the licence is checked |
| [UCGIS GIS&T Body of Knowledge](https://gistbok.ucgis.org/) | the field's authoritative curriculum taxonomy. Ten knowledge areas, 73 units, 26 "core" | reference work | check coverage against it. A degree taxonomy, not a shape to copy |
| [QGIS Training Manual](https://docs.qgis.org/latest/en/docs/training_manual/index.html) | the official practical course for QGIS — 20 modules | CC BY-**SA** 3.0 | learn from its sequencing; **do not adapt** — share-alike would spread into our MIT patches |
| [Geocomputation with R](https://r.geocompx.org/) | the programmer-facing book. Lovelace, Nowosad and Muenchow | prose CC-BY-**NC-ND**, code CC0 | **cite and link only** |
| [Unfolding](http://unfoldingmaps.org/) | Till Nagel's Processing/Java map library, written explicitly for designers and artists. The closest structural precedent that exists | code BSD; docs unverified | learn from its tutorial *order*. Quote sparingly, with attribution |

**GeoAcademy remains the only source we lean on as text**, carrying their
[attribution block](https://github.com/FOSS4GAcademy/GST101FOSS4GLabs/blob/master/Attribution_Block_for_Lab_Documents.md).
The 30DayMapChallenge's day *names* ("Points", "Hexagons", "Raster") are short factual themes and
are used here as evidence; its prompt **descriptions** are authored text and are quoted in this
document only as evidence about sequencing. Before any of that wording reaches a shipped patch,
**check the licence on tjukanovt/30DayMapChallenge.** This pack keeps a licence table precisely so
that decision is never made casually.

### Standards, which are a different kind of authority

These say what is *true* rather than how to teach it, and the libraries already conform:

| | |
|---|---|
| **OGC Simple Features** | the geometry model — Point, LineString, Polygon and their multi- forms. What NetTopologySuite implements, and therefore what a `Geometry` in a patch actually is |
| **RFC 7946 (GeoJSON)** | including §4, which mandates WGS84 longitude and latitude. Why VL.GeoJSON and VL.Mapsui agree about coordinates without an adapter |
| **EPSG registry** | the coordinate reference system codes. 4326 and 3857 are the two a web map lives between |

---

## The sequencing evidence

### The academic sources, which agree with each other

| | data model | on screen | styling | **coordinate systems** |
|---|---|---|---|---|
| **GST 101** | Lab 2 | Lab 4 | Lab 4 | **Lab 3** |
| **QGIS Training Manual** | — | **Module 2** | Module 2.4 | **Module 6** |
| **Geocomputation with R** | Ch 2 | Ch 9 | Ch 9 | **Ch 7** |

All three lead with the data model. Not one leads with coordinate systems; the QGIS manual is
explicit that CRS comes at Module 6, *after* students have mastered basic mapping.

### The #30DayMapChallenge, which agrees about order and disagrees about framing

**Days 1, 2 and 3 are Points, Lines, Polygons — in 2023, 2024 and 2025 alike.** Projections land on
day 19 (2025) and day 26 (2024). Choropleth on 13–16, and it is gone entirely from the 2025 list.
Raster on 21–29.

That is the **same content order the academic sources use.** The previous round's research was not
wrong. One word per unit is:

| | GST 101 Lab 2 | 30DMC day 1 |
|---|---|---|
| | *Spatial Data Models: vector vs raster* | **"Points"** — *"Map with point data. Focus on effective symbolization and density visualization."* |

A taxonomy versus a thing to make. Identical subject matter, opposite doors — and the second one is
what fifty thousand maps got made under, by people the rules explicitly welcome: *"Programming
skills are not in any way a requirement to do the maps."*

Counting the 2025 list by kind: 8 of 30 prompts are a geometry primitive or technique, 8 are an
aesthetic constraint (*Analog, Minimal map, 10-minute map, Icons, Black, Makeover, Process, Places
and their names*), 9 are a subject (*Earth, Air, Fire, Water, Urban, Transport, Boundaries…*), 3
name a dataset, 2 are meta. **Almost none is "learn X".** A prompt teaches a technique while reading
as a restriction; that is the whole trick.

### The naming evidence, from inside the vvvv community

| | [VL.TheBigBang](https://github.com/chkw-rks/VL.TheBigBang) (free, written) | [NODE Institute Beginner Class](https://thenodeinstitute.org/courses/vvvv-beginner-class/) (paid, live) |
|---|---|---|
| unit 1 | `Explanation 01. Types and IOBoxes` | "create your first visual compositions" |
| 3D | chapter 9 of 45 | session 2 of 8 |
| spreads / iteration | chapters 19–26 | session 4, *"Patterns in Motion: Iterating with Spreads & Lists"* |
| first thing rendered | **chapter 8 of 45** | session 1 |

Same community, same material, opposite naming — and the outcome-named one is the one people pay
for. Every NODE session title is an artefact with the machinery demoted to the subtitle.

**Rule taken from this:** *name a unit by what the reader ends up with; put the concept in the
subtitle.* "Coordinate systems and distortion" is a topic. "Put the same country in five projections
and watch Greenland eat Africa" is an outcome. The concept survives either way.

### Two tiers, which is how every large creative-coding curriculum is arranged

[The Coding Train](https://thecodingtrain.com/tracks) states it plainly: **Main Tracks** are
"sequenced video tutorials that you can follow like a course syllabus"; **Side Tracks** "don't
necessarily need to be watched in order". Rodenbröker: one *Essentials* course plus twenty
interest-entry modules. The Gray Book: Courses / Tutorials / Examples.

**Rule taken from this:** numbering is a *claim* that order matters, so it is spent only on the
spine. Number everything and the numbers become noise — and a reader arriving at chapter 05 feels
late, when the whole point is that they are not.

### What a first unit looks like, converged across sources

| source | the first thing the learner gets |
|---|---|
| [The Book of Shaders](https://thebookofshaders.com/02/) | a screen filled with one bright colour — text output is refused as *"an overcomplicated task for a first step"* |
| [Unfolding](http://unfoldingmaps.org/) | six lines → the whole planet, draggable. No projection, no CRS, no data |
| [p5.js](https://p5js.org/tutorials/) | "an interactive landscape" |
| Coding Train, p5 track | five drawing lessons before the first variable; `mouseX` before `var` |
| NODE Beginner Class | "your first visual compositions", session 1 of 8 |
| VL.TheBigBang | Types and IOBoxes; nothing rendered until chapter 8 of 45 |
| the Gray Book | **no first lesson at all** — it links out to YouTube |

Distilled into the tests a spine chapter here must pass:

1. **It renders in the first screenful.**
2. **It is already running when opened** — a worked example, not a blank canvas
   ([Sweller & Cooper 1985](https://files.eric.ed.gov/fulltext/EJ1161818.pdf); novices learn more
   from studying a working artefact than from building one). vvvv gives this for free.
3. **It has exactly one obvious knob**, and turning it *is* the lesson. Two readers turning the same
   knob must get visibly different screenshots.
4. **Its title names the picture, not the machinery.**
5. **It contains no vocabulary lesson.** [Diátaxis](https://diataxis.fr/tutorials/): *"A tutorial is
   not the place for explanation."* Link out to an `Explanation` patch.
6. **It is finishable in five minutes and skippable without penalty.**
7. **It ends by pointing at three different next things, not one** — Resnick's *wide walls*: *"It's
   not enough to provide a single path from low floor to high ceiling."*

### And the honest counterweight

None of this is an argument against structure. Sweller says novices genuinely need worked examples
rather than discovery. Rodenbröker, whose whole catalogue is outcome-named, still
[defends drilling](https://trcc.timrodenbroeker.de/learning-to-code-essential-tips-for-beginners/):
*"Question your motives. Do you want to learn how to code or do you just want to create an
impressive image?"* **"Tutorial hell" is an argument against structure with no exit into independent
making**, and the fix is fading and a Create stage, not the removal of scaffolding. That is what the
prompt tier is for.

Both *The Nature of Code* and *The Book of Shaders* also refuse, in writing, on page one, to be
anyone's first book — and that refusal is exactly what earns them the right to skip fundamentals.
This pack does the same, and points at VL.TheBigBang.

---

## GST 101 as the coverage checklist

Still read rather than skimmed. The change is the last column: this now records **whether we cover
it**, not **when**.

| lab | what it actually teaches | covered? |
|---|---|---|
| **0** Getting to Know FOSS and FOSS4G | what open source is, OSGeo, installing QGIS | **skipped** — a vvvv reader already has their tool |
| **1** GIS Application Paper | a writing assignment | **skipped** — academic assessment |
| **2** Spatial Data Models | vector vs raster; open a shapefile and a Landsat scene; notice vector layers arrive in a random colour | spine 06 (raster, as *"change how the world looks"*) and 02/07 (vector) |
| **3** Coordinate Systems and Map Projections | EPSG codes; shape and area **distortion** across world projections; UTM; datum | **not yet, and blocked** — no reprojection node exists in the family |
| **4** Displaying Geospatial Data | single symbol vs **categorised by attribute value**; layer order; legend naming | spine 07 partly; the categorised half unblocked 2026-08-23 (`StyleByValue`) — a unit for it is not yet written |
| **5** Creating Geospatial Data | digitising | **out of scope** — `Mapsui.Nts.Editing` is not wrapped |
| **6** Remote Sensing and Analysis | imagery interpretation | **out of scope** — another field |
| **7** Basic Geospatial Analysis | buffers, overlays, selection | **belongs to VL.NetTopologySuite**, which has 9 of them — Act I chapters 03–05 will teach them |

Two observations from the original reading, both still load bearing:

- **Lab 3 is not the abstraction it sounds like.** It does not argue that longitude is not metres;
  it puts the same country into several projections and has you *look*. Concrete, visual, and
  exactly what 30DMC day 19 asks for too. The sources agree; we simply cannot build it yet.
- **Lab 2's lesson is already on our screen and nobody has named it.** That was true and led to the
  wrong conclusion — that chapter 01 should be the naming. Naming what is on screen is an
  *explanation*, and belongs after the tutorial, not as it.

---

## The chapters

### The spine — two acts, ordered, each unit adding exactly one capability

**Act I — space as computation.** No basemap, no network, no files. Geometry lives in a small
local space and is rendered directly; every chapter runs offline the moment it opens. Renumbered
2026-08-22 (see the third correction above); titles of the unwritten chapters are working titles
from the design review and may change as they are built.

| | title | what it adds | packages |
|---|---|---|---|
| 01 | **Your cursor is now data** | a position becomes a value: Coordinate → Point → WKT | VL.NetTopologySuite |
| 02 | **A dot, a path, a plot of ground** | three geometries, and the measure only each can answer | VL.NetTopologySuite |
| 03 | **In or out** | a question asked of two geometries, answered every frame | VL.NetTopologySuite |
| 04 | **The shortest line between** | distance as a drawable thing — `Nearest Points` | VL.NetTopologySuite |
| 05 | **Grow a shape** | geometry that generates geometry, driven by any signal | VL.NetTopologySuite |

**Act II — the earth arrives.** The same values, now with the planet under them.

| | title | what it adds | packages |
|---|---|---|---|
| 06 | **Change how the world looks** | a map exists, and its appearance is a string you own | VL.Mapsui |
| 07 | **Your own points, lines and polygons** | your geometry drawn on the earth, styled by type | + NTS |
| 08 | **The map is just giving you coordinates** | `WorldToScreen` → draw anything you like on top | + NTS |
| 09 | **Real data** | GeoJSON, from a file or from the network | + VL.GeoJSON |

**Single-package spine chapters use the exemption written into this pack's rules** — Act I is
VL.NetTopologySuite throughout, and 06 is VL.Mapsui alone. The exemption and its reason are in
`CLAUDE.md`; briefly, a course with a hole at its door is worse than a duplicated node, and each
act's opener adds exactly one capability on purpose.

**08 comes before 09 deliberately.** Unfolding puts `getScreenPosition` *before* its GeoJSON
tutorial and says why: *"the easiest method to create a custom style is to draw the marker
yourself."* That is the moment the map stops being a map and becomes a coordinate provider, and the
reader returns to the visual language they already have. It is the strongest thing this stack can
offer a creative coder, and making them read a file format first would be a strange choice.

### The prompts — unnumbered, unordered, skippable

Grammar copied from the 30DayMapChallenge: a **material restriction** or a **subject**, never
"learn X". Tone copied from [Genuary](https://genuary.art/) (*"You don't have to follow the prompt
exactly. Or even at all." / "It's fine to skip days."*) and Nodevember (*"a challenge, not a
contest"*).

First set, chosen so that every one is buildable with nodes that exist today:

| prompt | after 30DMC | needs |
|---|---|---|
| **Two colours only** | 2024 day 22 | nothing new |
| **Minimal map** | 2025 day 11 | nothing new |
| **Live earthquakes** | *Fire* / *Time and space* | **built 2026-08-23, rung 4 passed** — `HTTPGet` (ships with vvvv) + USGS GeoJSON, no key; magnitude drives `StyleByValue`, hover-`Pick` reads the properties |
| **Out of this world** | 2025 day 18 | procedural NTS geometry; **no basemap, no network** |
| **Places and their names** | 2025 day 24 | `LabelStyle` |

---

## What the curriculum found in the libraries

The pack's second job: **checking the libraries against an outside standard finds gaps that using
them does not.** The ranking is now by *how many prompts each gap blocks*, which counts things
people actually chose to make.

| rank | missing | blocks |
|---|---|---|
| 1 | ~~**`GradientTheme`**~~ — **closed 2026-08-23** as `StyleByValue` (vl-mapsui). Was: colour driven by an attribute value | unblocked: Polygons, Choropleth, Population, Heat, Urban, most thematic work — and GST 101 Lab 4's categorised half. Multi-stop `ColorBlend` ramps remain the follow-up |
| 2 | **Reprojection** (`VL.ProjNet`) | Projections — a prompt in *every* year — plus *North is not always up* and *Antarctica*. Nothing in the four packages reprojects; `SphericalMercator` is used internally and never exposed |
| 3 | **Image markers** (`SymbolType.Image`) | Icons. Needs `BitmapRegistry` |
| 4 | **Layer opacity, basemap recolouring** | Vintage style, Black, most aesthetic prompts |
| 5 | **Map as texture, and a transformable map layer** | the entire vvvv-native shader angle |

### The road beyond the two acts — the design brief's chapters vs. the libraries, measured 2026-08-22

The direction brief (*teach spatial thinking through creative coding*) sketches twelve conceptual
chapters. Where each stands, so nobody re-derives it:

| brief chapter | bucket | detail |
|---|---|---|
| 1–4 geometry, data, questions, transforms | ✅ **built** | Act I, chapters 01–05. Feature construction unlocked by `NTS.Feature` (2026-08-22); `Touches/Overlaps/Crosses`, `ConvexHull/Simplify`, `Voronoi/Delaunay` arrive per vl-nettopologysuite's roadmap rule — when a chapter needs them |
| 5 coordinates have meaning | ⛔ **blocked** | nothing in the family reprojects (gap rank 2). Future `VL.ProjNet`; full salvage material in retired `vvvv-gis` (`ProjectionNodes.cs`). Natural slot: the hinge between the acts, with chapter 08 |
| 6 maps | ✅ **is Act II** | chapters 06–09. Its thematic half unblocked 2026-08-23 by `StyleByValue` (was gap rank 1) — a choropleth prompt or chapter is now buildable |
| 7 raster as field | 📦 **new territory** | zero support: no GeoTIFF, no DEM, no sampling. Do not promise |
| 8 find things fast | 🔧 **waiting** | `STRtree` sits in vl-nettopologysuite's roadmap "Later" with the ProcessNode caveat; the brief's 100k-points timing demo is that node's acceptance test — build both together |
| 9 networks, 10 3D | 📦 **new territory** | `CoordinateZ` exists and nothing else does |
| 11 big data, 12 cloud-native | ⛔ **do not build** | by the brief's own rule: a format may only be introduced as the answer to a problem the reader has already felt |

The chapter-authoring grammar that Act I established is recorded in
[PATCH-GRAMMAR.md](PATCH-GRAMMAR.md).

**Gap 5 is a wall, and must not be promised in a chapter.** `PixelSpace.Draw` calls
`canvas.SetMatrix(SKMatrix.Identity)`, discarding whatever transform the VL.Skia scene graph
applied, and nothing in VL.Mapsui produces an `SKImage` or a texture. Whether rendering the *whole
scene* to a texture still works is **unmeasured** — a measurement to take, not a claim to make.

Also confirmed absent, so that no prompt quietly assumes them: convex hull, simplify, any
elevation/DEM/raster reading, callouts, editing, and `LabelStyle.CollisionDetection` (measured
inert — 763 px with and without).

---

## Using this document

Before adding a unit: decide whether it is **spine** or **prompt**, and say what it is based on. A
unit with no source is allowed — several prompts have none, because a desktop GIS has neither a
frame loop nor a cursor to ask — but that should be a stated decision rather than an accident.

Before naming it: **name the picture, not the machinery.**

**The rule about where a patch lives, and its one exemption, are in `CLAUDE.md`.**
