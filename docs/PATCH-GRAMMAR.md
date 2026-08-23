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
2. **Geometry goes ONTO the map in WGS84, through `Feature` → `FeatureLayer`; the map projects.**
   The patch never converts world coordinates to pixels for drawing. The pixel route has now
   failed twice, identically and undiagnosed (vl-mapsui NOTES.md, 2026-08-14 and 2026-08-23).
   The payoff phrase is already in `HowTo Draw your own shapes`: *the shape stays on ITS GROUND
   rather than on the window*.
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
| **`Int2` is not a vector category.** There is no `Vector (Join)` for it; the node is `Int2 (Create) [Primitive.Int2]` with pins X, Y, Output — and `2D.Int2` does not exist at all | chapter 12 failed rung 2 with `Not found: Vector (Join) … category: 2D.Int2` |
| **`GridSpread`/`LinearSpread` default to `Centered`, which is NOT tiling.** Centered puts the outer samples on the edges — spacing `Width/(Count-1)`. `Block` cuts the width into Count equal blocks and samples each block's centre, spacing `Width/Count`. A raster cell is a block | chapter 12's first rung-4 run: hairline seams between every cell. Compile clean, counters right, only the picture wrong |
| **A spread of Skia layers is `GridSpread (2D)` (or any spread) → `ForEach` → the layer node → `Group (Spectral)`.** `Group (Spectral)` is the one that takes a Spread; plain `Group` takes numbered pins. Layer process nodes inside the region get **per-slice state**, so N cells are N persistent nodes, not N allocations a frame | chapter 12; the idiom is copied from VL.Skia's own `Example Looking at Rectangles.vl` |
| **`LastCategoryFullName`/`LastDependency` are hints, not resolution** — but keep them true anyway; a compile proves a node exists, only the NodeBrowser proves its category | negative-tested in vl-nettopologysuite, 2026-08-14 |

The four verification rungs and the reasons they exist are in `CLAUDE.md`; the short form: exit 0
means *parsed*, the generated C# means *resolved*, and only a person at the GUI means *works*.
Every Act I chapter went through all four.
