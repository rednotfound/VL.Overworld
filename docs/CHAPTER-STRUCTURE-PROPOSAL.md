# Chapter Structure Proposal — the spine gains chapters

**Status: DECIDED 2026-09-24 — seven chapters, scheme B.** Executes as the first step of the
end-of-campaign words batch; nothing renames until then (see Timing). The one verification that
could have sunk the scheme has already run: a dotted filename compiles (below).

## The problem — three observations, 2026-09-23/24

1. **The knowledge architecture exists in three places and none of them is where anyone looks
   first.** Help.xml's Topics group the spine into acts, CURRICULUM.md carries the act tables,
   README lists them — but the filenames, the thing a reader sees in the Help Browser list, in the
   folder, and in every in-text `NEXT` pointer, carry only a flat serial number. `Tutorial 07`
   does not say which body of knowledge it belongs to.
2. **Flat 01–14 numbering makes every insertion global.** Adding one geometry chapter after 05
   renames 06–14 and rewrites every cross-reference. The geometry part is expected to grow (the
   user, 2026-09-23), so this is a standing tax on the course's most likely growth.
3. **The acts' definitions have drifted out from under the units.** The redesigned Tutorial 01
   now contains a (tile-less) map, breaking Act I's "no basemap" charter — for the better, but
   the charter no longer describes the act. And Act III is four unrelated world-view extensions
   (projections, indexing, fields, networks) under one label; it is the part that feels
   structureless because it is.

## The evidence

- **The platform supports chapters natively.** Help.xml takes `Topic` → `Subtopic` nesting, and
  `help\` may use up to two levels of subdirectories
  ([Gray Book, Providing Help](https://thegraybook.vvvv.org/reference/extending/providing-help.html)).
  `Compile-HelpPatches.ps1` already recurses.
- **QGIS Training Manual**: Module N / Lesson N.M. Growth happens inside a module; modules never
  renumber. Thin modules exist and are honest.
- **Nature of Code**: thematic chapters 0–11; a decade of growth landed inside chapters, the
  chapter skeleton never moved.
- **The Coding Train**: main tracks / side tracks — already our Tutorial/Prompt tiers; unchanged.
- **The counterexample is in-family**: VL.TheBigBang's 45 flat numbered units, already cited in
  CURRICULUM.md as what "numbering as noise" looks like. Our current shape is that shape.

## Decision 1 — what the chapters are (the user's call)

The test is the one the Explanation split established (2026-08-23): **two units belong to
different chapters when they answer different questions.** Applied to the 14 spine units:

| ch | the question it answers | today's units | growth expected |
|---|---|---|---|
| 1 | How does a shape become data? | 01–05 | **yes — the user's stated intent**; Voronoi / Simplify land here |
| 2 | How does my data get onto the earth? | 06–09 (appearance, features, map↔cursor, files) | feature editing, more interaction |
| 3 | Why does the same place have different numbers? | 10 | reprojection when unblocked (GST 101 Lab 3, gap rank 2) |
| 4 | How do you ask 100,000 things quickly? | 11 | big-data prompts |
| 5 | What if space is not an object? | 12 | raster / DEM when it exists |
| 6 | When is close not reachable? | 13 | routing growth |
| 7 | What if the world does not fit in memory? | 14 | the Act IV lab's output |

Five of seven are one lesson today. That is honest, not sparse: a thin chapter is a **labelled
growth slot** — every blocked or waiting capability in the roadmap (reprojection, raster, more
network) has a named home instead of a renumbering bill. QGIS ships one-lesson modules.

**Alternative: the four acts become the four chapters** (1 geometry 01–05, 2 maps 06–09,
3 beyond 10–13, 4 access 14). Fewer, keeps the act arc literally — but chapter 3 stays the
grab-bag that observation 3 names, and splitting it later renumbers inside it anyway. The act
arc survives either way as prose (README: "chapters 1–2 are the geometry and map acts…").

**Decided 2026-09-24: seven** ("七章就七章吧"). Act I's charter updates to *no tiles, no network* — the
redesigned T01's tile-less map is legal, and the promise the reader actually gets (nothing is
fetched) is stated exactly.

Chapter *names* (the poetic titles, and their language) belong to the words batch, not to this
proposal. The table above names questions, which is what Help.xml's Topic titles should carry.

## Decision 2 — numbering: scheme B, flat folder + chapter.lesson filenames

`Tutorial 2.3 The map is just giving you coordinates.vl`. Lessons restart per chapter. Prompts
and Explanations stay unnumbered — the two-tier rule is untouched; numbering remains a claim
that order matters, now made twice and locally: chapters are ordered, lessons are ordered within
their chapter. Inserting a geometry lesson touches chapter 1 and nothing else.

**Verified 2026-09-24: a dotted filename compiles.** A full copy of Tutorial 03 as
`Tutorial 1.3 smoke test.vl` went through `Compile-HelpPatches.ps1` (real vvvvc, real package
repositories): exit 0, five generated `.cs` files, 50 KB. Measured because of the apostrophe
precedent (PATCH-GRAMMAR: vvvvc crashes on a document filename containing `'`). Residual
rung-4 check at execution time: the Help Browser *displays* a dotted name correctly and
`Open-Chapter.cmd` opens one.

