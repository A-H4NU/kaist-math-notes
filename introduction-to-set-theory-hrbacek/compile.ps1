#!/usr/bin/env pwsh

using namespace System.IO;

param(
    $texPath='',
    $invalidate='None',
    [switch]$verbose=$false
)

[FileInfo]$texFile

if ($texPath -eq '')
{
    if (@(Get-ChildItem *.tex).Count -ne 1)
    {
        Write-Error 'There must be only one TeX file in the directory.'
        Write-Error 'You may specify the path for TeX file via --texPath'
        exit 1
    }
    $texFile = @(Get-ChildItem *.tex)[0]
} else
{
    if (-not (Test-Path $texPath -PathType Leaf))
    {
        Write-Error "$texPath does not exist!"
        exit 1
    }
    $texFile = Get-Item $texPath
}

[DirectoryInfo]$texDir = $texFile.Directory
[String]$texDirWildcard = [System.IO.Path]::Combine($texDir.FullName, '*')

Write-Host "Compiling $(Resolve-Path -Relative $texFile)..."

# $OriginalPwd = $pwd

$stopwatch = [System.Diagnostics.Stopwatch]::new()

Remove-Item $texDirWildcard -Include "*.auxlock"
Remove-Item $texDirWildcard -Include "*.synctex.gz"

if (($invalidate -ieq 'all') -or ($invalidate -ieq 'reference'))
{
    Write-Host "Invalidating references..."
    Remove-Item $texDirWildcard -Include "*.aux"
    Remove-Item $texDirWildcard -Include "*.toc"
}
if (($invalidate -ieq 'all') -or ($invalidate -ieq 'figure'))
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
    Write-Host ""
    Write-Host "====================="
    Write-Host "Compile failed."
    Write-Host "There were some errors." "Exit Code: $LASTEXITCODE"
} else
{
    if ($verbose)
    {
        Write-Host "$output"
    }
    Write-Host ""
    Write-Host "====================="
    Write-Host "Compile done."
}

Write-Host "Total $($stopwatch.Elapsed.TotalSeconds) seconds elapsed."
Write-Host "====================="

exit 0
# Set-Location $OriginalPwd
