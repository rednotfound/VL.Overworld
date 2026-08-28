# Subpatches — a proposal, written 2026-08-28 after `Prompt Grow a town`

The user asked why, twenty chapters in, no patch in this pack has ever been split into a subpatch,
and pointed at `Prompt Grow a town` — 204 nodes, 317 links, a loop three regions deep — as the
place to start. This file is the survey of how shipped vvvv patches do it, the XML that a
generator or a hand needs, and a concrete cut for that chapter — **built the same evening; see
"Built" at the end for what the survey got wrong.**

## What vvvv calls it, and how often shipped help uses it

In VL a "subpatch" is a **node definition inside the document**: a `Process` (stateful, with
`Create`/`Update` operations — the norm, 346 in shipped help) or an `Operation` (stateless, 31,
almost all of them delegates inside regions rather than stand-alone). A definition is used like any
library node; it lives in category `Main` and resolves from the document itself.

Measured across vvvv gamma 7.4's VL.CoreLib and VL.Skia help (299 documents):

| set | documents defining their own nodes |
|---|---|
| all 299 help documents | **32** (11 %) |
| VL.Skia `Examples\` — the genre closest to ours | **9 of 29** (31 %) |
| this pack, 20 chapters | **0** |

How the ones that do are shaped:

| document | nodes | definitions (besides `Application`) |
|---|---|---|
| Example Tetris | 186 | `Grid`, `InputHandler`, `Tetromino`, `JoinCells`, `RotateShape`, `GetGrid`, `GetShape` |
| Example DifferentialGrowth | 78 | `DifferentialGrowth`, `Node` (a Record), `CreateInitCircle`, `RejectAll`, `RejectNode`, `AttractNeighbours`, `EdgeSplit` — the last five **nested inside** `DifferentialGrowth`'s own canvas |
| Example Spray | 36 | `Droplet`, `DrawDroplets`, `Spray` |
| Example Simple Drawing App | 33 | `DrawStroke`, `Stroke`, `UndoControler` |
| Example NoisyAgents | — | `Agent` |

Three conventions are visible without being written anywhere:

1. **A thing that persists is a noun** (`Agent`, `Droplet`, `Tetromino`, `Grid`); **a step is a
   verb phrase** (`JoinCells`, `RotateShape`, `RejectAll`, `EdgeSplit`, `DrawDroplets`).
2. **The `Application` keeps the story and the knobs**; the definitions hold the mechanism.
   Tetris's `Application` is a handful of nodes wiring `InputHandler` → `Grid` → renderer.
3. **Definitions may nest**: a step used only by one node is defined inside that node's canvas
   (DifferentialGrowth), so the top level of the document stays short.

And one measurement from VL-PATCH-XML.md worth repeating: **2,423 shipped process definitions have
an empty `Create`**. A subpatch with only an `Update` is the normal case, not a shortcut.

## The XML, copied from shipped files

A definition is a `Node` with `Name`, at the **root** `<Patch>` of the document, beside `Application`
(or inside another definition's canvas to nest it):

```xml
<Node Name="StreetEnds" Category="Main" Bounds="620,100" Id="…" Summary="Every street's first and last vertex as Vector2">
  <p:NodeReference>
    <Choice Kind="ContainerDefinition" Name="Process" />
    <FullNameCategoryReference ID="Primitive" />
  </p:NodeReference>
  <Patch Id="…">
    <Canvas Id="…">                          <!-- the nodes, regions and pads, as in Application -->
      …
    </Canvas>
    <Patch Id="…" Name="Create" />           <!-- empty: nothing runs once -->
    <Patch Id="…" Name="Update">
      <Pin Id="IN…"  Name="Streets" Kind="InputPin"  Bounds="200,80" />     <!-- pins live on the fragment -->
      <Pin Id="OUT1" Name="Starts"  Kind="OutputPin" Bounds="200,600" />    <!-- x order = pin order -->
      <Pin Id="OUT2" Name="Ends"    Kind="OutputPin" Bounds="320,600" />
    </Patch>
    <ProcessDefinition Id="…">
      <Fragment Id="…" Patch="…Create…" Enabled="true" />
      <Fragment Id="…" Patch="…Update…" Enabled="true" />
    </ProcessDefinition>
    <Link Id="…" Ids="IN…,innerNodePin"  IsHidden="true" />   <!-- fragment pin -> canvas: hidden -->
    <Link Id="…" Ids="innerNodePin,OUT1" IsHidden="true" />
  </Patch>