**Why not scheme C (chapter subfolders), although the platform allows it.** Audited 2026-09-24:
every serialized path in all four repositories' patches is document-relative (`Assets\x.geojson`;
zero absolute paths anywhere — the Path IOBox *displays* absolute but *stores* relative,
[Gray Book, IOBoxes](https://thegraybook.vvvv.org/reference/language/ioboxes.html)). So C is
*safe* — `..\Assets\` stays portable — but it costs: 8 wired asset paths rewritten, 7 narrative
mentions of `Assets\…` rewritten (they would become lies), four tools taught recursion and
name-uniqueness, Help.xml subfolder `link` format unverified, and the folder tree becomes a
second source of truth for chapter membership that can drift from Help.xml. C's one unique gain —
chapters visible in the filesystem — is invisible in the Help Browser, which is the reader's
actual surface. **C stays the fallback** for the day a chapter wants self-contained assets that
travel with it; today assets are shared across chapters (haneda.geojson serves T07 and an
Explanation).

## The change list — one batch, merged with the words pass

1. `git mv` the 14 spine files (history follows renames; the 2026-08-22 renumbering proved the
   drill).
2. `Help.xml`: one Topic per chapter, title carrying the chapter number and its question; links
   updated.
3. `Test-VLPackage.ps1`: spine prefix becomes `^Tutorial \d+\.\d+ `; add a check that each
   chapter's lesson numbers are contiguous from 1 (a gap is a silent hole in the spine).
4. Docs: README's course table, CLAUDE.md's unit table, CURRICULUM.md (this decision recorded as
   the **fourth correction**), filename references in PATCH-GRAMMAR / ACT-III-DESIGN /
   ACT-IV-LAB.
5. In-patch text: narrative openers ("09 - Real data…"), `NEXT` pointers, any chapter-number
   mentions — **this is the words batch itself**, which is why the two merge.
6. Verification: rungs 1–2 across the whole pack; generated C# spot-check unchanged (renames do
   not touch content); rung 4 = Help Browser shows the chapters, one dotted chapter opened via
   `Open-Chapter.cmd`, plus the two residual checks above.

## Timing

**Nothing renames now.** The hand-arranging campaign continues on current names. When the user
calls the end-of-campaign words batch, this executes as its first step — every in-text reference
is rewritten once, not twice. The only thing already done is the smoke test.

## What does not change

The two tiers; prompts and Explanations unnumbered; edit-in-place; `help\` stays flat; `Assets\`
stays where it is and no wired path moves; the checked-in `.vl` remains the source of truth.
