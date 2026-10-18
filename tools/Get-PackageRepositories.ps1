<#
.SYNOPSIS
    The package repositories and NuGet feeds this pack needs, in one place.

.DESCRIPTION
    This pack builds nothing. It has no dist\ and no deps\ of its own - every node its chapters use
    comes from a sibling repository, so opening or compiling a chapter needs SIX folders on
    --package-repositories and three NuGet sources for restore.

    That list lives here and nowhere else, because it has already been the problem twice. In
    vl-mapsui the same list was written out in two scripts and typed by hand a third time; two
    launches were lost to it, each failing with an error that named something entirely different
    ("The referenced symbol source 'Mapsui.dll' couldn't be found" for a missing deps\, "Missing
    package: VL.NetTopologySuite" plus twenty-five ambiguous Point candidates for a missing dist\).
    A repository folder that does not exist is IGNORED SILENTLY by vvvv, which is precisely how a
    missing folder disguises itself as a broken package.

.OUTPUTS
    A hashtable: Repositories (string[]), Feeds (string[]), Missing (string[]).
    Missing is not empty when a sibling has not been packed - the caller decides whether that is
    fatal, because it usually is.
#>
param(
    [hashtable]$Siblings = @{
        'VL.Mapsui'           = 'D:\2026_Projects\vl-mapsui'
        'VL.NetTopologySuite.GeoJSON' = 'D:\2026_Projects\vl-geojson'
        'VL.NetTopologySuite' = 'D:\2026_Projects\vl-nettopologysuite'
    }
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositories = [System.Collections.Generic.List[string]]::new()
$feeds        = [System.Collections.Generic.List[string]]::new()
$missing      = [System.Collections.Generic.List[string]]::new()

foreach ($name in ($Siblings.Keys | Sort-Object)) {
    $repo = $Siblings[$name]

    # dist\ is the staged PACKAGE FOLDER - how vvvv finds the package itself.
    $dist = Join-Path $repo 'dist'
    if (Test-Path $dist) { $repositories.Add($dist) } else { $missing.Add("$name : $dist (run its pack.ps1)") }

    # deps\ holds the upstream libraries a real install would have pulled in beside it. Omitting
    # this is what produces "the referenced symbol source couldn't be found".
    $deps = Join-Path $repo 'deps'
    if (Test-Path $deps) { $repositories.Add($deps) }

    # dist\feed\ is the NUPKG SOURCE - a different thing, needed by restore rather than by vvvv.
    # Supplying one and not the other gives a confident error about the other.
    $feed = Join-Path $repo 'dist\feed'
    if (Test-Path $feed) { $feeds.Add($feed) }
}

@{
    Repositories = $repositories.ToArray()
    Feeds        = $feeds.ToArray()
    Missing      = $missing.ToArray()
}
