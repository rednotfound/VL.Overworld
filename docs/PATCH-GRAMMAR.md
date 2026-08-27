# The shared grammar of a geometry-act chapter

Written down 2026-08-22, after all five Act I chapters shipped and passed a human's eyes — so this
records what was **built and verified**, not a plan. New chapters follow it; deviations are
decisions to note here, not accidents. The door tests a spine chapter must pass are in
[CURRICULUM.md](CURRICULUM.md) and are not repeated.

---

## The canvas, three zones

```
┌─ narrative column ─────┬─ the live patch ───────────────────┬─ (renderer opens as
│ ONE Comment IOBox      │ dataflow top to bottom:            │  its own window)
│ fontsize 11,           │   sources (editable IOBoxes)       │
│ at roughly             │   ↓ construction (NTS nodes)       │  Bounds default
│ Bounds -620,-60,540,~  │   ↓ the question / the operation   │  ~"926,114,700,700"
│                        │   ↓ render conversion              │
│ fixed section order:   │   Group → Renderer                 │
│   NN - Title line.     │                                    │
│   one-line idea        │ SAME ROWS for things that belong   │
│   the discoveries      │ together: a vertex's pad, split    │
│   PLAY                 │ and Coordinate share one row       │
│   WHAT HAPPENED?       │                                    │
│   GIS WORDS            │ SHORT LABELS touch the control     │
│   CREATIVE CONNECTION  │ they explain ('<- watch this       │
│   (exemption para)     │ flip as you cross the edge')       │
│   NEXT - three ways    │                                    │
└────────────────────────┴────────────────────────────────────┘
```

Hard rules, in force across chapters 01–05:

1. **Section order is fixed** and GIS terminology appears **only from GIS WORDS onward** — the
   reader experiences first, names second. Node names stay professional (`Buffer`, `Contains`);
   the chapter title names the picture.
2. **Every expected action has a label touching the thing** — nobody reads sixty lines before
   clicking. The long column is for after.
3. **NEXT always offers exactly three pointers**, different in kind (next chapter / a prompt or
   exercise / a look back or sideways). Resnick's wide walls, via CURRICULUM.md.
4. **One obvious knob per chapter** (mouse counts as a knob). Chapter 05's second knob
   (`Segments`) is subordinate and labelled as a discovery, not a control.
5. **Honesty clauses**: anything the libraries cannot do yet is named as a known gap in the
   narrative ("Touches, Overlaps and Crosses are on the roadmap"), and every measure carries its
   units caveat ("this canvas's own units; on the earth this lies — Act II walks into it").
6. **Single-package spine chapters carry the exemption paragraph** naming why (the validator
   warns until the description says it).

## The shared visual language

- **Space**: geometry lives in the renderer's own scene space, shapes within roughly
  x ∈ [-1.2, 1.2], y ∈ [-0.6, 0.6]. No longitude, no files, no network anywhere in Act I.
