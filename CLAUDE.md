# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working in this repository.

## Start here

Read this section, then `docs/CURRICULUM.md`, then `D:\2026_Projects\vl-mapsui\docs\RULES.md`.
**Before writing or editing a chapter, read `docs/PATCH-GRAMMAR.md`** — the shared canvas grammar
and every patch-engineering fact Act I paid for.

**Renamed from VL.Cartography to VL.Overworld on 2026-08-22** (the third correction made the old
name wrong: a course that no longer starts with maps cannot be called cartography). The rename is
complete — folder, repo, nuspec, memory junction — and the smoke test passed the same day.

**The memory directory for this project is a junction onto the shared one** — literally the same
files a session in `vl-mapsui` or `vvvv-gis` sees, so everything learned in any of the four
repositories is already loaded. Keep it that way. Do not write a second copy of something a
repository already records: a memory that drifts out of date is worse than no memory, and this
family has been bitten by exactly that (a memory saying "Mapsui is blocked" survived months after
VL.Mapsui was working, and cost a round of wrong reasoning before anyone checked).

### Where the work stands — 2026-08-22

**2026-08-22, evening: the spine now runs in two acts** — geometry (01–05: no basemap, no network,
no files, VL.NetTopologySuite only) then maps (06–09). The map act's chapters kept their content
and hand-arranged layouts; only numbers and in-text references moved. The reasoning is
`docs/CURRICULUM.md`'s **third correction**.

| unit | state |
|---|---|
| `Tutorial 01 Your cursor is now data` (geometry act) | done — **rung 4 passed 2026-08-22**: circle follows the mouse, WKT updates live. Layout still machine-generated |
| `Tutorial 02 A dot, a path, a plot of ground` (geometry act) | done — **rung 4 passed 2026-08-22**. Layout still machine-generated |
| `Tutorial 03 In or out` (geometry act) | done — **rung 4 passed 2026-08-22**. Layout still machine-generated |
| `Tutorial 04 The shortest line between` (geometry act) | done — **rung 4 passed 2026-08-22**. First consumer of `Nearest Points`. Layout still machine-generated |
| `Tutorial 05 Grow a shape` (geometry act) | done — **rung 4 passed 2026-08-22**. First ForEach region in the pack. Layout still machine-generated |
| `Tutorial 06 Change how the world looks` | done, **arranged by hand** (was 01) |
| `Tutorial 07 Your own points, lines and polygons` | done, layout still machine-generated (was 02) |
| `Tutorial 08 The map is just giving you coordinates` | **rebuilt 2026-08-23** after the first draft reproduced the recorded `WithinCommonSpace` disappearance (vl-mapsui NOTES.md, 2026-08-14 and 2026-08-23): now `ScreenToWorld` → live Buffer circle → `Feature`/`FeatureLayer`, with a `FrameDelay` breaking the map↔geometry cycle. Rungs 1–3 passed — **rung 4 owed**. Layout machine-generated |
| `Tutorial 09 Real data` | done (was 04, and 05 before that) |
| `Prompt A mountain` | done, layout still machine-generated |

Nothing is published anywhere. Everything runs off the siblings' `dist\` folders on disk.

### The four repositories, and who is responsible for what