</Node>
```

A pin may carry a `DefaultValue` and a `p:TypeAnnotation` exactly like a node's pin. An input that
must be read at creation goes on the `Create` fragment and is stored through a `Pad` with a `SlotId`
and a `<Slot>` (NoisyAgents' `Position`) — **and after 2026-08-28 we know what a Create pin does to
the caller**: a computed chain wired into one pulls the caller's graph into `__Create__`. Keep every
pin of every subpatch here on `Update`.

Using it, inside `Application` (or inside another definition):

```xml
<Node Bounds="…" Id="…">
  <p:NodeReference LastCategoryFullName="Main" LastSymbolSource="Prompt Grow a town.vl">
    <Choice Kind="NodeFlag" Name="Node" Fixed="true" />
    <Choice Kind="ProcessAppFlag" Name="StreetEnds" />
  </p:NodeReference>
  <Pin Id="…" Name="Streets" Kind="InputPin" />
  <Pin Id="…" Name="Starts" Kind="OutputPin" />
  <Pin Id="…" Name="Ends" Kind="OutputPin" />
</Node>
```

`LastSymbolSource`/`LastDependency` are hints; the name resolves within the document. The generated
C# gets one class per definition, so **rung 3 checks each definition's `Update()`**, not only the
Application's — the method-boundary check from PATCH-GRAMMAR applies per class.

## The cut for `Prompt Grow a town`

The test for what stays in `Application`: **would the reader look at it?** The narrative column,
the cockpit row, the two seeds, the FrameDelay loop with its two switches, `BuildNetwork` →
`ShortestPath` with the readouts, the render group, SAVE. About 45 nodes. Everything the reader
would only ever scroll past becomes a named node with a `Summary`:

| definition | pins | replaces | why it is its own node |
|---|---|---|---|
| **`GrowTown`** | `Streets` → `Grown`, `GeoJSON` | the whole Cache region | one node says "the rule"; its canvas holds the Cache and the five steps below, **nested** (DifferentialGrowth's shape) so the document's top level stays `Application` + `GrowTown` + two drawing helpers |
| `StreetEnds` | `Streets` → `Starts`, `Ends` | loop E (ForEach in ForEach) | the Coordinates→Vector2 idiom, named once |
| `DeadEnds` | `From`, `To`, `All Ends` → `From`, `To` | loop D (Keep in Keep) | the definition of a dead end is one sentence; the node should be too |
| `GrowTip` | `From`, `To`, `Branch` (bool) → `Child From`, `Child To` | loops **A and B** | the two loops are the same 30 nodes with one switch; a `Branch` pin removes the duplicate — the first place a subpatch pays for itself |
| `HashOf` | `Position` → `Value` (0–1) | 8 nodes inside A and B | the folklore formula gets a name and a Summary that cites it |
| `PairsToStreets` | `From`, `To` → `Streets` | loop L | Vector2 pairs back into geometry |
| **`DrawLines`** | `Geometry` (Spread), `Paint` → `Layer` | the streets loop **and** the route loop | used twice already: the second place a subpatch pays for itself |
| **`Readouts`** | `Found`, `Route`, `Streets`, `Networks Built` → `Layer` | 9 `Text` nodes, 4 `ToString`, `FontAndParagraph`, a `Group` | furniture; the reader never needs to see how text is painted |

Estimated result: `Application` ≈ 45 nodes, `GrowTown` ≈ 15 at its top level with five nested
definitions of 10–30 nodes each, `DrawLines` ≈ 10, `Readouts` ≈ 16. Same 1,300-odd ids, but no
canvas with more than ~45 things on it, and two pieces of duplication gone.

What does **not** change: the Help.xml entry, the validator (ids, links, BOM, genre, packages),
the compile harness, the four rungs. What changes in the generator: a `Definition` helper beside
`Region`, emitting the block above; links inside a definition go in that definition's `<Patch>`,
not the Application's (the "ALL links in the outer patch" rule is per definition, not per document).

## A rule to add to PATCH-GRAMMAR once the first one ships

A chapter gets a subpatch when any of these is true — and otherwise not, because a tutorial is
read top to bottom and a node the reader must open is a node the reader must trust:

- the same shape appears **twice** (`DrawLines`, `GrowTip`);
- a region nests **three deep** (E inside the Cache, D's inner loop);
- the canvas passes **~100 nodes** — this chapter is the first at 204; the next largest is 92.

Which door (89) and How high is here (92) sit under the line and are edited in place only; they
stay flat. The rule is for what comes next, and for `Grow a town` now.

## Built 2026-08-28, late evening — by the generator after all, and four things the survey missed

The user asked for it to be done rather than described. The generator was still in the session, so the
cut above was built as written: eight definitions (`HashOf`, `StreetEnds`, `DeadEnds`, `GrowTip`,
`PairsToStreets`, `GrowTown`, `DrawLines`, `Readouts`), 175 nodes in the document against 204 before,
`Application` down to ~45, `GrowTip` once with a `Branch` pin instead of two 30-node copies,
`DrawLines` used twice. Rung 4 (driven by `Capture-Renderer.ps1`): 11 presses → FOUND True, 960 m, 129
streets, NETWORKS BUILT 13 — identical to the flat build. Four compiles and three relaunches to get
there, and every one of the four faults was in the *definition* mechanics, not the chapter:

1. **Definitions live INSIDE the root `<Canvas>` element**, which must therefore not be self-closed;
   `Application` sits after `</Canvas>`. The XML block above had them as siblings of the canvas and
   vvvvc said `Not found: HashOf` — for a definition sitting right there in the file. A two-node
   probe (`Twice`, then `Quad` using `Twice`) settled it in one compile.
2. **Every pin of a definition must carry a type annotation.** An untyped pin is inferred from its
   inner use, and when that is generic (`ToString`, a `ForEach`) it becomes `object`; the caller's
   link is then **dropped in silence** and the C# reads `Debug_1_In: default(object)`. `Spread<T>`
   is written as `Spread` with `<p:TypeArguments><TypeReference …>` (syntax from shipped patches);
   NTS types resolve with `LastCategoryFullName="NetTopologySuite.Geometries"`.
3. **An input and an output must not share a name.** `DeadEnds` had `From`/`To` on both sides; a
   name-keyed pin dictionary silently pointed the *caller's* links at the outputs and the inputs
   stayed empty — no dead ends, no children, a town that never grew, no exception anywhere. Found by
   drawing stage counts on the picture (`ends 2, dead 0`). Outputs are now `Dead From`/`Dead To` and
   the generator asserts the two name sets are disjoint. FrameDelay gets away with `Value`/`Value`;
   a generator does not.
4. **The signature's pin order is not the `Bounds` x order** (`From, All Ends, To` came out of
   `60, 180, 300`); irrelevant to the compiled code, visible in the node's tooltip. Unresolved.

And one that was not the mechanism: a **vvvv instance from an hour earlier had survived every
`taskkill` issued from Git Bash**, `Open-HelpPatch.ps1` refused to start a second (correctly) while the
calling script only counted output lines, and vvvv **hot-reloaded** each regenerated file into the old
process. Two rounds of "still nothing" were measured against that. `Stop-Process -Force` from
PowerShell, then confirm the count is 0, then launch, then confirm the start time is seconds ago.

The chapter is now edit-in-place only, like every other. Rung 3 gains a line: **grep the C# for
`default(` at every definition call site** — a dropped link looks exactly like a wired one from the
canvas.

## Cost, honestly

One generator extension, one regeneration (the patch has not been arranged by hand — it is the
one chapter where regeneration is still legal), four compiles at most, one rung 4 that a person
watches again, because moving nodes between operations is exactly the kind of change the first
three rungs cannot see (2026-08-28, evening, this very chapter). Half a session.
