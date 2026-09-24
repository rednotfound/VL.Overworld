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

**The spine** is short, ordered, and each unit adds exactly one capability. It runs in **seven
chapters, one per question** — a lesson is numbered `chapter.lesson`, so a new lesson renumbers
its own chapter and nothing else. Numbering is a claim that order matters, and it is spent only
here. Geometry comes before maps because GIS is spatial *computation* before it is cartography,
and a polygon answering questions under your cursor renders instantly, offline, with nothing to
agree to.

**Chapter 1 — how does a shape become data?** No tiles, no network.

| | | you end up with |
|---|---|---|
| **1.1** | Your cursor is now data | one cursor read by two coordinate systems — a canvas and a tile-less map — and a line of WKT naming the position both are spelling |
| **1.2** | A dot, a path, a plot of ground | three geometries, and the measure only each can answer |
| **1.3** | In or out | a spatial question whose answer flips as you move |
| **1.4** | The shortest line between | distance as a thing you can draw, not just a number |
| **1.5** | Grow a shape | geometry that generates geometry, driven by any signal |

**Chapter 2 — how does my data get onto the earth?**

| | | you end up with |
|---|---|---|
| **2.1** | Change how the world looks | a map — and the knowledge that its entire appearance is one string you own |
| **2.2** | Your own points, lines and polygons | shapes you made, drawn on the earth, styled by kind — Haneda, typed in as numbers |
| **2.3** | The map is just giving you coordinates | the loop closed: the map says which place is under your cursor, and geometry grown from that answer is drawn back onto the earth, live |
| **2.4** | Real data | GeoJSON, from a file or straight off the network |

**Chapters 3–7 — one question each, one lesson so far.** A thin chapter is a labelled growth
slot, not a stub: reprojection lands in 3 when the family can build it, raster in 5, more network
in 6, and chapter 7's lessons are earned one at a time by the laboratory (`docs/ACT-IV-LAB.md`).
Two of these lessons are map-free on purpose — a basemap can draw only one projection, and it
would put an object underneath a field.

| | | you end up with |
|---|---|---|
| **3.1** — *why does the same place have different numbers?* | Same place, different numbers | three projections on one knob — and the discovery that your lon/lat scatterplots were already projected maps |
| **4.1** — *how do you ask 100,000 things quickly?* | Do you really want to ask 100,000 points one by one | a spatial index — and the contract that a candidate is not a result |
| **5.1** — *what if space is not an object?* | What if space is not an object | the field worldview: every place has a value, and a raster is a field that was sampled |
| **6.1** — *when is close not reachable?* | Close does not mean reachable | a street network where distance, topology and routing come apart — close the bridge and watch |
| **7.1** — *what if the world does not fit in memory?* | What if the world does not fit in memory | a remote 18.6 MB file answering your question after 0.07% of it was read — the question computed the byte address |

**Three Explanations** — each proves a fact on screen; skippable; the title is the assertion:
*The map is not to scale* — the cross under your cursor is 200 km each way, and it swells as you
pan north. *You do not have to read everything* — the same 754 features twice on disk, and the
side that partitioned them reads ~26× less to give the identical answer. *Sharper is a different
question* — the place under your cursor asked its height at six zooms at once: the answers walk
toward the survey's as pixels shrink, and the bytes per answer FALL.

**The prompts** are unordered, unnumbered and skippable. Pick one. Ignore the rest. There is no
prerequisite and no completion.

| | | network? |
|---|---|---|
| *A mountain* | Fuji from the top — nine crater peaks typed by hand, four trails from a file | file only |
| *Live earthquakes* | the last 24 hours of the ground moving, every dot sized by magnitude | asks first |
| *How high is here* | real elevation under your cursor, decoded from a terrain tile's pixels | asks first |
| *Which door* | the quickest door by the streets is not the nearest as the crow flies | offline |
| *Grow a town* | click, and a street network grows until two towns touch | offline |
| *Paint by numbers* | 177 countries painted by population — and the two lies every choropleth tells | offline |

Anything that can fetch (basemap tiles in 2.1, 2.3, 2.4, *The map is not to scale* and *Sharper is
a different question* — which also fetches Terrarium elevation tiles; 7.1's ranged reads;
the two prompts marked *asks first*) starts with its switch **off**: opening a patch is not
agreeing to network traffic.

**All fourteen spine lessons, all three Explanations and all six prompts exist and pass all
four verification rungs.** The spine was flat-numbered 01–14 until 2026-09-24, when it gained its
chapters; see
[CHAPTER-STRUCTURE-PROPOSAL.md](https://github.com/rednotfound/VL.Overworld/blob/main/docs/CHAPTER-STRUCTURE-PROPOSAL.md)
for the decision and
[CURRICULUM.md](https://github.com/rednotfound/VL.Overworld/blob/main/docs/CURRICULUM.md) for the
corrections that came before it.

### Why 2.3 comes before 2.4

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