| repository | owns | tests | source files |
|---|---|---|---|
| `D:\2026_Projects\vl-mapsui` | drawing maps: tiles, layers, styles, picking, widgets | **225** xunit | 30 |
| `D:\2026_Projects\vl-nettopologysuite` | geometry **and the feature model**: create, inspect, operate. Category `NTS` | **85** xunit | 10 |
| `D:\2026_Projects\vl-geojson` | reading and writing GeoJSON. Category `GeoJSON` | **69** (+4 skipped) | 9 |
| **here** | the course. **No nodes, no assembly, no `src\`** | none, and none is wanted | 0 |

**The division that matters: a missing or broken NODE is never fixed here.** If a chapter cannot be
written because a node does not exist or misbehaves, the work belongs in the library that owns it,
with a test there — and this repository's job is to have found it. Writing a workaround in a patch
would hide the finding, which is the one thing this pack exists to prevent. Five defects have gone
that route in two days; see the section below.

They compose through **NetTopologySuite**, a library they share rather than an agreement they made.
None references another, deliberately.

**2026-08-22: the `Feature`/`Split` nodes moved from VL.Mapsui to VL.NetTopologySuite**
(`NTS.Feature`), because a feature — geometry + attributes — is a data-model object that must be
constructible without a map engine; every standard and every geometry core in the field layers it
that way, and Mapsui itself converts into its own scene feature at the boundary. The evidence and
the costs are recorded in vl-nettopologysuite's `docs/ARCHITECTURE.md`, "Where a feature lives".
Seven help patches across two repositories were repointed (19 references); the four rungs below
were run through rung 3 the same day — **rung 4 (GUI) is still owed** for the new category.

### How each one is tested

```powershell
# the libraries - fast, no network, no vvvv. Close vvvv first: it holds the assemblies.
dotnet test D:\2026_Projects\vl-mapsui\test\VL.Mapsui.Tests\VL.Mapsui.Tests.csproj
dotnet test D:\2026_Projects\vl-nettopologysuite\test\VL.NetTopologySuite.Tests\VL.NetTopologySuite.Tests.csproj
dotnet test D:\2026_Projects\vl-geojson\test\VL.GeoJSON.Tests\VL.GeoJSON.Tests.csproj

