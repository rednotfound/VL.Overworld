# Globe Package Scope Proposal — 2026-11-09

The globe research of 2026-11-09 ([GLOBE-RESEARCH.md](GLOBE-RESEARCH.md)) ended with a ladder,
and the lab climbed three rungs of it the same day, all rung-4 verified ([ACT-IV-LAB.md](ACT-IV-LAB.md),
experiments 5–7): a Mapsui map wrapped on a sphere; 64 tiles as 64 patches meeting without a
seam; the camera's height and direction choosing which tiles, at which zoom, to request. Every
rung was a patch, with zero library change — which is the lab's rule, and also its limit. What the
patches cannot do is the *engine*: select by frustum, cache by tile number, refine by screen-space
error while keeping parents until children arrive, and count what was asked for. The family's
rule for an engine is a `[ProcessNode]` in a library, with tests, after a scope proposal.

This is that proposal. **It is a proposal; the decision is the user's**, and the open points are
marked ⊙. Where the network proposal of 2026-08-28 could promote in place, this one cannot: the
globe has no package to be promoted inside.

## 1. Location — a new repository, `vl-globe`

The alternatives, and why not:

- **Inside VL.Mapsui.** Mapsui is not in the globe at all: experiments 6 and 7 fetch with
  `HTTPGet`, decode with Skia, draw with Stride. Mapsui's maintainer has said the library will
  stay 2D (issue #911). Putting a Stride dependency on VL.Mapsui would make every 2D map chapter
  load a 3D engine, and would say the globe is "a Mapsui thing", which the evidence contradicts.
- **Inside VL.Overworld.** The course has no `src\` by design — "no nodes, no assembly" is the
  rule its validator enforces, and the reason it can find library defects instead of hiding them.
- **Inside VL.NetTopologySuite.** The globe uses one NTS type (`Coordinate`, for the bridge in §3)
  and nothing else of geometry. The network proposal's own paragraph said the *second* algorithm of
  ours wanting a home reopens the location question; this is it, and the answer is that a tile
  engine with a Stride dependency is not an algorithm over NTS types.

So: a fifth repository, `D:\2026_Projects\vl-globe`, with the siblings' tooling copied (pack.ps1,
Test-VLPackage, Test-Install, a `help\` that is junctioned into `dist\`, NOTES.md as the failure
record). The dependency arrows stay as the family draws them: VL.Globe → VL.NetTopologySuite (for
`Coordinate`), VL.Globe → VL.Stride, VL.Globe → BruTile; nothing of ours depends on VL.Globe, and
VL.Globe does not depend on VL.Mapsui.

## 2. Identity — ⊙ the name, and the category

Measured on nuget.org, 2026-11-09, among community packages that depend on VL.Stride:

| pattern | examples | count |
|---|---|---|
| host-prefixed `VL.Stride.X` — "nodes to create and render X in VL.Stride" | Text3d, BezierPatch, SDFToMesh, Voxels, glTF, OpenXRExtensions, DX12Bridge | 7 |
| domain-named `VL.X`, Stride as a dependency | Fuse, HapPlayer, Boids-GPU, Fresnel, Nurbsy, OpenEXR, PDFReader | 7 |
| renderer-suffixed `VL.X.Stride` — a core plus a Stride backend | ImGui, CEF, Avalonia | 3 |

Neither `VL.Globe` nor `VL.Earth` exists on nuget.org.

⊙ **Proposed: `VL.Globe`**, category `Globe`, repository `vl-globe`. The reasons, in order:

1. The family names a package after what you get, not after what it is built on: `VL.Mapsui` is
   the flat map, `VL.Globe` is the globe. The course's own rule for a unit — "name it by what
   the reader ends up with" — says the same.
2. The host-prefixed pattern fits a *primitive* added to Stride (a text mesh, a bezier patch).
   A globe is a domain with its own objects (tiles, zoom, a coordinate system), of which the
   mesh is one part; VL.Fuse, the largest Stride-dependent community library, chose the domain
   name for the same reason.
3. The renderer-suffixed pattern is for a core that can have two backends. The quadtree, the
   cache and the coordinate maths *are* renderer-independent, so `VL.Globe` leaves
   `VL.Globe.Skia` possible later (a flat debug view of the same tile selection) — whereas
   `VL.Stride.Globe` would close that door in the name.

The alternatives stay on the table: **`VL.Stride.Globe`** if the user reads the globe as "a
Stride primitive"; **`VL.Earth`** if the package is expected to grow terrain and atmosphere (the
word promises more than tiles; `Globe` promises exactly a sphere with a map on it, which is what
exists). Not proposed: `VL.Overworld.Globe` (a library must not be namespaced under the course that
found it) and `VL.Mapsui.Globe` (§1).

The process node is **`Globe [Globe]`**, on the precedent of `Map [Mapsui]`: the thing you get,
in the category named after the package.

## 3. Surface — what the three experiments asked for, and nothing they did not

Every pin below was wired by hand in experiments 5–7 or was the thing a patch could not do.
Nothing is added on the chance it might be wanted; the network proposal's rule — a consumer has
to have asked — applies.

### Phase 1 — what the lab proved and what it could not do

| node | pins | why |
|---|---|---|
| **`Globe [Globe]`** `[ProcessNode]` | in: `Tile Source`, `Camera` (the Stride camera entity, read for position and frustum), `Enabled` (default **false** — consent, as everywhere in the family), `Radius` (default 1, the unit sphere), `Max Zoom` (default 18), `Screen Space Error` (pixels, default 2 — Cesium's default), `Max Requests In Flight` (default 6), `Cache Folder` ; out: `Entity` (one Stride entity whose children are the visible tile meshes), `Tiles Visible`, `Tiles Loading`, `Requests Sent`, `Bytes Received`, `Attribution` | the engine the three experiments could not be: frustum selection, refinement by screen-space error with parents kept until children arrive, a cache keyed by tile number (memory, then the disk folder), a request budget. The four counters are Act IV's numbers as pins — the tile ledger, live |
| **`OpenStreetMap [Globe]`** and **`XyzTiles [Globe]`** | as VL.Mapsui's nodes of the same names: URL template, attribution text, `User Agent`; out: `Tile Source` (BruTile's `ITileSource`) | the globe needs a source, and the course's consent and attribution conventions must hold here exactly as on the flat map. ⊙ see §6 on sharing |
| **`ToGlobe [Globe]`** | in: `Longitude`, `Latitude`, `Height` (metres above the sphere, default 0), `Radius`; out: `Position` (Vector3). An overload taking an NTS `Coordinate` | the Coordinate → Vector3 bridge the course has wanted since 2026-09-24 ("the 3-node Coordinate↔Vector2 motif recurs in nearly every patch"), now with a third axis and a reason: putting an NTS point on the globe. Longitude/latitude are Float64; the output is the Float32 Stride wants |
| **`FromGlobe [Globe]`** | in: `Position` (Vector3), `Radius`; out: `Longitude`, `Latitude`, `Height` | the inverse; experiment 7 computed it by hand from the camera position with `Atan2`/`Asin` — eleven nodes that are one |

Implementation notes that are decisions:

- **Tile meshes are built on the CPU in C#**, a 9 × 9 grid per tile with vertices on the sphere,
  rows linear in Mercator y (MapLibre's layout, experiment 6's shader moved to the CPU). No
  material extension, no vertex shader: the shader was the right tool for a patch that could not
  build meshes; a library can, and a CPU mesh is testable without a GPU (vertices on the sphere to
  1e-7, adjacent tiles sharing edge vertices exactly — the seam test).
- **Textures are decoded by Stride** (`Image.Load` reads PNG and JPEG), so the library does not
  depend on VL.Skia.
- **The globe is a unit sphere** scaled by `Radius`. Float precision at Earth's real radius (0.5 m
  steps) is not a problem a globe view has; when a consumer descends to street level the answer is
  relative-to-centre rendering or a handover to the flat map, and that consumer reopens the
  question with its numbers.
- **BruTile is pinned to the version VL.Mapsui already carries** (5.0.6 today), because both will
  live in one vvvv process and NuGet unifies to one assembly; the two packages move BruTile
  together or not at all.

### Phase 2 — plausible, not proposed

Named now so the phase-1 surface cannot creep toward them, each waiting for a consumer:
`Pick [Globe]` (a ray from the mouse to longitude/latitude — the globe's `ScreenToWorld`),
vector data on the globe (NTS geometry as lines on the sphere; or Mapsui rendering vector tiles
into textures, which is where the flat library would re-enter), terrain (experiment "How high is
here" already decodes Terrarium tiles; on a tile mesh that is vertex displacement), a graticule.

## 4. The scope sentence

> **VL.Globe draws Web Mercator raster tiles on a sphere in Stride, requesting only the tiles the
> camera can see at the zoom its distance earns, and converts between longitude/latitude and
> positions on that sphere.** It fetches nothing until told to, caches by tile, and reports what it
> asked for.

## 5. Non-scope, stated now

- **No reprojection.** Tiles are Web Mercator; the sphere is the one surface they map onto
  without a projection library. Other tile schemes are a later source node, not a globe change.
- **No terrain, no 3D Tiles, no glTF.** The research doc's stage 3 — cesium-native bindings on
  .NET 10, quantized-mesh, `VL.Stride.glTF` — is a different family member with its own proposal.
- **No vector tiles, no labels, no styling.** The globe draws pictures someone else drew.
- **No 2D.** The flat map is VL.Mapsui; Mapbox's own move is to hand over from the globe to the
  flat map above zoom 6, and the course can teach that handover with two packages it has.
- ~~**No camera.** `OrbitCamera` is vvvv's; the globe reads a camera, it does not provide one.~~
  **Withdrawn 2026-11-09 by the user, after using the built globe** — see §9.

## 6. What the proposal touches, and ⊙ two sharing questions

| where | what |
|---|---|
| new `vl-globe` | the five nodes above, xunit tests for selection (a camera pose in, a tile set out — pure maths), cache (hit, miss, eviction, the disk folder), request budget, mesh geometry and seams; `help\`: `HowTo Put OpenStreetMap on a globe` (`Enabled` off), `HowTo Place a point on the globe` (ToGlobe with an NTS point) |
| vl-overworld | `lab\Experiment globe view.vl` becomes the first consumer and the rung-4 test of the engine (the same camera poses, the same two pictures, now with `Tiles Visible` and `Requests Sent` on screen); GLOBE-RESEARCH.md stage 2 marked "library"; the nuspec gains the fourth package when a chapter uses it — not before |
| vl-mapsui | nothing, unless ⊙ below |
| the shared memory | `package-family-state` gains the fifth member and its dependency arrows |

⊙ **Sharing the tile-source nodes.** `OpenStreetMap` / `XyzTiles` would exist twice, once per
package, ~60 lines each, with identical pins. The family's precedent is to accept small
duplication rather than a cross-dependency (the `Feature` nodes moved *down* to NTS precisely so
nobody would depend sideways). The alternative — VL.Mapsui exposing BruTile `ITileSource` nodes
that both packages consume — would make VL.Globe depend on VL.Mapsui for two nodes and pull the
2D library into every globe. **Proposed: duplicate**, and write in both ARCHITECTURE.md files that
the two must agree on pins and consent behaviour.

⊙ **Sharing the disk cache.** VL.Mapsui's `TileCache` keeps a folder per source. If VL.Globe uses
the same folder layout (BruTile's `FileCache` naming), a tile fetched for the flat map serves the
globe without a second request — zero code shared, one convention shared. **Proposed: same
layout**, documented in both.

## 7. Decision record

| ⊙ | proposed | alternatives |
|---|---|---|
| name | `VL.Globe`, category `Globe`, repo `vl-globe` | `VL.Stride.Globe`; `VL.Earth` |
| phase-1 surface | `Globe`, `OpenStreetMap`, `XyzTiles`, `ToGlobe`, `FromGlobe` | fewer: drop the source nodes and take a URL string on `Globe` (one node less, but then the consent and attribution conventions live in a pin instead of a node, unlike the flat map) |
| tile sources | duplicated from VL.Mapsui, pins agreed in both ARCHITECTUREs | VL.Mapsui exposes `ITileSource` nodes; VL.Globe depends on it |
| disk cache | BruTile `FileCache` layout, shared folder convention | separate folders |
| meshes | CPU, 9 × 9 per tile, tested | the lab's vertex shader, kept |
| first consumer | `lab\Experiment globe view.vl`, rebuilt on the node | a new chapter first |

Decided: **2026-11-09, by the user** — `D:6_Projectsl-globe` created (empty, not yet
`git init`), name `VL.Globe` accepted by the folder name; the other ⊙ rows stand as proposed until
the first build contradicts one.

**Built the same day (2026-11-09), commits c5bb63c..a07e9ec in vl-globe:** all five phase-1 nodes; 37 tests; two help patches through all four rungs (`ToGlobe` puts Tokyo at the centre of a camera aimed there; `Globe` draws zoom 9-10 OSM over Gabon and the whole face of Africa, 0.27 cores). Three failures, recorded in vl-globe's NOTES.md: Stride's module initializer in the test assembly; OrbitCamera's pose lives in its custom view matrix, not its transform; coarse facets sagging plus a tiny near plane making a background sphere z-fight. Not yet: `XyzTiles` help, `Pick`, polar caps, the lab's `Experiment globe view.vl` rebuilt on the node.

## 8. What the first build needs — verified 2026-11-09, before the usage limit cut the session

Facts gathered for the build so the next session starts at the keyboard, not at the research:

- **Reaching the Stride device from a C# node**: `VL.Stride.Runtime`'s own `SkiaTexture.cs` does
  `game = nodeContext.AppHost.Services.GetRequiredService<VLGame>()` (`VL.Stride.Games.VLGame`) in
  the constructor and `game.GraphicsDevice` at use. Copy that; no other handle is needed.
- **Project shape** (measured on `VL.Stride.glTF`, the closest community precedent): net8.0 here
  (vvvv 7.4 → Stride **4.2.1.2487**; glTF's net10/4.3 is gamma 8), `PackageReference` to
  `Stride.Engine`, `Stride.Games`, `Stride.Graphics`, `Stride.Rendering`, `Stride.Core.Mathematics`
  at 4.2.1.2487 and `VL.Core` 2025.7.4 with `ExcludeAssets="runtime"` as vl-mapsui does; plus
  `BruTile` **5.0.6** (VL.Mapsui's version — one assembly per process). The root `VL.Globe.vl`
  declares `NugetDependency` `VL.CoreLib`, `VL.Stride`, `BruTile`, `VL.NetTopologySuite`, and
  `PlatformDependency Location="./lib/net8.0/VL.Globe.dll" IsForward="true"`. The nuspec lists
  only BruTile and VL.NetTopologySuite as dependencies: VL.Stride ships inside vvvv.
- **Skeleton**: copy vl-mapsui's `build.ps1`, `pack.ps1`, `NuGet.config`, `.gitignore`, `LICENSE`,
  `tools\` and the test csproj shape, renaming the package; `Compile-HelpPatches.ps1` carries a
  per-package node table (15 Mapsui mentions) that must be rewritten for the five nodes;
  `Open-HelpPatch.ps1` names dist\ and deps\ (5 mentions). build.ps1 installs every non-`VL.*`
  `NugetDependency` of the root .vl into `deps\` — for this package that is BruTile only.
- **Tile sources, as VL.Mapsui builds them**: `new HttpTileSource(new GlobalSphericalMercator(),
  url, name:, attribution: new Attribution(text), userAgent: UserAgent)`; one source instance kept
  per URL (an `HttpTileSource` owns an `HttpClient` and is not disposable); `PersistentCache` set on
  every build. Fetch with `GetTileAsync(TileInfo)` → `byte[]`.
- **Disk cache convention to share with VL.Mapsui**: `%LOCALAPPDATA%\VL.Mapsui	iles\<host>-<sha256
  of the lowercased URL, first 8 hex>` as a BruTile `FileCache(folder, "png", 7 days)`. VL.Globe
  reads and writes the same folders, so a tile either package fetched serves both; the user-agent
  string is its own (`VL.Globe/0.0.1-alpha (+repo url)`).
- **Stride API for the tile mesh**, present in 4.2.1: `Buffer.Vertex.New<T>(device, T[])`,
  `Buffer.Index.New(device, int[]/short[])`, `MeshDraw` + `Mesh` + `Model` + `ModelComponent`;
  `Material.New(device, new MaterialDescriptor { Attributes = { Emissive = new
  MaterialEmissiveMapFeature(new ComputeTextureColor(texture)) } })`; `Texture.Load(device,
  stream)` for PNG/JPEG. Camera: `entity.Get<CameraComponent>()` → `ViewMatrix`,
  `ProjectionMatrix`, `Frustum`, `VerticalFieldOfView`; position from
  `entity.Transform.WorldMatrix.TranslationVector`.
- **Order of work**: `git init` + skeleton → `ToGlobe`/`FromGlobe` + tests (an afternoon, proves
  the pipeline end to end through pack.ps1 and a one-node help patch) → tile mesh generator + seam
  tests → `Globe` selection + cache + requests → rebuild `lab\Experiment globe view.vl` on it and
  compare with `lab\Assets\globe-view-zoom5.png` / `-zoom9.png`. Then: create `vl-globe` from the siblings' tooling, write
ARCHITECTURE.md with this document's §3–§5 as its first version, build `Globe` against the two
camera poses of experiment 7 until the pictures match, and only then look at a chapter.

## 9. Revision — 2026-11-09: the globe needs a geographic camera (decided by the user)

**The evidence.** The user opened `HowTo Put OpenStreetMap on a globe` and drove it with vvvv's
`OrbitCamera`. In GIS, people drag the *map*, not the camera. OrbitCamera rotates by fixed angles
and approaches by fixed distances and does not know where the ground is: once close, a small drag
moves the view across a continent, and a little more wheel goes through the surface. Every web
globe (Cesium's `ScreenSpaceCameraController`, MapLibre/Mapbox globe, Google Earth) spends most
of its interaction code on exactly this: the camera cannot go underground, and the speed of zoom
and pan follows the height. §5's "no camera" was written before anyone had used the globe; using
it is the evidence that withdraws it. The user decided the same day: amend, then build.

**The design follows the family's own 2D precedent.** VL.Mapsui keeps interaction in the patch:
`Map` holds the state, `Drag` and `ZoomByWheel` take pixel positions the patch wires from a mouse
node, and nothing reads the mouse behind the reader's back. The globe mirrors it one-to-one:

| node | pins | rule |
|---|---|---|
| **`GlobeCamera [Globe]`** `[ProcessNode]` | in: `Initial Longitude`, `Initial Latitude`, `Initial Height` (metres), `Min Height` (default 100 m), `Max Height` (default 4 earth radii), `Radius`, `Viewport Size`, `Field Of View`; out: `Camera` (a Stride entity for SceneWindow and Globe), `View` (the state, for Drag/ZoomByWheel), `Longitude`, `Latitude`, `Height` | the state is **geographic** — the point looked at, the height above it, heading, tilt — never a free 3D pose, so going underground is impossible by construction rather than corrected afterwards. **Near and far planes follow the height**, which also removes the depth-precision failure in vl-globe's NOTES.md (a fixed 0.0001 near plane resolving only ~0.0025 at globe distance) |
| **`Drag [Globe]`** | in: `View`, `X`, `Y` (pixels), `Dragging`; out: `View` | **grab the globe**: the point under the cursor at press stays under the cursor — a ray from the pixel hits the sphere, and the camera rig is rotated about the globe's centre by the rotation that brings the current hit back to the grabbed one. Pan speed follows the height by itself |
| **`ZoomByWheel [Globe]`** | in: `View`, `X`, `Y`, `Wheel Delta`, `Notch Size`; out: `View` | **zoom toward the cursor, by a factor**: each notch multiplies the height (about one zoom level), clamped to Min/Max Height, and the point under the cursor is kept there by the same rotation as Drag — VL.Mapsui's `ZoomByWheel`, on a sphere |
| `Tilt [Globe]`, `Rotate [Globe]` | phase 2 | heading and tilt as separate gestures, tilt limited and reduced at altitude — after the two above are right |

**Invariants the tests pin**, all pure maths with no GPU: after a Drag frame the geographic point
under the cursor is the grabbed one; after a zoom the point under the cursor has not moved; no
input sequence takes the height below Min Height or above Max Height; a cursor off the globe does
not move the camera; the near plane is a fixed fraction of the height.

**The scope sentence gains one clause:** *…and moves a camera around it the way a map is moved —
grabbed, and zoomed toward the cursor.* Non-scope stays otherwise: no inertia, no keyboard, no
fly-to animation until a consumer asks.

**Touches:** vl-globe gains the four nodes and their tests; both help patches swap `OrbitCamera`
for `GlobeCamera` + `Drag` + `ZoomByWheel`, wired from a mouse node as VL.Mapsui's help patches
are. Formulas are checked against Cesium's and MapLibre's source before they are written
(research running 2026-11-09).
