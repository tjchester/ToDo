Import-Module Pester

Invoke-Pester

$base_dir = split-path -parent $MyInvocation.MyCommand.Definition

$file = Join-Path -Path $base_dir -ChildPath "todo.txt"

If (Test-Path -Path $file) {
	Remove-Item -Path $file
}
