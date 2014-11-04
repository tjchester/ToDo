# ToDo List Manager PowerShell Module #

This is a PowerShell module to help manage a **todo** text file inspired by the original implementation documented at [Todo.txt](http://todotxt.com/).

## Installation ##

To install this module, place the *ToDo* folder and its contents in the *modules* folder of your PowerShell *profile* folder.

On a Windows 7 or 8 computer, this path would typically be:

`C:\Users\UserName\Documents\WindowsPowerShell\Modules\

>NOTE: From a PowerShell prompt you can execute:
>
	PS> Split-Path $profile -Parent

>This will give you your PowerShell profile directory location and may still require you to manually create the *Modules* subfolder.

## Running Tests ##

If you have installed [Pester](https://github.com/pester/Pester) you can run the unit tests using:

	PS> cd $(Split-Path $profile -Parent)
	PS> cd .\Modules\ToDo\Tests
	PS> .\Execute-Test.ps1

## Available Cmdlets ##

	PS> Import-Module -Name ToDo
	PS> Get-Command -Module ToDo

	CommandType     Name                                               ModuleName
	-----------     ----                                               ----------
	Function        Add-ToDo                                           ToDo
	Function        Get-ToDo                                           ToDo
	Function        Remove-ToDo                                        ToDo
	Function        Set-ToDo                                           ToDo
	Filter          Format-ColoredRow                                  ToDo

## Examples ##

> These examples are inspired by this [screencast](http://vimeo.com/3263629)

First we need to import the module and create a helper function that will handle the display of our todo lists.

	PS> Import-Module -Name ToDo -Force
	PS> function Format-ToDo
	>> {
	>>     param(
	>>         $Collection
	>>     )
	>>
	>>     $Collection | Select-Object -Property LineNumber,Priority,Text,Contexts,Projects `
	>>                 | Sort-Object Priority,Text | Format-Table -AutoSize
	>>  }
	>>

Now we add a simple todo.

	PS> Add-ToDo -Text "Make peace between Cylons and humans"
	TODO: 'Make peace between Cylons and humans' added on line 1.

Now we will add a few todo's that are associated with a project.

	PS> Add-ToDo -Text "Upgrade jump drives with Cylon technology" -Projects "GalacticaRepairs"
	TODO: 'Upgrade jump drives with Cylon technology +GalacticaRepairs' added on line 2.

	PS> Add-ToDo -Text "Seal ship's cracks with biomatter" -Projects "GalacticaRepairs"
	TODO: 'Seal ship's cracks with biomatter +GalacticaRepairs' added on line 3.

Now we will add a project associated with a context.

	PS> Add-ToDo -Text "Check for DRADIS contact" -Contexts "CIC"
	TODO: 'Check for DRADIS contact @CIC' added on line 4.

Next we will add a todo associated with both a project and a context.

	PS> Add-ToDo -Text "Report to Admiral Adama about FTL" -Contexts "CIC" -Projects "GalacticaRepairs"
	TODO: 'Report to Admiral Adama about FTL @CIC +GalacticaRepairs' added on line 5.

Finally we display our list so far.

	PS> Format-ToDo $(Get-ToDo)
	TODO: 5 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                                      Contexts Projects
	---------- -------- ----                                      -------- --------
	         4          Check for DRADIS contact                  {CIC}    {}
	         1          Make peace between Cylons and humans      {}       {}
	         5          Report to Admiral Adama about FTL         {CIC}    {GalacticaRepairs}
	         3          Seal ship's cracks with biomatter         {}       {GalacticaRepairs}
	         2          Upgrade jump drives with Cylon technology {}       {GalacticaRepairs}

Let's say that we only want to see todo items associated with a specific project.

	PS> Format-ToDo $(Get-ToDo -SearchProject "GalacticaRepairs")
	TODO: 3 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                                      Contexts Projects
	---------- -------- ----                                      -------- --------
	         5          Report to Admiral Adama about FTL         {CIC}    {GalacticaRepairs}
	         3          Seal ship's cracks with biomatter         {}       {GalacticaRepairs}
	         2          Upgrade jump drives with Cylon technology {}       {GalacticaRepairs}

Or maybe just a specific context.

	PS> Format-ToDo $(Get-ToDo -SearchText "Cylon")
	TODO: 2 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                                      Contexts Projects
	---------- -------- ----                                      -------- --------
	         1          Make peace between Cylons and humans      {}       {}
	         2          Upgrade jump drives with Cylon technology {}       {GalacticaRepairs}

