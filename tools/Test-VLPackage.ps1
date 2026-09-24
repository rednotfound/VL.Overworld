<#
.SYNOPSIS
    Static validation of this content pack. Needs no vvvv install.

.DESCRIPTION
    A sibling of vl-mapsui's script of the same name, and deliberately NOT a copy of it: a content
    pack is a different kind of package, and half that script's checks assert things that are false
    here.

      - There is no assembly, no src\ and no lib\, so every forwarded-assembly and ImportAsIs check
        goes. A pack that shipped a DLL would itself be the defect.
      - A chapter is SUPPOSED to declare foreign packages. Next door that is an error; here it is
        the entire point, and a chapter declaring only one is the thing worth flagging.

    Everything that still applies is carried over with its wording intact, because each of those
    checks corresponds to a defect that shipped at least once in a sibling repository.

      1. UTF-8 BOM on every .vl        vvvv will not load the document without it
      2. document IDs                  22 chars, first [A-V], unique within each document
      3. every internal reference      Link@Ids, Pad@SlotId, Fragment@Patch,
                                       Patch@ParticipatingElements. None of these is an XML error,
                                       so the document parses while being quietly wrong
      4. no <ProjectDependency>        points at a .csproj nobody installing this will have
      5. family packages pinned 0.0.0  or a chapter demands one exact version forever
      6. THE CROSS-PACKAGE RULE        a unit needing one library belongs in that library - EXCEPT
                                       a spine `Tutorial `, which may need one when the course's
                                       sequence requires it. A `Prompt ` gets no exemption
      7. genre prefix                  Tutorial / Prompt / Explanation / HowTo / Example. The
                                       filename is how a reader tells the spine from the library
      8. Help.xml agrees with disk     in both directions
      9. nuspec                        ships the .vl at root, ships NO lib\, declares the family
     10. no stray map tiles            a cache once wrote {z}\{x}\{y}.png into a repository

.EXAMPLE
    .\tools\Test-VLPackage.ps1