- **Colors**: derived/answer geometry teal `0.15, 0.55, 0.5` (translucent `0.55` when a fill
  coexists with sources); signal/measurement orange `1, 0.66, 0`; source outlines neutral gray
  `0.75–0.8`; true/false shown by **presence** (a layer's `Enabled` pin), not by color-switching —
  chapter 03's fill takes `Contains` straight into `Enabled`, no `if` anywhere.
- **Readouts**: the number or bool that IS the lesson gets fontsize 14 and a label; WKT boxes are
  plain String IOBoxes wide enough to read.

## The map act — the two sanctioned directions, and the rule that would have prevented Tutorial 08's first draft

Written down 2026-08-23, after that draft rebuilt a recorded dead end. Act II chapters follow
everything above, plus:

1. **Before composing any node combination new to the family, search the owning libraries'
   NOTES.md for the nodes involved.** CLAUDE.md and this file record what WORKS; NOTES.md records
   what FAILED and why. Tutorial 08's first draft drew a Skia `Circle` positioned by
   `WorldToScreen` through `WithinCommonSpace (PixelTopLeft)` — the exact overlay design
   vl-mapsui's NOTES.md had recorded as drawing nothing on 2026-08-14, complete with a standing
   "output disappeared downstream of `WithinCommonSpace`, not diagnosed" mystery. Every static
   check passed; the failure log was the only place the answer existed, and it was not on the
   pre-writing reading list. Now it is.
2. **Ask what the thing is anchored to. There are two legitimate answers and one failed one.**
   *(Corrected 2026-08-23 — the earlier wording of this rule said "the patch never draws over the
   map", which is both wrong and, taken seriously, would forbid this course every readout, button
   and scale bar it will ever need.)*

   | anchored to | route | example |
   |---|---|---|
   | **the ground** — it must stay on its place when you pan | WGS84 → `Feature` → `FeatureLayer`. **The map projects; the patch never computes pixels.** | a marker, a shape, chapter 10's cross |
   | **the window or the cursor** — furniture, not geography | screen space, drawn OVER the map: a Mapsui **widget**, or a Skia layer in the `Group` above `ToSkiaLayer` | a coordinate readout, a button, a scale bar |
   | ~~the ground, drawn by converting to pixels in the patch~~ | **failed twice, undiagnosed** — `WorldToScreen` → `WithinCommonSpace (PixelTopLeft)` → a Skia layer (vl-mapsui NOTES.md, 2026-08-14 and 2026-08-23) | — |

   The payoff phrase for the first row is already in `HowTo Draw your own shapes`: *the shape stays
   on ITS GROUND rather than on the window*. The second row is not a loophole — **it is how every
   map library in the field is built**, and how this family is already built:

   - Mapsui keeps `Map.Widgets` as a collection entirely separate from `Map.Layers`, and VL.Mapsui
     already wraps three of them — `ScaleBar`, `Attribution`, `ZoomButtons` — **confirmed on screen
     2026-08-14, buttons included**. Nine widget renderers are registered, `TextBox` and
     `MouseCoordinatesWidget` among them.
   - OpenLayers puts the cursor readout in `ol/control/MousePosition`, a **control** in the map's
     overlay container; `ol/Overlay` is the separate thing you use when something must stay pinned
     to a coordinate. Leaflet ships scale bar, layer switcher, zoom buttons and attribution as
     `Control`s. No library in the field models its scale bar as a layer.
   - **Every chapter in this pack already draws Skia over the map**: the render `Group` takes
     `ToSkiaLayer`'s output *and* `Console`'s, and the console draws on top. That route is shipped
     and rung-4 verified; it is simply not the same route as the one that failed.

   What actually failed, in both incidents, was a **space conversion of a georeferenced thing**.
   A readout that follows `Mouse [Graphics.Skia.IO]`'s `Position In World` never touches the map's
   projection at all, and is Act I's oldest idiom.
3. **Data comes OUT of the map through `Pick` and `ScreenToWorld`** — into readouts, and into
   geometry that may go back in through rule 2.
4. **A wrapped node with no GUI consumer is unmeasured territory, not a green light.**
   `WorldToScreen` was unit-tested (exact inverse of `ScreenToWorld`) and had never been consumed
   on screen. "First consumer" should have been read as "first measurement".

## How a chapter is born, and what it is afterwards

The first draft is **generated once by a PowerShell script** (family precedent: the old basemap
tutorial began the same way) — the Act I generators lived in a session scratchpad and are gone,
**which is fine: the shipped `.vl` files are now the templates**. Copy node XML from them, or
from vvvv's own help patches, rather than composing from memory. From the moment a chapter is
checked in — and doubly so once someone arranges it by hand in the GUI — it is edited **in place
only**, each change anchored on a match asserted to occur exactly once (see CLAUDE.md).

Ids come from `tools\New-VLId.ps1`, never derived by editing. Files are UTF-8 **with BOM**, CRLF.

## How to find out, instead of guessing — written down 2026-08-23 after a day of both

Chapters 10 and 12 and the first `Explanation` were built in one day, and most of the elapsed time
went on questions that had cheap answers. In order of cost:

1. **Read the node's own `Summary` and `Remarks` first.** `Text`'s definition says
   *"Use FontAndParagraph [Graphics.Skia.Paint] to adjust various parameters"*. That sentence was
   grepped, printed, and ignored, and the font size was then set twice on the wrong pin — on two
   different patches, both fixed by the user in the GUI. `grep -n -A3 '<Node Name="X"' <pack>.vl`
   costs one command.
2. **Probe-compile instead of guessing a category.** vvvvc's error *names the real one*:
   `Not found: Vector (Join) … category: 2D.Int2` and, better,
   ``1. Control.Switch`1  In: Index: Integer32  Out: Output: T``. So a throwaway
   `help\Tutorial 99 probe.vl` holding ten candidate nodes, compiled with
   `-Patch "Tutorial 99*"`, answers ten questions in a handful of runs — and it is how
   `Primitive.Float64`, `Primitive.String`, `Control.Switch`, `Primitive.Boolean.OR` and
   `Int2 (Create)` were all settled. **Delete the probe before validating**: it has no genre and
   no family package, and rule 1 and rule 6 will both fail it.
3. **A link-type error produces no C# at all, so rung 3 cannot help — bisect by subtraction.**
   `types dont match: Float32, Float64` names neither node nor pin. Strip the patch to halves,
   compile, repeat. Four runs found it: `LinearSpread`'s `Center`/`Width` are Float32 and my
   Float64 annotation was the whole problem.
4. **Multi-step `.vl` edits go in a script FILE, not an inline command block** — CLAUDE.md rule 4,
   violated twice in one day. A PowerShell here-string followed by `-replace` on the same line
   parses as a culture argument and fails silently enough to waste a round trip. Writing the same
   edit to a `.ps1` and running it worked first time, every time.

## Two failures of judgement from the same day, because they will recur

- **Iterating on a symptom the reader named, instead of questioning the premise.** Tutorial 10 was
  built three times. The first two versions each fixed exactly what the reader complained about —
  "the numbers don't mean anything", then "put them on the map" — and both left the subject
  untouched. What actually had to break was an assumption nobody had stated: *we only have one
  projection, because the family has no reprojection engine.* False: an engine solves arbitrary
  CRS by EPSG code, while a forward cylindrical projection is a line of arithmetic. **When the
  second fix also fails to land, stop fixing and go looking for the premise.**
- **Replacing an uncommitted patch that worked.** The cross version of Tutorial 10 was overwritten
  by a full-template rewrite before it was ever committed, and had to be rebuilt from scratch to
  become `Explanation The map is not to scale`. **Copy an uncommitted `.vl` aside before replacing
  it**, and retire the generator template the moment a human edits the patch — rename it
  `…RETIRED-do-not-expand.vl` so that re-expanding is not one keystroke away.

## Patch-engineering facts, each paid for once

Every one of these was caught loudly by rung 2 (the compile harness) or rung 3 (reading the
generated C#) during Act I. They are the difference between an afternoon and a week:

| fact | how it bit |
|---|---|
| **VL widens Float32→Float64 on links automatically; it never narrows.** Coordinate→Vector2 needs `ToFloat32 [System.Conversion]` before `Vector (Join)` | chapter 04 failed with `Float64 is no Float32!` until the four converters went in |
| **Fluent NTS operations (geometry in, geometry out) expose `Output`; non-fluent expose `Result`** | chapter 05 failed with `Buffer doesn't have a pin called "Result"` |
| **A Renderer needs its `Bound to Document` pin present with `DefaultValue="True"`** or the window never opens on document load | chapter 01's first compile showed `Bound_to_Document = false`; caught reading the C# |
| **`Mouse [Graphics.Skia.IO]` gives `Position In World` already in scene space** — no conversion — but its `Context` output must be wired into the render `Group` or it never hears anything | the canonical idiom, copied from vvvv's own examples |
| **Skia's `Polygon` draws both polylines and fills**: `Closed=False` + `Stroke` paint is the multi-line; `Closed=True` + fill paint is the shape. Include `<PinReference Kind="InputPin" Name="Closed" />` in the node reference to materialise the pin | chapters 02–05 |
| **A ForEach region is hand-authorable**: `StatefulRegion` + inner `Patch` with Create/Update/Dispose (all `ManuallySortedPins="true"`) + `ControlPoint`s on the top/bottom borders; ALL links live in the outer patch, referencing control-point ids | chapter 05 converts the buffer's variable-count Coordinates; it compiles to a native C# `foreach` |
| **Attribute text stores line breaks as `&#xD;&#xA;` entities and must not contain a raw `"`** — a double quote ends the attribute and the XML | chapter 04's narrative broke on `"nearest"`; use apostrophes |
| **A layer built FROM the map and drawn ON it is a genuine dataflow cycle** — `ScreenToWorld` → geometry → `FeatureLayer` → `Map.Layers` loops; break it with `FrameDelay` on the layer (one frame old, invisible to the eye) | chapter 08 failed rung 2 with `Cycle detected. Execution order undefined.` |
| **`LinearSpread`'s `Center` and `Width` are Float32, not generic**, so annotating them Float64 is a type error and the loop needs a `ToFloat64` on the item. `GridSpread (2D)` takes Vector2 there, which is the same fact wearing a vector | chapter 10 failed rung 2 with `types dont match: Float32, Float64`, four probe compiles from the answer |
| **`Switch` (by index) lives in `Control`, not `Primitive`**; `Switch (Boolean)` (condition, two inputs) lives in `Primitive`. Boolean `OR` is uppercase, in `Primitive.Boolean`. Scalar maths for Float64 — `Sin Cos Tan Asin Acos Atan Sqrt Ln Log Exp Pow Floor PI` — is all in **`Primitive.Float64`**, not `Math`; only the operators (`+ - * /`) are in `Math` | chapter 10; vvvvc names the real category in its error, so one compile answers one question |
| **Text is painted by `FontAndParagraph [Graphics.Skia.Text]`, not by `Fill`.** Font `Size` (a single float, ~0.04), `Color`, family, style, line height and alignment all live on that node; its `Output` goes to `Text`'s `Paint`. Skia `Text`'s own `Size` is a Vector2 **layout box** (default `0, 1`, width 0 = auto), which is not a font size at all | set twice as if it were a font size, on two different patches; **the `Text` node's own Remarks say `Use FontAndParagraph [Graphics.Skia.Paint] to adjust various parameters`** and it was read and ignored. The user fixed it in the GUI both times |
| **`GeometryCollection [NTS.Geometry]` is the flattener.** `Coordinates` on a collection walks it and returns every vertex, so a spread of geometries becomes one flat coordinate list and a loop-inside-a-loop is avoided | chapter 10 draws 134 coastlines from one flat ForEach |
| **A ForEach's top `ControlPoint` is a SPLICER** — it hands the loop one item per iteration. A constant the whole loop needs (the query polygon, a mouse position) is linked **directly from the outer pin to the inner node's pin**, no control point at all; VL makes the border crossing itself. VL.Skia's `Example Looking at Rectangles` wires its mouse position into the loop's `Distance` exactly that way | chapter 11 failed rung 2 with `Polygon is no Sequence<Geometry>!` after the polygon was fed to a top control point |
| **`Keep` is an output pin on the region's `Update` patch**: `<Patch Name="Update"><Pin Name="Keep" Kind="OutputPin" /></Patch>`, and a link from a bool inside the loop to that pin id (in the outer patch, `IsHidden="true"`). Items whose Keep is false are dropped from the output spread. An identity pass-through — top control point linked straight to the bottom one — is legal and is how a pure filter is written. Compiles to `if (Result) builder.Add(item)` | chapter 11's two filter loops; shape copied from VL.Skia's `Example Spray` |
| **A `Cache` region is hand-authorable and can contain a ForEach.** `ProcessStatefulRegion Name="Cache"`, pins `Force` / `Dispose Cached Outputs` / `Has Changed`, inner patches `Create` and `Then`, top and bottom control points; every link — including those of the nested ForEach — lives in the outer patch. Compiles to `CacheManager.InputsChanged(inputs)` gating the whole body, so a spread of static-node outputs (100,000 NTS `Point`s) is built **once** and handed downstream as the same objects every frame | chapter 11; this is what lets `SpatialIndex`'s `Indexes Built` stay at 1 — **watched at 1 in the GUI**, 2026-08-23 |
| **`Points [Graphics.Skia.Layers]` draws a whole `Spread<Vector2>` as one layer** (pins `Points`, `Size`, `Paint`). 100,000 of them at 8 fps *with* a 100k `Contains` loop beside it — the loop is the cost, not the drawing. `RandomSpread (2d) [Collections.Spread]` (Center, Size, Seed, Count) is itself cached and hands out the same spread every frame | chapter 11 |
| **`Int2` is not a vector category.** There is no `Vector (Join)` for it; the node is `Int2 (Create) [Primitive.Int2]` with pins X, Y, Output — and `2D.Int2` does not exist at all | chapter 12 failed rung 2 with `Not found: Vector (Join) … category: 2D.Int2` |
| **`GridSpread`/`LinearSpread` default to `Centered`, which is NOT tiling.** Centered puts the outer samples on the edges — spacing `Width/(Count-1)`. `Block` cuts the width into Count equal blocks and samples each block's centre, spacing `Width/Count`. A raster cell is a block | chapter 12's first rung-4 run: hairline seams between every cell. Compile clean, counters right, only the picture wrong |
| **A spread of Skia layers is `GridSpread (2D)` (or any spread) → `ForEach` → the layer node → `Group (Spectral)`.** `Group (Spectral)` is the one that takes a Spread; plain `Group` takes numbered pins. Layer process nodes inside the region get **per-slice state**, so N cells are N persistent nodes, not N allocations a frame | chapter 12; the idiom is copied from VL.Skia's own `Example Looking at Rectangles.vl` |
| **`LastCategoryFullName`/`LastDependency` are hints, not resolution** — but keep them true anyway; a compile proves a node exists, only the NodeBrowser proves its category | negative-tested in vl-nettopologysuite, 2026-08-14 |

The four verification rungs and the reasons they exist are in `CLAUDE.md`; the short form: exit 0
means *parsed*, the generated C# means *resolved*, and only a person at the GUI means *works*.
Every Act I chapter went through all four.