# here - there is no unit suite, and there should not be. A course is tested by compiling it.
.\tools\Test-VLPackage.ps1                              # static: BOM, ids, links, the rules
.\tools\Compile-HelpPatches.ps1 -OutputDirectory <abs>  # every unit, headless
```

**Four rungs, and each catches what the one below cannot.** Skipping a rung is how every silent
failure in this family got in:

1. **`Test-VLPackage.ps1`** — structure. It cannot tell you a node resolved.
2. **`Compile-HelpPatches.ps1`** — exit 0 means the document **parsed**. It cannot tell you a node
   resolved either: an unimported type is dropped in silence.
3. **Read the generated C#.** This is the rung people skip. A pin fed by nothing compiles as a
   literal (`string Cache_Folder_11 = @"";`) and looks identical to a wired one from the outside.
   Check that values arrive from `__pad_…` and that process nodes are constructed in `__Create__`.
4. **Open it in vvvv and look.** Two of the five defects below were invisible to every automated
   signal — the layer rebuilt, the counters advanced, the status pins named real folders, and the
   picture did not change. **Never leave vvvv running unattended, and launch only through
   `tools\Open-HelpPatch.ps1`.** After any GUI session run `tools\Normalize-HelpPatches.ps1`.

### Known gaps in the libraries — do not rediscover these

- **`GradientTheme` is not wrapped**, so a style cannot be chosen from an attribute *value*. No
  choropleth, and no colouring points by elevation. It has now blocked two concrete things and is
  first on both the GST 101 list and the #30DayMapChallenge one. **The most valuable next library
  job.**
- **Nothing reprojects.** `SphericalMercator` is used internally and never exposed, and no
  `VL.ProjNet` exists. Area and length in lon/lat come out in degrees.
- **No image markers, no callouts, no layer opacity, no raster/DEM reading, no editing.**
- **The map layer cannot be transformed inside VL.Skia** — `PixelSpace.Draw` resets the matrix — and
  nothing produces a texture. Whether rendering the whole scene to a texture works is unmeasured.

Full list with measurements: `D:\2026_Projects\vl-mapsui\docs\MAPSUI-SURFACE.md`.

## What this is

**VL.Overworld is a course, not a library.** It contributes **no nodes**. It declares the three
libraries it teaches, and holds every patch that needs more than one of them.

| repository | what it is |
|---|---|
| `D:\2026_Projects\vl-mapsui` | draws maps: tiles, layers, styles, picking |
| `D:\2026_Projects\vl-nettopologysuite` | geometry — points, lines, polygons, operations |
| `D:\2026_Projects\vl-geojson` | reads and writes the format data arrives in |
| **here** | the chapters that use two or more of them |

The shape is copied from [VL.ExtendedTutorials](https://www.nuget.org/packages/VL.ExtendedTutorials)
and [VL.TheBigBang](https://github.com/chkw-rks/VL.TheBigBang): **no assembly, an empty entry
document, everything in `help\`, and a nuspec that declares the libraries.** ExtendedTutorials'
entry `.vl` is 1322 bytes of nothing, which is exactly right — the alternative is inventing nodes
so the package has something to contribute.

## The rule this repository exists for

> **A patch that needs ONE package belongs in that package's own `help\`. A patch that needs TWO
> OR MORE belongs here — *except* a spine `Tutorial`, which may need one package when the course's
> sequence requires it, and must say why in its own description.**

Both halves are enforced. `tools\Test-VLPackage.ps1` here fails a chapter that names only one
family package **unless its filename starts `Tutorial `**; vl-mapsui's fails a help patch that names
a foreign `VL.*` one. Neither is a convention to remember.

**The exemption exists because a course with a hole at chapter 1 is worse than a duplicated node.**
Every unit with a payoff inside five minutes — a world you can drag, a basemap you can restyle, the
longitude under the cursor — needs VL.Mapsui and nothing else. The rule was written for a
*library's* `help\`, where a foreign dependency opens red for whoever installed that library alone.
**This pack declares all three packages, so a single-package patch here is duplication, never
breakage** — a far smaller cost than sending a beginner elsewhere for lesson one, which is exactly
how the Gray Book loses people: it has no first lesson, it links out to YouTube.

The exemption is narrow on purpose. **A `Prompt` gets none.**

**Why it matters:** everything under a library's `help\` is packed, so a patch needing a package
that library does not depend on opens red for anyone who installed it alone. And the cure is never
to add the dependency — a map engine has no business requiring a GeoJSON reader. An `examples\`
folder was the first attempt and was worse: nothing there is packed, so **no user ever saw it**.

## And the second reason, which matters more

**The chapters are how the libraries get tested**, and the record is now five defects in two days,
none of which the unit suite had.

On **2026-08-16**, one cross-package patch found three that 218 tests had missed:

- `SymbolStyle` drew **0 pixels** for a polygon, silently erasing half a dataset
- the first fix stacked two styles and put a second circle on every point
- a nested `StyleCollection` rendered nothing at all — 156 px where the flat one drew 14884

On **2026-08-17**, the basemap tutorial (then `Tutorial 01`, now `06`) — whose entire lesson is
switching basemaps — found two more on its first run:

- **every tile source shared one cache folder**, so the second basemap you picked never fetched
  anything. Changing the preset appeared to do nothing while every status pin reported success
- **each switch leaked a connection pool**, because the `HttpTileSource` was rebuilt along with the
  layer and BruTile never releases one

Note the shape of all five. **Not one is an arithmetic error; every one is about composition or
lifetime** — two styles meeting, two packages meeting, two tile sources meeting one cache. A suite
organised one node at a time cannot contain them, which is an argument about test *shape* rather
than test count. The second pair also needed something the tests structurally lack: **a person
looking at the picture.** Every automated signal said the switch had worked.

**This pack is a standing integration test that happens also to teach**, which is why it has a
compile harness and is a package rather than a folder of files.

## Working rules carried from the sibling repositories

Read `D:\2026_Projects\vl-mapsui\docs\RULES.md` and `docs\VL-PATCH-XML.md` before editing a `.vl`.
The ones that bite hardest here:

1. **Opening a document in vvvv is running it.** Read the value and close. Never leave it running
   unattended, never start it in the background. **Launch only through
   `tools\Open-HelpPatch.ps1`** — this pack needs **six** package repository folders, and vvvv
   ignores a repository that does not exist, so a missing one shows up as an error naming something
   else entirely.
2. **`Enabled` is off by default** on anything that fetches. Whoever opens a chapter has not agreed
   to anything yet; OSM's tile policy is a real constraint, not etiquette.
3. **A `.vl` is UTF-8 with BOM**, every `Id` exactly 22 characters starting `[A-V]`, unique within
   its document. `tools\New-VLId.ps1` generates them — never derive one by editing a character.
4. **Multi-step `.vl` edits go in a script FILE, not an inline command block.** An inline
   here-string terminator with an argument after it wrote PowerShell source into a patch on
   2026-08-16; the XML still parsed, `vvvvc` still compiled it, and only the validator noticed.
5. **Validate before committing, in a separate step.** A check whose result arrives after the push
   is not a gate.
6. **NOTES.md is the failure log, and it is read BEFORE composing, not after failing.** This file
   and PATCH-GRAMMAR.md record what works; the siblings' NOTES.md record what was tried and how it
   died — and rungs 1–3 cannot catch a recorded dead end, because parse-and-resolve says nothing
   about pixels. Tutorial 08's first draft rebuilt one (2026-08-23); the rule and the two
   sanctioned map-act directions are in `docs/PATCH-GRAMMAR.md`, "The map act".

## Before adding a unit, read `docs/CURRICULUM.md`

**The order is derived, not invented — and it has been corrected twice.** The first outline was
invented outright. The second was derived from FOSS4G GeoAcademy's GST 101 and still put a
vocabulary lesson at the door, because GST 101 is a graded university course and its reader cannot
leave. `docs/CURRICULUM.md` carries the sources, their licences, the evidence, and both corrections.

Four things from it that constrain the work:

- **GST 101 is the coverage checklist, not the sequence.** It answers "do we teach what the field
  considers core?" It does not name or order the units.
- **Name a unit by what the reader ends up with; put the concept in the subtitle.** The evidence is
  in-community and free: VL.TheBigBang opens on `Explanation 01. Types and IOBoxes` and renders
  nothing until chapter 8 of 45; the NODE Institute's paid beginner class opens on "create your
  first visual compositions" and is in 3D by session 2.
- **Only [FOSS4G GeoAcademy](https://github.com/FOSS4GAcademy) may be borrowed from as text** —
  CC-BY 3.0, attribution required. QGIS Training Manual is CC BY-**SA** and would spread share-alike
  into our MIT patches; Geocomputation with R is CC-BY-**NC-ND** and may only be cited.
  **The 30DayMapChallenge's licence is unverified** — its day *names* are used as evidence here, but
  check before any prompt description reaches a shipped patch.
- **A unit with no source is allowed but must say so.** Several prompts have none, because a desktop
  GIS has neither a frame loop nor a cursor to ask. A stated decision, not an accident.

## Two tiers, and the filename says which

```
help\Tutorial 01 ….vl     the spine. Ordered, numbered, each adds exactly one capability
help\Prompt ….vl          unordered, unnumbered, skippable, no prerequisites
```

**Numbering is a claim that order matters, so it is spent only on the spine.** Number everything and
the numbers become noise, and a reader arriving at unit 05 feels late — when the entire point of the
prompt tier is that they are not. [The Coding Train](https://thecodingtrain.com/tracks) says the same
in its own words: Main Tracks "you can follow like a course syllabus", Side Tracks "don't necessarily
need to be watched in order".

A **prompt** is phrased as a permission, not an instruction: a material restriction ("two colours
only") or a subject ("out of this world"), never "learn X". Tone from Genuary — *"You don't have to
follow the prompt exactly. Or even at all."*

The prefixes extend vvvv's existing `Explanation` / `HowTo` / `Example` convention, which is already
three-quarters of Diátaxis. `Tutorial` is the genre Diátaxis says those three are missing.

`Help.xml` carries the tags and groups the units into the two tiers, and the validator checks it
against the disk in both directions.

## The dev loop, and the one step that is not optional

Nothing is published. Every node a chapter uses comes off a sibling's `dist\` folder on disk, so
the loop never touches nuget.org:

```
1. close vvvv                        build refuses while it holds the assemblies, and says so
2. change a library -> run THAT library's .\pack.ps1
3. here:  .\tools\Compile-HelpPatches.ps1      <- the integration test
4.        .\tools\Open-HelpPatch.ps1 "name"    -> read -> close
```

**Step 2 is mandatory, and the reason is not obvious.** Every package sits at `0.0.1-alpha` and the
version never changes during development. **NuGet sees a matching version, uses its cache, and
never looks at the feed** — so a library you just rebuilt is silently ignored and you spend half an
hour debugging yesterday's code. All three siblings' `pack.ps1` evict the stale copy from both
`%USERPROFILE%\.nuget\packages` and vvvv's `package-cache`; skipping `pack.ps1` is what reopens the
hole.

**Step 3 is why this pack is worth its weight.** Change a pin name in a library and the compile
here goes red — `VisibleRange doesn't have a pin called "Result"` is a real one from 2026-08-16.
A library's API cannot move without a chapter telling you.

