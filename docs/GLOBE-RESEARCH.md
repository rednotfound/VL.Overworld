# From a flat map to a globe — research, 2026-11-09

The question: VL.Mapsui draws a 2D map. Can that map be wrapped onto a sphere inside vvvv's
Stride engine, as the first step toward a real 3D world? What exists already, and if nothing
does, how would we build it and where does the effort go?

Surveyed in one afternoon: the .NET/vvvv landscape (what could be reused), how Mapbox,
MapLibre, Cesium, deck.gl and three-globe actually wrap Web Mercator tiles onto a sphere (the
algorithms and the traps), and the concrete entry points in Mapsui 4.1.9 and VL.Stride 2025.7.4
as installed here. Everything below was verified against source, docs or the local install
unless marked *unverified*.

## The conclusion in five lines

1. **Nothing in .NET ships "tiles on a globe" as a reusable component.** Mapsui is 2D and its
   maintainer says it will stay so ("No, no plans for 3D", issue #911). vvvv has never had one.
2. **The first globe costs zero new nodes.** vvvv already ships the bridge: `SkiaTexture` turns
   any Skia layer, including Mapsui's `ToSkiaLayer`, into a Stride texture, and `DynamicMesh`
   builds a mesh from a Spread of vertices. A sphere whose rows are spaced in Mercator-y takes
   that texture with no distortion. This is a patch, not a library.
3. **That globe has a hard ceiling: about 5 km per pixel.** One texture can hold at most zoom 5
   or 6 of the world. Zooming in past that is not a bigger texture; it is a different
   architecture — one mesh patch and one texture per tile, picked by a quadtree. There Mapsui's
   renderer stops being useful; the data path becomes BruTile (tiles) and NTS (vectors) straight
   into Stride.
4. **The "pure 3D" future has one real reuse candidate**: Evergine's MIT bindings to
   cesium-native (3D Tiles, terrain, raster overlays, WGS84 maths, engine-agnostic). It needs
   .NET 10, so it waits for a vvvv that runs on .NET 10 (*unverified* here: which gamma does).
5. **Recommended path: a ladder of lab experiments, Act IV style** — each one a number and a
   picture, no new surface until a scope proposal. Stage 0 is tile-free and can be built now.

## 1. What exists (reuse survey)

| candidate | what it is | verdict |
|---|---|---|
| **Mapsui 4.1.9 / 5.x** (MIT) | 2D, SkiaSharp. Has off-screen rendering: `MapRenderer.RenderToBitmapStream(Viewport, layers, …)` and `Render(SKCanvas, Viewport, …)` — vl-mapsui's own tests already call the latter | keep as the 2D engine and as a *raster producer* for the single-texture globe. Not a globe |
| **vvvv VL.Stride 2025.7.4** (shipped) | `SkiaTexture` (Skia layer → Texture), `SkiaRenderer` (Skia drawn into a Stride scene), `ImageToTexture`, `TextureReader`, `DynamicMesh` / `DynamicMesh (Indexed)`, `SphereMesh`, material extension shaders (`_ShaderFX.sdsl` with a vertex stage), `DrawFX`. Ships `Example Layers - Day and Night Earth` (equirectangular Blue Marble on `Sphere`) and `Example World Cities` (lat/lon → sphere) | **everything stage 0 needs is already installed** |
| **BruTile 5.0.6** (Mapsui's tile lib) | `HttpTileSource(GlobalSphericalMercator, url).GetTileAsync(TileInfo)` returns the tile's bytes | the tile path for the per-tile globe (stage 2), independent of Mapsui's renderer |
| **OpenGlobe** (Cozzi & Ring, C#, MIT, 2011, .NET 3.5 + OpenTK) | the textbook *3D Engine Design for Virtual Globes* as code: ellipsoid tessellation, RTC / jitter, depth precision, clipmap terrain | reference to read, not a dependency |
| **Evergine.Bindings.CesiumNative** (MIT, nuget 2026.9, net10.0, no Evergine dependency, pushed 2026-11-09) | P/Invoke over cesium-native: 3D Tiles selection + streaming, glTF reader, raster overlays (XYZ/TMS/WMS/ion), WGS84/ECEF/ENU, credits; you supply the GPU side | **the one serious reuse candidate for stage 3.** Native dependency; "early stage" by its own README; .NET 10 only |
| **bertt (Geodan) .NET libs** (MIT, active) | `quantized-mesh-tile-cs` (Cesium terrain tiles, read+write), `b3dm-tile-cs`, `subtree`, `tilebelt-cs` | parsers for a hand-built terrain / 3D Tiles path without cesium-native |
| **SharpGLTF** (MIT) + **VL.Stride.glTF 0.1.0** (bj-rn, MIT, 2026-09) | runtime glTF into a Stride model in vvvv (gamma 8 / .NET 10; no materials/skins yet) | the mesh-tile loader for stage 3 |
| Esri ArcGIS Maps SDK for .NET `SceneView` | real globe, free Lite tier — but a UI control only; `ExportImageAsync` snapshots the visible view | cannot be composed into a Stride scene |
| NASA WorldWind .NET | dead since ~2007; Java/Web alive, not .NET | no |
| Stride community, vvvv contributions, nuget `VL.Globe/Earth/Geo` | nothing (GitHub search zero hits; forum threads only: a displacement earth in 2022, beta-era worldmap) | **the field is empty** |
| Microsoft Maps SDK for Unity | shut down 2025-03 | gone |
| Cesium for Unity / Unreal | C++ calling into C#; nothing liftable | reference only |

Full URLs in §6.

## 2. How the real globes do it (the algorithms we would copy)

Notation: λ longitude, φ latitude (radians); u,v in [0,1] tile/texture coordinates, origin
top-left (north).

**Web Mercator is spherical by definition** (OSM, Wikipedia, Cesium's `WebMercatorProjection`),
so a *sphere* is the exact surface for its tiles, not an approximation:

```
u = (λ + π) / 2π                      v = 1/2 − ln(tan(π/4 + φ/2)) / 2π
φ = 2·atan(exp(π·(1 − 2v))) − π/2     λ = 2π·u − π            |φ| <= 85.0511°
p = R · (cos φ · sin λ,  sin φ,  cos φ · cos λ)      (Stride's y-up; the same axes as SphereMesh)
```

| engine | per-tile mesh | UV | poles | globe → flat | precision |
|---|---|---|---|---|---|
| **MapLibre 5** | grid of granularity² quads, vertices linear in **Mercator** (tile) space; raster tiles 128/2^z, min 32 | UV **is** the position, no separate attribute; inverse Mercator per vertex in the vertex shader | tiles at y=0 / 2^z−1 get a sentinel row; the shader snaps it to (0,±1,0) and clamps v to 0/1 | style preset: vertical-perspective to z10, Mercator from z12 | measures the GPU's `atan(exp())` error every ~10 frames and corrects the rotation — "several hundred metres" off on some GPUs otherwise |
| **Mapbox GL JS** | 64 columns; 64/32/16 rows chosen by sin³ of latitude; rows linear in **latitude** | forward Mercator per vertex in the shader | triangle fan per zoom at 85° | `smoothstep(5, 6, zoom)` — Mercator above z6; half the earth visible | per-tile normalised ECEF (14-bit) through a denormalise matrix |
| **CesiumJS** | WGS84 ellipsoid, *geographic* quadtree; Mercator imagery reprojected onto a 2×64 strip whose rows are Mercator-spaced on the CPU ("we can't see the difference, 4× faster"); or the terrain mesh carries a per-vertex `webMercatorT` | — | n/a (geographic tiles reach the poles) | never; one engine to street level | RTC per tile (`view·center` on the CPU), logarithmic depth + multi-frustum (0.1 m – 1e8 m) |
| deck.gl GlobeView | UV sphere of radius 256 units | equirectangular | pinches | documented "no high precision above z12" | — |
| three-globe | `SphereGeometry(100, 90, 45)` + one equirectangular image | equirectangular | pinches; the seam picks a low mip | — | — |

What this says for us:

- **Rows linear in Mercator-y, UV = (u, v).** MapLibre's layout. It makes a Mercator texture map
  with zero distortion and keeps the maths on the CPU (a `ForEach` in a patch), which sidesteps
  the GPU `atan/exp` precision trap MapLibre had to build an error-measurement pass for.
  Row spacing in latitude shrinks toward the poles as cos φ; 64 rows are plenty for z <= 5.
- **Poles are caps, not texture.** Mercator stops at 85.05°. Close each pole with a fan to
  (0, ±R, 0) in a flat colour, or clamp v to 0/1 (MapLibre's trick).
- **Duplicate the seam column** (u = 0 and u = 1 as separate vertices) and either disable mips or
  clamp; the derivative discontinuity at the seam otherwise picks the lowest mip.
- **A unit sphere is enough for globe view.** Float32 spacing at 6.4e6 m is 0.5 m — 1e-7 of the
  radius, far below the 4.9 km/px of z5. Floating origin / RTC and log depth are needed only
  when the camera descends to street level with orbit and ground on screen at once. Mapbox dodges
  that by going flat at z6; MapLibre at z12; Cesium pays for it.

## 3. The entry points we have today

| what | node / API | where verified |
|---|---|---|
| Mapsui layer → Stride texture | `SkiaTexture [Stride]` — `Input (ILayer), Size (Int2, default 1280×720), Space, Clear, Clear Color, Format → Output (Texture)`; a `[ProcessNode]`, renders Skia through EGL/D3D11 into a Stride texture every frame | `VL.Stride.Windows\VL.Stride.Windows.vl`, help `Textures\HowTo Create a Texture in Skia`; used by `Example Layers - Day and Night Earth` itself |
| Skia inside a Stride scene (overlay) | `SkiaRenderer [Stride]` | help `Rendering\HowTo Overlay 3D Objects with 2D Skia` |
| CPU image → texture | `ImageToTexture [Stride.Textures]` (`IImage`, from VL.Skia `ToImage`) | `VL.Stride.Rendering.vl` |
| mesh from vertices | `DynamicMesh` — `Data, Update Buffer, Vertex Declaration (Pos3Norm3Tex2), Topology, Bounding Box, Force Update → Output`; `DynamicMesh (Indexed)`; `GenerateNormals` | help `Rendering\HowTo Dynamic Mesh` |
| ready sphere | `SphereMesh` — UV is **equirectangular** (u = λ linear, v = 0 at the north pole → 1 south); the shipped `earth_512x512.jpg` is a squashed equirectangular Blue Marble | Stride `GeometricPrimitive.Sphere.cs`; the image itself |
| vertex-stage shader | material extension `_ShaderFX.sdsl` overriding `PreTransformPosition` / `PostTransformPosition` (overriding `VSMain` crashed one user); `_DrawFX.sdsl` for a full draw shader; VL.Fuse `DisplacementFromVectorFunction` + `ApplyDisplacement (Material)` | help `ShaderFX\HowTo Extend a Material with Custom Tessellation` (`TessSphere_ShaderFX.sdsl`); forum |
| Mapsui off-screen, no UI | 4.1.9: `MapRenderer.RenderToBitmapStream(Viewport, layers, Color? bg, float pixelDensity, widgets, RenderFormat)`; `Render(SKCanvas, Viewport, layers, widgets, bg)`; `Viewport(centerX, centerY, resolution, rotation, width, height)` is a plain record. The renderer never fetches: data must be in the layers' caches first (`RefreshData`, wait on `Busy`) | the DLL in the nuget cache; vl-mapsui `AttributionRenderingFacts.cs:47` |
| Mapsui and projections | `Map.CRS` is a label used only to reproject *vector* providers (4326/3857/3395 built in). **"Mapsui does not reproject raster images such as tiles."** An equirectangular world from OSM tiles does not exist — hence the Mercator-spaced mesh above | Mapsui docs, `Projection.cs` |
| a tile without Mapsui | BruTile 5.0.6 `HttpTileSource(new GlobalSphericalMercator(), url, …).GetTileAsync(tileInfo)` with `TileIndex(col, row, level)` | BruTile source |

Two caveats carried from the forum: `SkiaTexture` ignores Skia blend modes, and older builds
had a colour-space mismatch (hence the sRGB `Format` pin). Both are rung-4 things: look at the
picture.

## 4. The ladder

Every rung is one experiment with a number and a picture, in `lab\` first (unpacked, unvalidated
by the chapter rules, on purpose — the Act IV way). No permanent capability without a scope
proposal. Every rung needs VL.Stride, which is not a family package; that is fine for `lab\`
and is the first question a scope proposal must answer.

### Stage 0 — the snow globe: no tiles, no network, no new code

**Built and seen the same afternoon (2026-11-09):** `lab\Experiment globe.vl` +
`lab\shaders\MercatorUV_ShaderFX.sdsl`, picture in `lab\Assets\globe-stage0.png`, record in
`ACT-IV-LAB.md` experiment 5. Continents in place and unmirrored, parallels evenly spaced on the
sphere, 0.4 cores / 8 % GPU / 851 MB while running. The plan below is what was built, with one
change: the remap went into a ten-line ShaderFX node on Stride's own `Sphere` instead of a
CPU-built `DynamicMesh` — fewer nodes, the shipped `HowTo Custom Texture Sampling` as the
template, and forward Mercator (`log(tan())`) per pixel is harmless at 10 km/px.

A Mapsui map of what the course already owns — `Assets\countries-population.geojson` through
`FeatureLayer` + `StyleByValue`, plus `Graticule` — rendered by `ToSkiaLayer` with its `Map`
navigated to the **whole world square** (centre 0,0; resolution = 40 075 016.68 m divided by the
texture size in px). `SkiaTexture` at 4096² takes that layer. A `ForEach` over a 64 × 128 grid
builds the vertices: v linear, φ from the inverse-Mercator formula, UV = (u, v);
`DynamicMesh (Indexed)`; `GenerateNormals`; pole caps as two fans. A PBR or unlit material,
`OrbitCamera`. The course's own 1.1 move again — the same data, changing only the canvas, this
time from a plane to a sphere.

What it measures: that the bridge works at all (the CLAUDE.md gap "whether rendering the whole
scene to a texture works is unmeasured" closes); the per-frame cost of `SkiaTexture` re-rendering
a 4096² map (in-patch `Stopwatch`, per the frame-time memory) — if it is high, the answer is a
render-once node (`RenderToBitmapStream` → `ImageToTexture` on change), which is a vl-mapsui
scope question, not a patch workaround; and the seam, pole and colour-space traps on a real GPU.

### Stage 1 — tiles on the snow globe, consent on

`OpenStreetMap` + `TileCache` under the same layer, `Enabled` off by default as everywhere. The
whole world at one zoom is 4^z tiles: z3 = 64, z4 = 256, **z5 = 1024 tiles** — a third of
everything this course has ever fetched, in one go (the tile ledger stands at 3,422). z4 at
4096² is the honest default; z5 at 8192² is the ceiling (16384² is a 1 GiB texture). Ground
resolution at the equator: z4 ≈ 9.8 km/px, z5 ≈ 4.9 km/px.

What it measures: the ceiling. Zoom the camera in and the globe goes soft — *resolution is part
of access*, Act IV's own thesis, now in 3D. That picture is the argument for stage 2 and the
reason stage 2 is not "a bigger texture".

### Stage 2 — one patch per tile (the real globe)

MapLibre's architecture in VL: a quadtree over z/x/y; for each visible tile, a small mesh
(grid linear in tile space, inverse Mercator on the CPU, UV = local tile coordinates) and its
own texture from BruTile's bytes (`ImageToTexture`); LOD by screen-space error (Cesium's
`geometricError × screenHeight / (distance × sseDenominator)`, refine above ~2 px); parents
drawn until children arrive; pole caps; the cache and the consent gate as before. Camera: unit
sphere, no RTC — and either stop at z ~10–12 or hand over to the 2D map (Mapbox's move), which
this family already has.

This is where Mapsui's renderer leaves the picture. The globe draws raster tiles and NTS
geometry (`Coordinate` → sphere point is one node away) directly in Stride. It is a **new
library**, not a patch, and the shipped convention for one library with two renderers is
`VL.ImGui` / `VL.ImGui.Skia` / `VL.ImGui.Stride` (all three are in this install). Whether it is
`VL.Mapsui.Stride` (shares BruTile, TileCache, the consent gate, attribution) or a separate
package with no Mapsui at all is the scope proposal's first question; the second is a Vector3
bridge for `Coordinate`, which the 2026-11-08 shape work deliberately left at Vector2.

### Stage 3 — height and real 3D

- **Terrain the cheap way**: `Prompt How high is here` already decodes Terrarium PNG tiles to
  metres. On a stage-2 tile mesh that is vertex displacement along the normal — the field of
  chapter 5 standing up. Stride's `Displacement` material feature is scalar-along-normal, exactly
  this.
- **Terrain the standard way**: Cesium quantized-mesh tiles via `quantized-mesh-tile-cs` (MIT).
- **Buildings / 3D Tiles**: `Evergine.Bindings.CesiumNative` for tile selection and streaming,
  `VL.Stride.glTF` / SharpGLTF to turn the glb payloads into Stride models. .NET 10 and a native
  dll — a different family member, and only after a consumer asks.

## 5. Traps, recorded before anyone pays for them

| trap | source | the move |
|---|---|---|
| Mapsui never warps tiles to 4326; `SphereMesh`'s UV is equirectangular | Mapsui docs; Stride source | build the sphere with Mercator-spaced rows; do not fight the texture |
| GPU `atan(exp())` is vendor-inaccurate — hundreds of metres | MapLibre's error-measurement pass | compute φ per vertex on the CPU (stages 0–2); go to a shader only when vertex count forces it |
| texture seam at u = 0/1 picks the lowest mip | three-globe / realtimerendering | duplicate the seam column; clamp or no mips |
| Mercator has no poles | all | cap with fans; never stretch v past [0,1] |
| float32 at Earth radius = 0.5 m steps | Ohlarik, Cesium | unit sphere for globe view; RTC only at street level; or go flat like Mapbox |
| a world at z5 is 1024 tiles | OSM policy, the tile ledger | z4 by default, consent gate, count every fetch |
| `SkiaTexture` re-renders every frame; ignores blend modes; colour-space pin | forum | measure frame time in-patch; a render-once node as a scope question |
| `VSMain` override in a material extension crashed vvvv for one user | forum | override `PreTransformPosition` / `PostTransformPosition`, or build the mesh on the CPU |
| a 16384² RGBA8 texture is 1 GiB | D3D11 limits | the single-texture globe ends at 8192² — stage 2 is the answer, not a bigger texture |

## 6. Sources

Landscape: OpenGlobe https://github.com/virtualglobebook/OpenGlobe · Cesium.NET
https://github.com/EvergineTeam/Cesium.NET · nuget
https://www.nuget.org/packages/Evergine.Bindings.CesiumNative · cesium-native
https://github.com/CesiumGS/cesium-native · Mapsui #911 https://github.com/Mapsui/Mapsui/issues/911 ·
Mapsui static images https://mapsui.com/v5/static-image-generation/ · Mapsui projections
https://mapsui.com/v5/projections/ · BruTile https://github.com/BruTile/BruTile · bertt
https://github.com/bertt · SharpGLTF https://github.com/vpenades/SharpGLTF · VL.Stride.glTF
https://www.nuget.org/packages/VL.Stride.glTF · Esri ExportImageAsync
https://developers.arcgis.com/net/api-reference/api/netfx/wpf/Esri.ArcGISRuntime.UI.Controls.GeoView.ExportImageAsync.html ·
WorldWind https://worldwind.arc.nasa.gov/news · Maps SDK for Unity https://github.com/microsoft/MapsSDK-Unity ·
vvvv forum https://forum.vvvv.org/t/hi-res-world-map/21033 https://forum.vvvv.org/t/import-map-tiles/21042

Algorithms: MapLibre `create_tile_mesh.ts`, `globe_utils.ts`, `_projection_globe.vertex.glsl`,
`globe_projection_error_measurement.ts` (https://cdn.jsdelivr.net/npm/maplibre-gl@5.23.0/src/) ·
Mapbox `globe_constants.ts`, `globe_util.ts`, `globe_raster.vertex.glsl`
(https://github.com/mapbox/mapbox-gl-js/tree/main/src) and https://docs.mapbox.com/mapbox-gl-js/guides/globe/ ·
Cesium `ImageryLayer.js`, `QuadtreePrimitive.js`, `GlobeVS.glsl`
(https://github.com/CesiumGS/cesium/tree/main/packages/engine/Source) · Cesium log depth
https://cesium.com/blog/2018/05/24/logarithmic-depth/ · precision
https://help.agi.com/AGIComponents/html/BlogPrecisionsPrecisions.htm · deck.gl
https://deck.gl/docs/api-reference/core/globe-view · three-globe
https://github.com/vasturiano/three-globe · OSM zoom levels
https://wiki.openstreetmap.org/wiki/Zoom_levels · book TOC https://www.virtualglobebook.com/toc.html

vvvv: VL.StandardLibs `SkiaTexture.cs`, `SkiaRenderer.cs`
(https://github.com/vvvv/VL.StandardLibs/tree/main/VL.Stride.Runtime/src) · Gray Book
https://thegraybook.vvvv.org/reference/libraries/3d/models.html, shaders.html, rendering.html ·
Stride sphere https://github.com/stride3d/stride/blob/master/sources/engine/Stride.Graphics/GeometricPrimitives/GeometricPrimitive.Sphere.cs ·
forum https://forum.vvvv.org/t/stream-output-of-geometry-shader-in-vl-stride/19199
https://forum.vvvv.org/t/generating-procedural-mesh-from-buffer/19460
https://forum.vvvv.org/t/skia-and-stride-combination/21661

*Unverified as of this writing*: which vvvv gamma release runs on .NET 10 (the Cesium bindings
and VL.Stride.glTF need it); that a 4326 tile layer renders end-to-end in Mapsui; Evergine's
current engine licence (irrelevant to the bindings, which are MIT with no Evergine dependency).
