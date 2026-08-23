# Third-party notices

The patches in this package are MIT. **The sample data is not** — geographic data almost always
carries a licence, and several of them require attribution wherever the data is *shown*, not
merely wherever it is redistributed. That is a working constraint on anyone building a map, which
is why chapter 09 treats it as part of the lesson.

## Sample data shipped in `help/Assets/`

| file | source | licence | what it asks of you |
|---|---|---|---|
| `cities.geojson` | hand-written for this package | MIT, same as the patches | nothing |

*(Grows as chapters are added. Every asset gets a row before it is committed — an unattributed
file in a shipped package is a licensing defect, not an oversight to fix later.)*

## Data sources worth knowing, and what they cost

Not shipped here, but these are where real data comes from and the terms differ sharply:

- **[Natural Earth](https://www.naturalearthdata.com/)** — public domain. Countries, coastlines,
  rivers, populated places, at three scales. No attribution required, though it is polite. The
  easiest legal starting point for anything global.
- **[OpenStreetMap](https://www.openstreetmap.org/copyright)** — **ODbL**. Free to use, but
  attribution is required *on the map itself*, and derived databases must be shared alike. Extracts
  from Geofabrik and Overpass carry the same terms. VL.Mapsui's `Attribution` widget exists for
  exactly this.
- **National open-data portals** — for example
  [GSI Japan](https://www.gsi.go.jp/kikakuchousei/kikakuchousei40182.html) or
  [data.gov](https://data.gov/) — usually permissive, usually with an attribution clause, and
  usually specific about *how* the attribution must read.
- **[USGS Earthquake Hazards Program feeds](https://earthquake.usgs.gov/earthquakes/feed/)** —
  public domain (US government work); the USGS asks that data be credited
  ["courtesy of the U.S. Geological Survey"](https://www.usgs.gov/information-policies-and-instructions/acknowledging-or-crediting-usgs).
  `Prompt Live earthquakes` fetches the summary GeoJSON at runtime — nothing is shipped — one
  request per press of its Fetch button, no key, no account. The feed updates about once a
  minute, which is the polite ceiling for refreshing it.

## Tile services

Tiles are not data you hold; they are a service someone pays for.

**OpenStreetMap's tile servers run on donated hardware and their
[tile usage policy](https://operations.osmfoundation.org/policies/tiles/) forbids bulk
downloading.** VL.Mapsui sends a User-Agent naming itself, caches only the tiles that were actually
drawn, and ships every patch with the tile layer switched **off** so that opening a document does
not fetch anything you did not agree to. Those are not conveniences; they are what the policy asks
for.

### The basemaps `Tutorial 06` offers, and what each asks

Every one was fetched and **looked at** on 2026-08-17 — a 200 and a plausible byte count is not
proof, because an error tile is also a valid PNG.

| paste this into `URL Template` | licence | put this on the `Attribution` pin |
|---|---|---|
| `https://tile.openstreetmap.org/{z}/{x}/{y}.png` | ODbL data, CC-BY-SA tiles | `© OpenStreetMap contributors` |
| `https://tile.opentopomap.org/{z}/{x}/{y}.png` | CC-BY-SA 3.0 | `Map data: © OpenStreetMap contributors, SRTM \| Style: © OpenTopoMap (CC-BY-SA)` |
| `https://a.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png` | ODbL / CC-BY-SA | `© OpenStreetMap contributors \| CyclOSM` |
| `https://tiles.maps.eox.at/wmts/1.0.0/s2cloudless-2020_3857/default/g/{z}/{y}/{x}.jpg` | **CC BY-NC** — see below | `Sentinel-2 cloudless 2020 by EOX IT Services GmbH (Contains modified Copernicus Sentinel data 2020)` |
| `https://tiles.maps.eox.at/wmts/1.0.0/blackmarble_3857/default/g/{z}/{y}/{x}.jpg` | NASA imagery, EOX rendering | `Black Marble { © NASA } \| Rendering © EOX` |
| `https://tiles.maps.eox.at/wmts/1.0.0/terrain-light_3857/default/g/{z}/{y}/{x}.jpg` | OSM/NaturalEarth/GEBCO data, EOX rendering | `Terrain Light { Data © OpenStreetMap contributors and others, Rendering © EOX }` |

Three notes that cost an afternoon each if you meet them the hard way:

- **s2cloudless is non-commercial.** Free for "academic research, educational materials, school and
  university projects, NGO publications and humanitarian mapping, personal use"; anything
  commercial needs an EOX licence. Shipping the URL is fine — what you *display* is your side of it.
- **All three EOX layers come off a demo service**, which states "provided as is without any
  guarantee. Content and availability may change without notice" and applies rate limiting under
  load. Fine for a lesson; not something to point an installation at. The per-source disk cache is
  most of what makes us a tolerable guest.
- **The `{s}` subdomain placeholder is not supported.** `XYZ` hands the template to BruTile, which
  substitutes `{x}`, `{y}` and `{z}` and nothing else, so a provider's documented
  `https://{s}.example.com/…` must have a real subdomain written in (`a.`) or be dropped. Some hosts
  only answer on the subdomain form — `tile.openstreetmap.fr` presents a certificate for a different
  name, and `tile-cyclosm.openstreetmap.fr` does not resolve at all.
- **Placeholder order does not matter**, only presence. `…/{z}/{y}/{x}.jpg` works, which is why the
  EOX row above is not a typo.

### Two that work perfectly and are not allowed

Both return a correct, good-looking tile. Neither may be used, and **that is the point of putting
them here**: a request that succeeds tells you nothing about whether you were permitted to make it.

- **CARTO** (Positron, Dark Matter, Voyager). Their own
  [`LICENSE.md`](https://github.com/CartoDB/basemap-styles/blob/master/LICENSE.md): *"access to
  CARTO's basemap tile services is restricted to CARTO enterprise customers and Non-Profit GRANTS
  only and is not available for free public use."* The open licence covers the **style definitions**,
  not the hosted tiles — an easy and expensive thing to misread.
- **Esri World Imagery** via `server.arcgisonline.com`. The grant is *"the non-exclusive right to
  use the World Imagery map to trace features and validate edits in the creation of vector data…
  any and all other uses… remain subject to the terms and conditions set forth in the Esri Master
  Agreement"*. A basemap in a tutorial is one of those other uses.

Any other provider — Mapbox, Stadia, Thunderforest, a national service — has its own terms, its own
key, and its own required credit. `XYZ` will point at any of them. Reading their terms is your
part.

## Coordinates typed into `Tutorial 07`

Nothing is shipped as a file — these are numbers in IOBoxes — but they still came from somewhere,
and where from decides whether the chapter may print them.

| what | source | licence |
|---|---|---|
| Haneda Terminals 1, 2 and 3 | [Wikidata](https://www.wikidata.org/) Q57080453 / Q57080454 / Q57080456 | **CC0** — no attribution required |
| Runway 16L/34R, and the other three in the comment | [OurAirports](https://ourairports.com/data/) | **public domain** |
| the box round the runways | drawn by hand for this chapter | MIT, like the patch |

**The third row is the point of the table.** The chapter says out loud that the box is not the
boundary of anything — a real airport outline has hundreds of vertices and arrives in a file, which
is chapter 09. Passing off a sketch as surveyed data would be the exact failure this pack keeps
warning about, one row further down the stack.

## `help/Assets/haneda.geojson` — the real airport

**754 features from OpenStreetMap**, fetched through Overpass on 2026-08-18 for the bounding box
`35.53,139.75,35.58,139.83` and converted to GeoJSON: 712 taxiways, 14 aprons, 9 runways, 9
terminals, 6 hangars, 4 helipads. Coordinates rounded to six decimals — about 0.1 m at this
latitude, and anything finer is noise that only costs bytes.

**ODbL, and this one has teeth.** Attribution is required *wherever the data is shown*, not merely
wherever the file is passed on. So `Tutorial 07` carries an `Attribution` widget, which its donor
patch did not — that was added the moment this file arrived, because displaying ODbL data with no
credit on screen is a licensing defect rather than a cosmetic gap. Derived databases must also be
shared alike.

The credit reads `© OpenStreetMap contributors`, and one line covers both the basemap tiles and
this vector data, since they are the same source.

*(`haneda-runways-and-buildings.geojson` is the same extract with the taxiways removed — 42
features, kept because a 40 KB file can be embedded in a patch as a string where a 307 KB one
cannot. Same terms.)*

## `help/Assets/fuji.geojson` — Mount Fuji

**65 features from OpenStreetMap**, fetched through Overpass on 2026-08-22 for
`35.28,138.66–35.42,138.82`: 41 segments of the five climbing routes (吉田, 富士宮, 須走, 御殿場,
河口湖), 13 peaks and 11 mountain huts. Peaks and huts carry `ele`, which is why the file is worth
more than its geometry.

**ODbL**, same terms and the same obligation as the Haneda extract: the credit belongs wherever the
data is shown, so `Prompt A mountain` carries an `Attribution` widget.

The nine crater-rim coordinates **typed into that patch by hand** come from the same source — they
are the peaks between 3718 m and 3776 m, and they are printed in the patch as numbers rather than
loaded, which does not change whose measurement they are.

*(Elevations, for anyone checking the patch text against the file: 剣ヶ峰 3776, 白山岳 3756,
伊豆岳 3749, 成就岳 3734, 三島岳 3734, 朝日岳 3733, 久須志岳 3725, 浅間岳 3722, 駒ヶ岳 3718.)*