Or possibly both a specific project and in a specific context.

	PS> Format-ToDo $(Get-ToDo -SearchProject "GalacticaRepairs" -SearchContext "CIC")
	TODO: 1 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                              Contexts Projects
	---------- -------- ----                              -------- --------
	         5          Report to Admiral Adama about FTL {CIC}    {GalacticaRepairs}

Now we will assign the highest priority to the task at line number 3.

	PS> Set-ToDo -LineNumber 3 -Priority "A"
	PS> Format-ToDo $(Get-ToDo)
	TODO: 5 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                                      Contexts Projects
	---------- -------- ----                                      -------- --------
	         4          Check for DRADIS contact                  {CIC}    {}
	         1          Make peace between Cylons and humans      {}       {}
	         5          Report to Admiral Adama about FTL         {CIC}    {GalacticaRepairs}
	         2          Upgrade jump drives with Cylon technology {}       {GalacticaRepairs}
	         3 A        Seal ship's cracks with biomatter         {}       {GalacticaRepairs}

And let us assign various priorities to the other todo items.

	PS> Set-ToDo -LineNumber 2 -Priority "A"
	PS> Set-Todo -LineNumber 1 -Priority "B"
	PS> Set-Todo -LineNumber 4 -Priority "C"
	PS> Format-ToDo $(Get-ToDo)
	TODO: 5 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                                      Contexts Projects
	---------- -------- ----                                      -------- --------
	         5          Report to Admiral Adama about FTL         {CIC}    {GalacticaRepairs}
	         3 A        Seal ship's cracks with biomatter         {}       {GalacticaRepairs}
	         2 A        Upgrade jump drives with Cylon technology {}       {GalacticaRepairs}
	         1 B        Make peace between Cylons and humans      {}       {}
	         4 C        Check for DRADIS contact                  {CIC}    {}

It is kind of cluttered with the non-prioritized and prioritized items mixed together so let us just display the items that have assigned priorities.

	PS> Format-ToDo $(Get-Todo -PrioritizedOnly $true)
	TODO: 4 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                                      Contexts Projects
	---------- -------- ----                                      -------- --------
	         3 A        Seal ship's cracks with biomatter         {}       {GalacticaRepairs}
	         2 A        Upgrade jump drives with Cylon technology {}       {GalacticaRepairs}
	         1 B        Make peace between Cylons and humans      {}       {}
	         4 C        Check for DRADIS contact                  {CIC}    {}

Now we will remove the priority from the todo at line number 2.

	PS> Set-ToDo -LineNumber 2 -Priority " "
	PS> Format-ToDo $(Get-ToDo)
	TODO: 5 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                                      Contexts Projects
	---------- -------- ----                                      -------- --------
	         5          Report to Admiral Adama about FTL         {CIC}    {GalacticaRepairs}
	         2          Upgrade jump drives with Cylon technology {}       {GalacticaRepairs}
	         3 A        Seal ship's cracks with biomatter         {}       {GalacticaRepairs}
	         1 B        Make peace between Cylons and humans      {}       {}
	         4 C        Check for DRADIS contact                  {CIC}    {}

Finally let us mark the todo at line number 1 completed.

	PS> Set-ToDo -LineNumber 1 -MarkCompleted
	PS> Format-ToDo $(Get-ToDo)
	TODO: 4 tasks in C:\Users\Thomas\Documents\todo.txt
	--
	
	LineNumber Priority Text                                      Contexts Projects
	---------- -------- ----                                      -------- --------
	         5          Report to Admiral Adama about FTL         {CIC}    {GalacticaRepairs}
	         2          Upgrade jump drives with Cylon technology {}       {GalacticaRepairs}
	         3 A        Seal ship's cracks with biomatter         {}       {GalacticaRepairs}
	         4 C        Check for DRADIS contact                  {CIC}    {}

## Getting Help ##

All of the cmdlets have built-in help that can access using the Get-Help cmdlet.

- For basic help: *Get-Help [cmdlet name]*; for example, ```Get-Help Add-ToDo```
- For detailed help: *Get-Help [cmdlet name] -Full*; for example ```Get-Help Add-ToDo -Full```

> Only minimal help is available currently.

## See Also ##

- [Todo.txt](http://todotxt.com/) - The inspiration for this implementation and documenation on file formats
- [Microsoft Script Center](http://technet.microsoft.com/en-us/scriptcenter/bb410849.aspx)	

Copyright (c) 2014 Thomas Chester. This software is licensed under the MIT License.