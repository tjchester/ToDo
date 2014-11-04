Set-StrictMode -version 2.0

# Determine our current operating directory
$base_dir = split-path -parent $MyInvocation.MyCommand.Definition

# Load module helper function file
. $base_dir\Helpers.ps1

# Load UI script responsible for adding todo's
. $base_dir\Add-ToDo.ps1

# Load UI script responsible for getting todo's
. $base_dir\Get-ToDo.ps1

# Load UI script responsible for deleting todo's
. $base_dir\Remove-ToDo.ps1

# Load UI script responsible for updating todo's
. $base_dir\Set-ToDo.ps1