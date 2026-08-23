# VL.Overworld

**Spatial thinking in [vvvv gamma](https://vvvv.org) — geometry first, maps second.**

This package contains **no nodes**. It installs the libraries that do, and adds the patches that
show them working together:

| library | what it does |
|---|---|
| [VL.Mapsui](https://github.com/rednotfound/VL.Mapsui) | draws a real map — tiles, layers, styles, picking |
| [VL.NetTopologySuite](https://github.com/rednotfound/VL.NetTopologySuite) | geometry: points, lines, polygons, and operations on them |
| [VL.GeoJSON](https://github.com/rednotfound/VL.GeoJSON) | reads and writes the format the data actually arrives in |

Install this one and all three arrive. Everything appears in vvvv's Help Browser.

> **Status: early.** Nothing here is on nuget.org yet.

> **This is not your first vvvv patch.** It assumes you can read a node graph, wire a pin and find
> the Help Browser. If that is not you yet,
> [VL.TheBigBang](https://github.com/chkw-rks/VL.TheBigBang) is where to start. It assumes
> **nothing at all** about maps or GIS.

---

## Two tiers

**The spine** is short, ordered, and each unit adds exactly one capability. Numbering is a claim
that order matters, so it is spent only here. It runs in **two acts: geometry first, maps second**
— because GIS is spatial *computation* before it is cartography, and a polygon answering questions
under your cursor renders instantly, offline, with nothing to agree to.

**Act I — space as computation.** No basemap, no network, no files.

| | | you end up with |
|---|---|---|
| **Tutorial 01** | Your cursor is now data | the dot you see and a line of WKT — two spellings of one position |
| **Tutorial 02** | A dot, a path, a plot of ground | three geometries, and the measure only each can answer |
| **Tutorial 03** | In or out | a spatial question whose answer flips as you move |
| **Tutorial 04** | The shortest line between | distance as a thing you can draw, not just a number |
| **Tutorial 05** | Grow a shape | geometry that generates geometry, driven by any signal |

**Act II — the earth arrives.**

| | | you end up with |
|---|---|---|
| **Tutorial 06** | Change how the world looks | a map — and the knowledge that its entire appearance is one string you own |
| **Tutorial 07** | Your own points, lines and polygons | shapes you made, drawn on the earth, styled by kind — Haneda, typed in as numbers |
| **Tutorial 08** | The map is just giving you coordinates | the loop closed: the map says which place is under your cursor, and geometry grown from that answer is drawn back onto the earth, live |
| **Tutorial 09** | Real data | GeoJSON, from a file or straight off the network |

**The prompts** are unordered, unnumbered and skippable. Pick one. Ignore the rest. There is no
prerequisite and no completion.

> *Two colours only* · *Minimal map* · *Live earthquakes* · *Out of this world* ·
> *Places and their names*

**All nine spine chapters exist.** The geometry act (01–05) is verified end to end; 08 is the
youngest, rebuilt 2026-08-23 onto the family's own rails after its first draft repeated a recorded
mistake (the story is in vl-mapsui's NOTES.md). The map act was numbered 01, 02 and 04 until
2026-08-22 — the geometry act took the front numbers; see
[CURRICULUM.md](https://github.com/rednotfound/VL.Overworld/blob/main/docs/CURRICULUM.md)'s third
correction for why.

### Why 08 comes before 09

Because that is the moment the map stops being a picture and becomes a question you can ask every
frame — *which place on the earth is under this pixel?* — with geometry grown live from the answer
and drawn straight back onto the earth. [Unfolding](http://unfoldingmaps.org/) — the Processing map
library written for designers and artists — teaches the same conversion before its GeoJSON
tutorial, because interaction is what a live map is *for*. Making someone read a file format before
they get there would be a strange choice.

---

## Where the order comes from

It has been wrong twice, and both corrections are written up in
**[CURRICULUM.md](https://github.com/rednotfound/VL.Overworld/blob/main/docs/CURRICULUM.md)**,
with the sources and their licences. (An absolute link on purpose: this README ships inside the
package, where a repository-relative path would not resolve.)

The short version. [FOSS4G GeoAcademy](https://github.com/FOSS4GAcademy)'s GST 101 is the
**coverage checklist** — it answers *do we teach what the field considers core?* It does not order
the units, because it is a graded university course whose reader cannot leave, and optimising for
coverage put a vocabulary lesson at the door twice running.

The order and the naming come from
[**#30DayMapChallenge**](https://github.com/tjukanovt/30DayMapChallenge), where more than 50,000
maps have been posted since 2019. Its days 1, 2 and 3 are Points, Lines, Polygons — in 2023, 2024
and 2025 alike. Projections land on day 19. Choropleth on day 13, and by 2025 it is gone.

That is **the same content order GST 101 uses.** What differs is one word per unit:

| GST 101 Lab 2 | 30DMC day 1 |
|---|---|
| *Spatial Data Models: vector vs raster* | **Points** |

A taxonomy, versus a thing to make.

---

## Why a separate package

GIS is a large topic, and **anything worth showing needs more than one library**. Reading a GeoJSON
file, styling it by geometry type and drawing it on a map touches three packages — and no single one
can declare the other two without pretending to be something it is not. A map engine has no business
requiring a GeoJSON reader; a GeoJSON reader has no business requiring a map engine. They compose
through NetTopologySuite, which is a library they share rather than an agreement they made.

So the patches need a home of their own. The shape is the one
[VL.ExtendedTutorials](https://www.nuget.org/packages/VL.ExtendedTutorials) and
[VL.TheBigBang](https://github.com/chkw-rks/VL.TheBigBang) already use: no assembly, an empty entry
document, everything in `help\`, and a nuspec that declares the libraries being taught.

**And these are not documentation — they are how the libraries get tested.** On 2026-08-16 a single
cross-package patch found three real defects in VL.Mapsui that 218 unit tests had not: a style that
silently erased every polygon, a fix for it that drew two markers on every point, and a nested style
collection that rendered nothing at all. None could have been caught by testing one library alone.
**This pack is a standing integration test that happens also to teach.**

### Where a patch belongs

> **One package → that package's own `help\`. Two or more → here.** The one exemption is a spine
> `Tutorial`, which may need a single package when the course's sequence requires it — a course with
> a hole at chapter 1 is worse than a duplicated node.

The validator checks it in both directions.

---

## If you installed VL.GIS

`VL.GIS` is retired, and **all six of its published versions are unlisted** (verified 2026-08-16).
Unlisting is not deletion, though, and it does nothing whatever for someone who already installed
it — which is what this section is for.

**`VL.GIS 0.2.0-alpha` conflicts with VL.Mapsui, and uninstalling does not fix it.** It declares
`BruTile 6`, while `Mapsui.Tiling` requires `BruTile [5.0.6, 6.0.0)`, and the two are not
compatible — `BruTile.Attribution` changed layout between them, so loading both throws
`TypeLoadException`. It also drags in `NetTopologySuite.IO.GeoJSON 3.0.0`, which pins
`NetTopologySuite.Features` to the **floor** of its range, 2.0.0, where VL.GeoJSON needs 2.1.0.

vvvv keeps every package's dependencies in one flat, machine-wide folder, and **uninstalling a
package does not remove them** — nor does reinstalling vvvv, because the folder lives in your user
profile. Delete these by hand:

```
%LOCALAPPDATA%\vvvv\gamma\nugets\BruTile.6.0.0
%LOCALAPPDATA%\vvvv\gamma\nugets\NetTopologySuite.Features.2.0.0
%LOCALAPPDATA%\vvvv\gamma\nugets\NetTopologySuite.IO.GeoJSON.3.0.0
```

Moving them somewhere else first is the reversible version, and is what we did on our own machine.

---

## Licence

MIT for the patches. **Sample data and tile services keep their own terms** — see
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md), which also records two basemaps that return a
perfectly good tile and are **not permitted for this use**. A request that succeeds tells you
nothing about whether you were allowed to make it.
