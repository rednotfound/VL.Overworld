<#
.SYNOPSIS
    A double-clickable picker for the chapters - select one, vvvv opens it.

.DESCRIPTION
    Wraps Open-HelpPatch.ps1, which stays the single source of truth for HOW a chapter is
    launched: the six package repositories, the vvvv-already-running check, the missing-dist
    check. This file only supplies a window, for the days when nobody remembers the command -
    every launch still goes through the same gate, and every refusal is printed in the log box
    with the same words.

    Start it by double-clicking Open-Chapter.cmd in the repository root, or:

        pwsh -File tools\Open-HelpPatch-GUI.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$RepoRoot  = Split-Path $PSScriptRoot -Parent
$Launcher  = Join-Path $PSScriptRoot 'Open-HelpPatch.ps1'
$Normalize = Join-Path $PSScriptRoot 'Normalize-HelpPatches.ps1'
$HelpDir   = Join-Path $RepoRoot 'help'

# The same enumeration Open-HelpPatch.ps1 uses, so the window never shows a chapter the
# launcher would not find.
$chapters = @(Get-ChildItem $HelpDir -Recurse -File -Filter *.vl | Sort-Object Name)

$form                 = [System.Windows.Forms.Form]::new()
$form.Text            = 'VL.Overworld - open a chapter'
$form.ClientSize      = [System.Drawing.Size]::new(600, 600)
$form.StartPosition   = 'CenterScreen'
$form.Font            = [System.Drawing.Font]::new('Segoe UI', 10)
$form.MinimumSize     = [System.Drawing.Size]::new(480, 480)

$list                 = [System.Windows.Forms.ListBox]::new()
$list.Location        = [System.Drawing.Point]::new(12, 12)
$list.Size            = [System.Drawing.Size]::new(576, 300)
$list.Anchor          = 'Top,Left,Right,Bottom'
$list.Font            = [System.Drawing.Font]::new('Segoe UI', 11)
$list.IntegralHeight  = $false
foreach ($c in $chapters) { [void]$list.Items.Add($c.BaseName) }
if ($list.Items.Count -gt 0) { $list.SelectedIndex = 0 }

$hint                 = [System.Windows.Forms.Label]::new()
$hint.Text            = 'Opening a document in vvvv is RUNNING it. Read it, close vvvv, then Normalize.'
$hint.Location        = [System.Drawing.Point]::new(12, 320)
$hint.Size            = [System.Drawing.Size]::new(576, 20)
$hint.Anchor          = 'Left,Right,Bottom'

$openBtn              = [System.Windows.Forms.Button]::new()
$openBtn.Text         = 'Open in vvvv'
$openBtn.Location     = [System.Drawing.Point]::new(12, 346)
$openBtn.Size         = [System.Drawing.Size]::new(180, 34)
$openBtn.Anchor       = 'Left,Bottom'

$normBtn              = [System.Windows.Forms.Button]::new()
$normBtn.Text         = 'Normalize (after closing vvvv)'
$normBtn.Location     = [System.Drawing.Point]::new(204, 346)
$normBtn.Size         = [System.Drawing.Size]::new(240, 34)
$normBtn.Anchor       = 'Left,Bottom'

$log                  = [System.Windows.Forms.TextBox]::new()
$log.Multiline        = $true
$log.ReadOnly         = $true
$log.ScrollBars       = 'Vertical'
$log.Font             = [System.Drawing.Font]::new('Consolas', 9)
$log.Location         = [System.Drawing.Point]::new(12, 392)
$log.Size             = [System.Drawing.Size]::new(576, 196)
$log.Anchor           = 'Left,Right,Bottom'
$log.Text             = "pick a chapter and press Open - or double-click it.`r`n"

# Run a tool script in a CHILD pwsh: the tools call `exit` on refusal, which would close this
# window if they ran in-process. The child's console output lands in the log box either way.
function Invoke-Tool([string]$scriptPath, [string[]]$toolArgs, [string]$doing) {
    $openBtn.Enabled = $false
    $normBtn.Enabled = $false
    $form.UseWaitCursor = $true
    $log.AppendText("`r`n== $doing`r`n")
    [System.Windows.Forms.Application]::DoEvents()
    try {
        $out = & pwsh -NoProfile -ExecutionPolicy Bypass -File $scriptPath @toolArgs 2>&1 | Out-String
        $log.AppendText($out)
        if ($LASTEXITCODE -ne 0) {
            $log.AppendText("`r`nREFUSED (exit $LASTEXITCODE) - the reason is above.`r`n")
        }
    }
    finally {
        $form.UseWaitCursor = $false
        $openBtn.Enabled = $true
        $normBtn.Enabled = $true
    }
}

$openChapter = {
    if ($list.SelectedIndex -lt 0) { return }
    $file = $chapters[$list.SelectedIndex].FullName
    Invoke-Tool $Launcher @('-Path', $file) "opening $($list.SelectedItem)"
}

$openBtn.Add_Click($openChapter)
$list.Add_DoubleClick($openChapter)
$normBtn.Add_Click({
    Invoke-Tool $Normalize @() 'normalizing help patches (vvvv must be closed)'
})

$form.Controls.AddRange(@($list, $hint, $openBtn, $normBtn, $log))
[void]$form.ShowDialog()