#>
param(
    [string]$RepoRoot = (Split-Path $PSScriptRoot -Parent)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PackName = 'VL.Overworld'
$VlFile   = Join-Path $RepoRoot "$PackName.vl"
$Nuspec   = Join-Path $RepoRoot "$PackName.nuspec"
$HelpDir  = Join-Path $RepoRoot 'help'

# The libraries this pack teaches. A unit naming two or more of these is what belongs here.
$Family = @('VL.Mapsui', 'VL.GeoJSON', 'VL.NetTopologySuite')

# The filename tells a reader which tier a unit is in before they open it, so it is validated.
# `Tutorial ` is the ordered spine; `Prompt ` is the unordered library. The other three are vvvv's
# own convention, carried over from the sibling packages.
$Genres = @('Tutorial ', 'Prompt ', 'Explanation ', 'HowTo ', 'Example ')

$errors = [System.Collections.Generic.List[string]]::new()
function Fail([string]$message) { $script:errors.Add($message) }
function Ok([string]$message)   { Write-Host "  ok    $message" -ForegroundColor DarkGray }
function Warn([string]$message) { Write-Host "  warn  $message" -ForegroundColor DarkYellow }

# Dot-notation on XmlElement throws under StrictMode when the element is absent, which is exactly
# the case a validator must survive. Namespace-agnostic, so the same helpers work on .vl and nuspec.
function Get-Child($node, [string]$name) {
    if ($null -eq $node) { return @() }
    @($node.ChildNodes | Where-Object { $_.LocalName -eq $name })
}
function Get-Attr($node, [string]$name) {
    if ($null -eq $node -or $null -eq $node.Attributes) { return $null }
    $a = $node.Attributes[$name]
    if ($a) { $a.Value } else { $null }
}

Write-Host "validating $PackName`n" -ForegroundColor White

if (-not (Test-Path $VlFile)) { throw "No entry document at $VlFile" }
if (-not (Test-Path $Nuspec)) { throw "No nuspec at $Nuspec" }

# 1-4, over the entry document and every chapter alike ------------------------
# The @() must wrap the Get-ChildItem itself: with no matches it returns nothing, and under
# StrictMode .FullName on nothing throws instead of giving an empty list.
$documents = @($VlFile) + @(
    if (Test-Path $HelpDir) { @(Get-ChildItem $HelpDir -Recurse -File -Filter *.vl) | ForEach-Object { $_.FullName } }
)
$documentProblems = 0

foreach ($path in $documents) {
    $label = Split-Path $path -Leaf
    $before = $errors.Count

    $head = Get-Content $path -AsByteStream -TotalCount 3
    if ($head.Count -lt 3 -or $head[0] -ne 0xEF -or $head[1] -ne 0xBB -or $head[2] -ne 0xBF) {
        Fail "$label has no UTF-8 BOM. vvvv writes one on every .vl; without it the document fails to load silently."
    }

    $raw = Get-Content $path -Raw

    $ids = @([regex]::Matches($raw, 'Id="([^"]*)"') | ForEach-Object { $_.Groups[1].Value })
    $malformed = @($ids | Where-Object { $_ -notmatch '^[A-V][0-9A-Za-z]{21}$' })
    if ($malformed) {
        Fail "$label has malformed document IDs (must be 22 chars, first in A-V): $($malformed -join ', ')"
    }
    $dupes = @($ids | Group-Object | Where-Object Count -gt 1 | ForEach-Object Name)
    if ($dupes) { Fail "$label uses these ids more than once: $($dupes -join ', ')" }

    if ($raw -match '<ProjectDependency\b') {
        Fail "$label contains a <ProjectDependency>. Shipped documents must not reference a .csproj."
    }

    $doc = New-Object System.Xml.XmlDocument
    try { $doc.LoadXml($raw) }
    catch { Fail "$label is not well-formed XML: $($_.Exception.Message)"; $documentProblems++; continue }

    # Every internal reference resolves. A .vl is a graph held together by 22-character strings,
    # and every one of these has broken at least once while editing by hand.
    $known = [System.Collections.Generic.HashSet[string]]::new(
        [string[]]@($doc.SelectNodes('//@Id') | ForEach-Object { $_.Value }))

    $unresolved = [System.Collections.Generic.List[string]]::new()
    foreach ($link in $doc.SelectNodes('//Link')) {
        foreach ($end in ($link.Ids -split ',')) {
            if (-not $known.Contains($end)) { $unresolved.Add("Link $($link.Id) -> $end") }
        }
    }
    foreach ($pad in $doc.SelectNodes('//Pad[@SlotId]')) {
        if (-not $known.Contains($pad.SlotId)) { $unresolved.Add("Pad $($pad.Id) -> Slot $($pad.SlotId)") }
    }
    foreach ($fragment in $doc.SelectNodes('//Fragment[@Patch]')) {
        if (-not $known.Contains($fragment.Patch)) { $unresolved.Add("Fragment $($fragment.Id) -> Patch $($fragment.Patch)") }
    }
    foreach ($operation in $doc.SelectNodes('//Patch[@ParticipatingElements]')) {
        foreach ($element in ($operation.ParticipatingElements -split ',')) {
            if (-not $known.Contains($element)) {
                $unresolved.Add("Patch '$($operation.Name)' ParticipatingElements -> $element")
            }
        }
    }
    foreach ($reference in $unresolved) { Fail "$label has an unresolved reference: $reference" }

    # A labelled, EMPTY IOBox wired to nothing is debris a reader will reasonably ask about. A
    # warning rather than a failure: one carrying a value is a constant, unconnected on purpose.
    $linked = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($link in $doc.SelectNodes('//Link')) {
        foreach ($end in ($link.Ids -split ',')) { [void]$linked.Add($end) }
    }
    foreach ($box in $doc.SelectNodes('//Pad[@isIOBox="true"][@Comment]')) {
        if (-not $linked.Contains($box.Id) -and [string]::IsNullOrEmpty($box.Value)) {
            Warn "$label has an empty IOBox '$($box.Comment)' connected to nothing"
        }
    }

    if ($errors.Count -ne $before) { $documentProblems++ }
}
if ($documentProblems -eq 0) { Ok "$($documents.Count) document(s): BOM, ids, references, no ProjectDependency" }

# 5 + 6. dependencies, and the rule this pack exists for ----------------------
$chapters = @(if (Test-Path $HelpDir) { Get-ChildItem $HelpDir -Recurse -File -Filter *.vl })
$chapterProblems = 0

foreach ($chapter in $chapters) {
    $before = $errors.Count
    $raw = Get-Content $chapter.FullName -Raw
    $declared = @([regex]::Matches($raw, '<NugetDependency\b[^>]*\bLocation="([^"]*)"[^>]*\bVersion="([^"]*)"') |
        ForEach-Object { [pscustomobject]@{ Name = $_.Groups[1].Value; Version = $_.Groups[2].Value } })
    $fromFamily = @($declared | Where-Object { $_.Name -in $Family })

    # 7. The filename declares the tier. Checked before the cross-package rule, because the
    # exemption below is keyed off it and an unrecognised prefix must not buy one by accident.
    $genre = @($Genres | Where-Object { $chapter.Name.StartsWith($_, [StringComparison]::Ordinal) }) |
        Select-Object -First 1
    if (-not $genre) {
        Fail "help\$($chapter.Name) does not start with one of: $(($Genres | ForEach-Object { $_.Trim() }) -join ', '). The filename is how a reader tells the ordered spine from the skippable library."
    }

    # 6. THE RULE. A unit that needs one library belongs in that library's own help\, where its
    # users find it without installing anything else.
    #
    # The exemption: a spine `Tutorial ` may need one package. Every unit with a payoff inside five
    # minutes uses VL.Mapsui alone, and a course with a hole at chapter 1 is worse than a duplicated
    # node - this pack declares all three packages, so a single-package unit here is duplication,
    # never breakage. A `Prompt ` gets no exemption: it is not carrying the sequence.
    if ($fromFamily.Count -eq 0) {
        Fail "help\$($chapter.Name) declares none of $($Family -join ', '), so it teaches nothing this pack is for."
    } elseif ($fromFamily.Count -eq 1 -and $genre -ne 'Tutorial ') {
        Fail "help\$($chapter.Name) needs only $($fromFamily[0].Name). A unit needing ONE package belongs in that package's own help\; this pack is for the ones that need two or more. Only a spine 'Tutorial ' is exempt."
    } elseif ($fromFamily.Count -eq 1) {
        Warn "$($chapter.Name) needs only $($fromFamily[0].Name) - allowed as spine, but its description must say why"
    }

    # Pinned to the sentinel, or the chapter demands one exact version of a sibling forever. vvvv
    # rewrites these to whatever is installed the moment the patch is saved in the GUI.
    foreach ($pin in @($fromFamily | Where-Object { $_.Version -ne '0.0.0' })) {
        Fail "help\$($chapter.Name) pins $($pin.Name) $($pin.Version); it must be 0.0.0. Run tools\Normalize-HelpPatches.ps1."
    }

    if ($errors.Count -ne $before) { $chapterProblems++ }
}
if ($chapters.Count -eq 0) { Warn "no units yet" }
elseif ($chapterProblems -eq 0) {
    $spine = @($chapters | Where-Object { $_.Name.StartsWith('Tutorial ', [StringComparison]::Ordinal) }).Count
    Ok "$($chapters.Count) unit(s), $spine in the spine: genre prefixes valid, cross-package rule met, all pinned 0.0.0"
}

# 7b. The spine numbers as chapter.lesson, and both runs are contiguous from 1. A gap is a silent
# hole in the spine; a flat number is the pre-2026-09-24 scheme sneaking back
# (docs/CHAPTER-STRUCTURE-PROPOSAL.md carries the decision).
$spineFiles = @($chapters | Where-Object { $_.Name.StartsWith('Tutorial ', [StringComparison]::Ordinal) })
$spineParsed = @()
foreach ($s in $spineFiles) {
    if ($s.Name -match '^Tutorial (\d+)\.(\d+) \S') {
        $spineParsed += [pscustomobject]@{ Chapter = [int]$Matches[1]; Lesson = [int]$Matches[2]; Name = $s.Name }
    } else {
        Fail "help\$($s.Name): a spine filename is 'Tutorial <chapter>.<lesson> <title>.vl'."
    }
}
if ($spineParsed.Count -eq $spineFiles.Count -and $spineFiles.Count -gt 0) {
    $chapterNumbers = @($spineParsed | ForEach-Object { $_.Chapter } | Sort-Object -Unique)
    $expectedChapters = @(1..$chapterNumbers.Count)
    if (Compare-Object $chapterNumbers $expectedChapters) {
        Fail "spine chapters are [$($chapterNumbers -join ', ')] - they must run 1..$($chapterNumbers.Count) with no gaps."
    }
    $lessonProblems = 0
    foreach ($ch in $chapterNumbers) {
        $lessons = @($spineParsed | Where-Object { $_.Chapter -eq $ch } | ForEach-Object { $_.Lesson } | Sort-Object)
        if (Compare-Object $lessons @(1..$lessons.Count)) {
            Fail "chapter $ch lessons are [$($lessons -join ', ')] - they must run 1..$($lessons.Count) with no gaps."
            $lessonProblems++
        }
    }
    if ($lessonProblems -eq 0 -and -not (Compare-Object $chapterNumbers $expectedChapters)) {
        Ok "spine numbering: $($chapterNumbers.Count) chapter(s), lessons contiguous in each"
    }
}

# 8. Help.xml agrees with what is on disk, in both directions -----------------
$helpXmlPath = Join-Path $HelpDir 'Help.xml'
if (-not (Test-Path $helpXmlPath)) {
    if ($chapters.Count -gt 0) { Fail "help\Help.xml is missing, so the chapters ship unordered and untagged." }
} else {
    [xml]$helpIndex = Get-Content $helpXmlPath -Raw
    $listed = @($helpIndex.SelectNodes('//VLDocument') | ForEach-Object { $_.link.Replace('\', '/') })
    $onDisk = @($chapters | ForEach-Object { $_.FullName.Substring($HelpDir.Length + 1).Replace('\', '/') })

    $indexProblems = 0
    foreach ($l in $listed) {
        if ($l -notin $onDisk) { Fail "Help.xml lists '$l', which is not on disk."; $indexProblems++ }
    }
    foreach ($d in $onDisk) {
        if ($d -notin $listed) {
            Fail "help\$d is not listed in Help.xml, so it never appears in the Help Browser."
            $indexProblems++
        }
    }
    if ($indexProblems -eq 0) { Ok "Help.xml lists exactly the $($onDisk.Count) chapter(s) on disk" }
}

# 9. nuspec -------------------------------------------------------------------
[xml]$nu = Get-Content $Nuspec -Raw
$pkg      = $nu.DocumentElement
$files    = @(Get-Child (@(Get-Child $pkg 'files') | Select-Object -First 1) 'file')
$metadata = @(Get-Child $pkg 'metadata') | Select-Object -First 1
$groups   = @(Get-Child (@(Get-Child $metadata 'dependencies') | Select-Object -First 1) 'group')
$declared = @($groups | ForEach-Object { Get-Child $_ 'dependency' } | ForEach-Object { Get-Attr $_ 'id' })

if (-not ($files | Where-Object { (Get-Attr $_ 'src') -eq "$PackName.vl" -and [string]::IsNullOrEmpty((Get-Attr $_ 'target')) })) {
    Fail "$PackName.nuspec does not ship $PackName.vl at the package root (target must be empty, or vvvv never finds it)."
} else { Ok "nuspec ships $PackName.vl at the package root" }

# A content pack that shipped an assembly would be a different kind of thing.
$shipsLib = @($files | Where-Object { (Get-Attr $_ 'target') -like 'lib*' -or (Get-Attr $_ 'src') -like '*.dll' })
if ($shipsLib) {
    Fail "$PackName.nuspec ships an assembly. This pack contributes no nodes; anything that needs one belongs in a library."
} else { Ok "no assembly shipped - the pack teaches, the libraries do the work" }

$missing = @($Family | Where-Object { $_ -notin $declared })
if ($missing) {
    Fail "$PackName.nuspec does not declare $($missing -join ', '), so installing the pack would not bring what the chapters import."
} else { Ok "nuspec declares all $($Family.Count) libraries the chapters teach" }

# 10. stray map tiles ---------------------------------------------------------
$strays = @(Get-ChildItem $RepoRoot -Recurse -File -Filter *.png -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '\\\d+\\\d+\\\d+\.png$' })
if ($strays) {
    Fail "found $($strays.Count) file(s) shaped like cached map tiles. A tile cache has written into the repository; see vl-mapsui NOTES.md, 2026-08-14."
} else { Ok "no {zoom}\{x}\{y}.png anywhere in the repository" }

# -----------------------------------------------------------------------------
Write-Host ''
if ($errors.Count -gt 0) {
    Write-Host "FAIL - $($errors.Count) problem(s):" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "PASS - pack structure is valid." -ForegroundColor Green
