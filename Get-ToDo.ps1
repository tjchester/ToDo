<#
.Synopsis 
   Gets a list of todo items
   
.Description
   Gets a list of todo items which can optionally include completed items and items that match a specified search text. The output
   list will be sorted by open items, then descending priority, then by order added to file, then by the todo text property.
   
.Notes
   The first line of the todo file is considered to be line 1.
   
.Example
   Get-ToDo
   
   Gets the set of all open todo items.

.Example
   Get-ToDo -IncludeCompleted
   
   Gets the set of all open and completed todo items.
   
.Example
   Get-ToDo -SearchText "Foo"
   
   Get the set of all open todo items that contain the text "Foo" in their text property.
      
.Parameter File
   The absolute or relative path of the todo file you want to remove the item from. If this is not specified, the default file will be C:\Users\UserName\Documents\todo.txt.

.Parameter IncludeCompleted
   If specified then the output will include completed items in the output as well as open items.
   
.Parameter SearchText
   The string value to be used to filter the returned set of items based on the todo text property.

.Parameter SearchProject
   The value to be used to filter the returned set of items that contain the specified project string.

.Parameter SearchContext
   The value to be used to filter the returned set of items that contain the specified context string.

.Parameter PrioritizedOnly
   If specified then the output will include only those items that have a priority value set.

#>
#.Example
#   Get-ToDo | Format-Table -AutoSize | Format-ColoredRow -Property "Priority" -ColorSchemes $ColorSchemes
#   
#   Gets the set of all open todo items, formats them as a table, and colorizes by priority.
function Get-ToDo
{
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $File=$null,
               
        [Parameter(Mandatory = $false)]
        [switch] $IncludeCompleted,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $SearchText = $null,

        [Parameter(Mandatory = $false)]
        [switch] $PrioritizedOnly,

        [Parameter(Mandatory = $false)]
        [string] $SearchProject = $null,

        [Parameter(Mandatory = $false)]
        [string] $SearchContext = $null
    )

    begin 
    {
        $File = Get-ToDoFileNameAndPath $File
    }
    
    process
    {
    	 $results = @(Get-ToDoFileContent -File $File `
                        | Where-Object { if ($SearchText) { $_.Text -match $SearchText } else { $true } } `
                        | Where-Object { if ($SearchProject) { $_.Projects -contains $SearchProject } else { $true } } `
                        | Where-Object { if ($SearchContext) { $_.Contexts -contains $SearchContext } else { $true } } `
                        | Where-Object { if ($IncludeCompleted) { $true } else {$_.Completed -eq $false } } `
                        | Where-Object { if ($PrioritizedOnly) { $_.Priority -ne $null } else { $true } } `
                        | Sort-Object -Property @{Expression="Text"; Descending=$false} -CaseSensitive `
                        | Select-Object LineNumber,CreatedDate,Priority,Projects,Text,Completed,CompletedDate,Contexts,Metadata)    
                        #| Sort-Object -Property @{Expression="Completed"   ; Descending=$false}, `
                        #                        @{Expression="Priority"    ; Descending=$false }, `
                        #                        @{Expression="LineNumber"  ; Descending=$false}, `
                        #                        @{Expression="Text"        ; Descending=$false}  `
                        #              -CaseSensitive `
                        #| Select-Object LineNumber,Text,Priority,Projects,Contexts,CreatedDate,Completed,CompletedDate,Metadata    

        $results
    }
    
    end
    {
        if ($results -eq $null)
        {
            Write-Host -ForegroundColor Green "TODO: 0 tasks in $File"
        }
        else
        {
            #Write-Host -ForegroundColor Black $results.GetType()
            Write-Host -ForegroundColor Green "TODO: $($results.Count) tasks in $File"
        }
        Write-Host -ForegroundColor Green "--"
    }
}
