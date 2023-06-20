param([String]$invalidate='None')

$OriginalPwd = $pwd
$pdfName = (Split-Path -Path $PSScriptRoot -Leaf) + "_Note.tex"
Set-Location $PSScriptRoot
Write-Output "Compiling $PSScriptRoot\$pdfName."
$stopwatch = [System.Diagnostics.Stopwatch]::new()
Remove-Item .\*.auxlock
Remove-Item .\*.gz
if (($invalidate -ieq 'all') -or ($invalidate -ieq 'reference'))
{
	Write-Output "Invalidating references..."
	Remove-Item .\*.toc
	Remove-Item .\*.aux
}
if (($invalidate -ieq 'all') -or ($invalidate -ieq 'figure'))
{
	Write-Output "Invalidating figures..."
	Remove-Item .\*.md5
	Remove-Item .\*.dep
	Remove-Item .\*.dpth
}
$stopwatch.Start()
$output = & pdflatex -file-line-error -interaction=nonstopmode -halt-on-error -shell-escape -enable-write18 -synctex=1 -output-directory="$PSScriptRoot" $pdfName
if ($LASTEXITCODE -ne 0)
{
	Write-Output $output
	Write-Output "" "There were some errors." "Exit Code: $LASTEXITCODE"
}
else
{
	Write-Output "Compile done."
}
Write-Output "Total $($stopwatch.Elapsed.TotalSeconds) seconds elapsed."
Set-Location $OriginalPwd