### When to publish

`VL.NetTopologySuite` and `VL.GeoJSON` depend on nothing of ours; `VL.Mapsui` depends on
VL.NetTopologySuite; this pack depends on all three. **Publish in that order or an install fails.**

**But not yet.** A published version is permanent — nuget.org cannot delete, only unlist, and this
family already spent a day on the consequences of one published alpha (`VL.GIS 0.2.0-alpha`, which
declares BruTile 6 and breaks VL.Mapsui; the fix exists in source and was never published). Mean-
while the same `0.0.1-alpha` gets repacked a dozen times a day here, which is flatly incompatible
with permanence.

The signal to publish is **the node surface going a week without moving**, plus enough chapters to
learn from. Until then `Test-Install.ps1` in each library already simulates a real install locally:
NuGet resolves the real dependency graph into a temp folder, and the help patches are compiled
**from the installed package**.

This repository has no `build.ps1` or `pack.ps1` yet — there is nothing to compile. One is needed
before it can be published; `nuget pack VL.Overworld.nuspec` has been verified by hand to produce
the right contents.

## Commands

```powershell
# validate: BOM, ids, references, the cross-package rule, Help.xml, the nuspec
.\tools\Test-VLPackage.ps1

# the real test - compiles every chapter against all three siblings' packages.
# Needs each sibling's pack.ps1 to have run first.
.\tools\Compile-HelpPatches.ps1 -OutputDirectory <abs-dir>
#   exit 0 means the document PARSED. Read the generated C# to see the nodes RESOLVED.

# open one, read it, close it
.\tools\Open-HelpPatch.ps1 -List
.\tools\Open-HelpPatch.ps1 "Drawing GeoJSON"

# or without a command line: double-click Open-Chapter.cmd in the repository root.
# A window lists the chapters; Open goes through Open-HelpPatch.ps1 (same gate, same
# refusals, printed in the log box), and a second button runs Normalize afterwards.

# after any GUI session - vvvv repins dependency versions and saves Enabled=True
.\tools\Normalize-HelpPatches.ps1
```

