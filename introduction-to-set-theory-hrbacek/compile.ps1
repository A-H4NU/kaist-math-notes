#!/usr/bin/env pwsh

using namespace System.IO;

param(
    [String]$TexPath='',
    [String]$Invalidate='None',
    [switch]$Verbose=$false,
    [switch]$Quiet=$false
)

[FileInfo]$texFile

if ($TexPath -eq '')
{
    if (@(Get-ChildItem *.tex).Count -ne 1)
    {
        Write-Error 'There must be only one TeX file in the directory.'
        Write-Error 'You may specify the path for TeX file via -TexPath'
        exit 1
    }
    $texFile = @(Get-ChildItem *.tex)[0]
} else
{
    if (-not (Test-Path $TexPath -PathType Leaf))
    {
        Write-Error "$TexPath does not exist!"
        exit 1
    }
    $texFile = Get-Item $TexPath
}

[DirectoryInfo]$texDir = $texFile.Directory
[String]$texDirWildcard = [System.IO.Path]::Combine($texDir.FullName, '*')

Write-Host "Compiling $(Resolve-Path -Relative $texFile)..."

$stopwatch = [System.Diagnostics.Stopwatch]::new()

Remove-Item $texDirWildcard -Include "*.auxlock"
Remove-Item $texDirWildcard -Include "*.synctex.gz"

if (($Invalidate -ieq 'all') -or ($Invalidate -ieq 'reference'))
{
    Write-Host "Invalidating references..."
    Remove-Item $texDirWildcard -Include "*.aux"
    Remove-Item $texDirWildcard -Include "*.toc"
}
if (($Invalidate -ieq 'all') -or ($Invalidate -ieq 'figure'))
{
    Write-Host "Invalidating figures..."
    Remove-Item $texDirWildcard -Include "*.md5"
    Remove-Item $texDirWildcard -Include "*.dep"
    Remove-Item $texDirWildcard -Include "*.dpth"
}

$stopwatch.Start()
$output = xelatex -file-line-error -interaction=nonstopmode -halt-on-error -shell-escape `
    -synctex=1 -output-directory="$($texDir.FullName)" "$($texFile.FullName)"
| Out-String
$stopwatch.Stop()

if ($LASTEXITCODE -ne 0)
{
    Write-Host "$output"
    if (-not $Quiet)
    {
        Write-Host -NoNewline "`a"
    }
    Write-Host "`n====================="
    Write-Host "Compile failed."
    Write-Host "There were some errors."
    Write-Host "Exit Code: $LASTEXITCODE"
} else
{
    if ($Verbose)
    {
        Write-Host "$output"
    }
    Write-Host "`n====================="
    Write-Host "Compile done."
}

Write-Host "Elapsed: $([Math]::Round($stopwatch.Elapsed.TotalSeconds, 3))s"
Write-Host "====================="

exit 0
