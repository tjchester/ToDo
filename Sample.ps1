Import-Module -Name ToDo -Force

$File = Join-Path -Path $([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath "todo.txt"

If (Test-Path -Path $File -PathType Leaf)
{
    Remove-Item -Path $File
}

function Format-ToDo
{
    param(
        $Collection
    )
    
    $Collection | Select-Object -Property LineNumber,Priority,Text,Contexts,Projects | Sort-Object Priority,Text | Format-Table -AutoSize
 }


Add-ToDo -Text "Make peace between Cylons and humans"
#TODO: 'Make peace between Cylons and humans' added on line 1.

Add-ToDo -Text "Upgrade jump drives with Cylon technology" -Projects "GalacticaRepairs"
#TODO: 'Upgrade jump drives with Cylon technology +GalacticaRepairs' added on line 2.

Add-ToDo -Text "Seal ship's cracks with biomatter" -Projects "GalacticaRepairs"
#TODO: 'Seal ship's cracks with biomatter +GalacticaRepairs' added on line 3.

Add-ToDo -Text "Check for DRADIS contact" -Contexts "CIC"
#TODO: 'Check for DRADIS contact @CIC' added on line 4.

Add-ToDo -Text "Report to Admiral Adama about FTL" -Contexts "CIC" -Projects "GalacticaRepairs"
#TODO: 'Report to Admiral Adama about FTL @CIC +GalaticaRepairs' added on line 4.

Format-ToDo $(Get-ToDo)

#04 Check for DRADIS contact @CIC
#01 Make peace between cylons and humans
#05 Report to Admiral Adama about FTL @CIC +GalacticaRepairs
#03 Seal ship's cracks with biomatter +GalacticaRepairs
#02 Upgrade jump drives with Cylon technology +GalacticaRepairs
#--
#TODO: 5 tasks in C:/Documents and Settings/gina/My Documents/todo.txt

Format-ToDo $(Get-ToDo -SearchProject "GalacticaRepairs")

#05 Report to Admiral Adama about FTL @CIC +GalacticaRepairs
#03 Seal ship's cracks with biomatter +GalacticaRepairs
#02 Upgrade jump drives with Cylon technology +GalacticaRepairs

Format-ToDo $(Get-ToDo -SearchText "Cylon")

#01 Make peace between cylons and humans
#02 Upgrade jump drives with Cylon technology +GalacticaRepairs

Format-ToDo $(Get-ToDo -SearchProject "GalacticaRepairs" -SearchContext "CIC")

#05 Report to Admiral Adama about FTL @CIC +GalacticaRepairs

Set-ToDo -LineNumber 3 -Priority "A"

#3: (A) Seal ship's cracks with biomatter +GalacticaRepairs
#TODO: 3 prioritized (A).

Format-ToDo $(Get-ToDo)

#03 (A) Seal ship's cracks with biomatter +GalacticaRepairs  <-- yellow
#04 Check for DRADIS contact @CIC
#01 Make peace between cylons and humans
#05 Report to Admiral Adama about FTL @CIC +GalacticaRepairs
#02 Upgrade jump drives with Cylon technology +GalacticaRepairs
#--
#TODO: 5 tasks in C:/Documents and Settings/gina/My Documents/todo.txt

Set-ToDo -LineNumber 2 -Priority "A"

#2: (A) Upgrade jump drives with Cylon technology +GalacticaRepairs
#TODO: 2 prioritized (A).

Set-Todo -LineNumber 1 -Priority "B"

#1: (B) Make peace between Cylons and humans
#TODO: 1 prioritized (B).

Set-Todo -LineNumber 4 -Priority "C"

#4: (C) Check for DRADIS contact @CIC
#TODO: 4 prioritized (C).

Format-ToDo $(Get-ToDo)

#03 (A) Seal ship's cracks with biomatter +GalacticaRepairs  <-- yellow
#02 (A) Upgrade jump drives with Cylon technology +GalacticaRepairs  <-- yellow
#01 (B) Make peace between cylons and humans <-- green
#04 (C) Check for DRADIS contact @CIC <-- blue
#05 Report to Admiral Adama about FTL @CIC +GalacticaRepairs
#--
#TODO: 5 tasks in C:/Documents and Settings/gina/My Documents/todo.txt

Format-ToDo $(Get-Todo -PrioritizedOnly $true)
 
#03 (A) Seal ship's cracks with biomatter +GalacticaRepairs  <-- yellow
#02 (A) Upgrade jump drives with Cylon technology +GalacticaRepairs  <-- yellow
#01 (B) Make peace between cylons and humans <-- green
#04 (C) Check for DRADIS contact @CIC <-- blue
#--
#TODO: 4 prioritized tasks in C:/Documents and Settings/gina/My Documents/todo.txt

Set-ToDo -LineNumber 2 -Priority " "

#2: Upgrade jump drives with Cylon technology +GalacticaRepairs
#TODO: 2 deprioritized.

Format-ToDo $(Get-ToDo)

#03 (A) Seal ship's cracks with biomatter +GalacticaRepairs  <-- yellow
#01 (B) Make peace between cylons and humans <-- green
#04 (C) Check for DRADIS contact @CIC <-- blue
#05 Report to Admiral Adama about FTL @CIC +GalacticaRepairs
#02 Upgrade jump drives with Cylon technology +GalacticaRepairs
#--
#TODO: 5 tasks in C:/Documents and Settings/gina/My Documents/todo.txt

Set-ToDo -LineNumber 1 -MarkCompleted

#1: x 2009-02-17 Make peace between Cylons and humans
#TODO: 1 marked as done.
#x 2009-02-17 Make peace between Cylons and humans
#TODO: C:/Documents and Settings/gina/My Documents/todo.txt archived.

Format-ToDo $(Get-ToDo)

#03 (A) Seal ship's cracks with biomatter +GalacticaRepairs  <-- yellow
#04 (C) Check for DRADIS contact @CIC <-- blue
#05 Report to Admiral Adama about FTL @CIC +GalacticaRepairs
#02 Upgrade jump drives with Cylon technology +GalacticaRepairs
#--
#TODO: 4 tasks in C:/Documents and Settings/gina/My Documents/todo.txt