`tools\Get-PackageRepositories.ps1` is the single source of truth for the six repository folders
and three feeds. Both other scripts read it. It exists because that list was written out twice next
door and cost two launches.

## Assets

Every file in `help\Assets\` gets a row in `THIRD-PARTY-NOTICES.md` **before** it is committed.
Geographic data almost always carries a licence, and several require attribution wherever the data
is *shown* rather than merely redistributed — which is a working constraint on anyone building a
map, and part of what chapter 09 teaches.

## The checked-in `.vl` is the source of truth. Never regenerate one.

The basemap tutorial (now `Tutorial 06`) was first *generated* — a script derived it from vl-mapsui's
`HowTo Drive the map with the mouse.vl`, deleting and rebuilding the file each run. That was the
right way to get a patch that compiles. **It stopped being right the moment the patch was arranged
by hand**, on 2026-08-18, and re-running that script now would silently destroy the arrangement.

This reverses nothing; it is the rule vl-mapsui already carries, arriving here for the same reason:

> Regenerating turned out to be the more destructive of the two once a patch was in use: it
> discarded a layout arranged by hand in the GUI.

So: **edit in place, and validate every edit** — anchor each change on a match that occurs exactly
once and fail loudly otherwise, then check ID legality and uniqueness, dangling link endpoints, the
BOM, an XML parse, `tools\Test-VLPackage.ps1`, and a `vvvvc` compile.

### What the hand-arranging changed, and why it is worth preserving

Reading the diff taught two things a generator would not have produced:

- **Things that belong together go on the same rows.** The six basemap URLs and their six credits
  now sit in two columns at the same six vertical positions, so "this credit belongs to that
  basemap" is something the eye establishes. The generated version had them 700 units apart because
  the strings are long — which hid the one design rule the chapter exists to teach.
- **A short label next to a control beats a paragraph about it.** The long explanation stayed, moved
  aside into a tall column; what got *added* was two one-line labels — an arrow beside the `Basemap`
  knob, and "if you don't have a scroll wheel, click here" beside the zoom buttons. Nobody opening a
  patch reads sixty lines first. They do read the label touching the thing they are about to click.

Generated patches run. Arranged patches get read. **A chapter has to do the second.**
