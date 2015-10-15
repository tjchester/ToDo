<#
.Synopsis 
   Adds a new item to the list of todos
   
.Description
   Adds a new item to the list of todos.
   
.Notes
   The first line of the todo file is considered to be line 1.
   
.Example
   Add-ToDo -Text "This is a test"
   
   Adds a new todo item with a description of "This is a test".
      
.Example
   Add-ToDo -Text "Pick up milk" -Projects Errands -Context Car -Priority M
   
   Adds a low priority errand to pick up milk while driving home.

.Parameter Text
   This is the main description for this todo item.
        
.Parameter Completed
   The todo will be created and marked completed. The current date will be used unless the CompletionDate parameter is supplied.

.Parameter CompletedDate
   The todo will be created and marked completed with the specified date. The date should be input in YYYY-MM-DD format.
        
.Parameter Priority
   The todo item will be assigned the specified priority. 'A' represents the highest priority and 'Z' represents the lowest priority.
   Multiple todo items may be assigned the same priority level.

.Parameter Projects
   This comman separated list of strings will assign a list of project names this todo is associated with.
        
.Parameter Contexts
   This comma separated list of strings will assign contexts to the todo item.
        
.Parameter CreatedDate
   The todo will be created with the current date unless this parameter is supplied then this date will be used. The date should be input in YYYY-MM-DD format.
        
.Parameter Metadata
   This is an arrya of key:value pairs that can define additional data for the todo item. Both the
   key and value should not contain any whitespace characters or the colon character. An example of
   a metadata item might be "Due:3Days".
	 
.Parameter File
   The absolute or relative path of the todo file you want to remove the item from. If this is not specified, the default file will be C:\Users\UserName\Documents\todo.txt.
#>
function Add-ToDo
{
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Text,
        
        [Parameter(Mandatory = $false)]
        [switch] $Completed,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $CompletedDate,        
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [ValidatePattern("[A-Z]")]
        [string] $Priority,
     
        [Parameter(Mandatory = $false)]
        [AllowEmptyCollection()]
        [string[]] $Projects,
        
        [Parameter(Mandatory = $false)]
        [AllowEmptyCollection()]
        [string[]] $Contexts,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $CreatedDate,
        
        [Parameter(Mandatory = $false)]
        [AllowEmptyCollection()]
        [string[]] $Metadata,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $File=$null                
    )
   	
    begin
    {
        $File = Get-ToDoFileNameAndPath $File
        $ToDos = @($(Get-ToDoFileContent -File $File))
    }
    
    process
    {
        if (!($CreatedDate))
        {
            $CreatedDate = "{0:yyyy-MM-dd}" -f (Get-Date)
        }
        
        if ($Completed -And (!($CompletedDate)))
        {
            $CompletedDate = "{0:yyyy-MM-dd}" -f (Get-Date)
        }
        
        if (!$Completed)
        {
            $CompletedDate = ""
        }

        $ToDo = New-Object -TypeName PSObject -Property @{
            'Completed'     = $Completed;
            'CompletedDate' = $CompletedDate;
            'CreatedDate'   = $CreatedDate;
            'Priority'      = $Priority;
            'Text'          = $Text.Trim();
            'Contexts'      = $Contexts;
            'Projects'      = $Projects;
            'Metadata'      = $Metadata;
        }

        $ToDos += $Todo
        
        $project_list = ""
        if ($ToDo.Projects) {
            foreach($project in $ToDo.Projects) {
                $project_list += " +$project"
            }
        }

        $context_list = ""
        if ($ToDo.Contexts) {
            foreach($context in $ToDo.Contexts) {
                $context_list += " @$context"
            }
        }

        Write-Host -ForegroundColor Green "TODO: '$($ToDo.Text)$($context_list)$($project_list)' added on line $($ToDos.Count)."

    }
    
    end 
    {
        Set-ToDoFileContent -File $File -ToDos $ToDos
    }
}
