<#
==============================================================================
vget - Windows PowerShell Native Wrapper
Role: Exécute vget depuis PowerShell avec préservation des arguments et flux TTY
==============================================================================
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ArgsList
)

$bashPath = $null
$candidates = @(
    "$env:ProgramFiles\Git\bin\bash.exe",
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
    "$env:LocalAppData\Programs\Git\bin\bash.exe",
    "$env:SystemDrive\msys64\usr\bin\bash.exe"
)

foreach ($c in $candidates) {
    if (Test-Path $c) {
        $bashPath = $c
        break
    }
}

if (-not $bashPath) {
    $found = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($found) {
        $bashPath = $found.Source
    }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vgetScript = Join-Path $scriptDir "bin\vget"

if ($bashPath) {
    $drive = $scriptDir.Substring(0, 1).ToLower()
    $subPath = $scriptDir.Substring(2).Replace('\', '/')
    $unixScript = "/$drive$subPath/bin/vget"
    & $bashPath -l $unixScript @ArgsList
    exit $LASTEXITCODE
}

if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
    wsl.exe bash -c "vget `$(wslpath -a '$vgetScript') $($ArgsList -join ' ')"
    exit $LASTEXITCODE
}

Write-Error "[vget] Erreur : Git Bash ou WSL requis sur Windows. Installez avec: winget install Git.Git"
exit 1
