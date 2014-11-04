<#
.Synopsis 
   Updates an existing todo item
   
.Description
   Updates an existing todo item.
   
.Notes
   The first line of the todo file is considered to be line 1.
   
.Example
   Set-ToDo -LineNumber 1 -MarkCompleted $True
   
   Marks the todo item at line 1 completed.
     
.Example
   Set-ToDo -LineNumber 3 -Priority A
   
   Assigns a priority leve A (highest) to the todo item at line 3.

.Parameter File
   The absolute or relative path of the todo file you want to remove the item from. If this is not specified, the default file will be C:\Users\UserName\Documents\todo.txt.

.Parameter LineNumber
   The number of the line of the todo item you want to update. The first line of the file is 1.

.Parameter MarkCompleted
   The todo item will be assigned a completion date of today.

.Parameter MarkNotCompleted
   The todo item will be re-opened by clearing its completion date.

.Parameter Priority
   The todo item will be assigned a new priority. The priority is optional. 'A' represents the highest priority and 'Z' represents the lowest priority.
   Multiple todo items may be assigned the same priority level.
   
#>
function Set-ToDo
{
    param(        
        [Parameter(Mandatory = $true, Position = 0)]
        [int] $LineNumber,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $File=$null,
                
        [Parameter(Mandatory = $false)]
        [switch] $MarkCompleted,
        
        [Parameter(Mandatory = $false)]
        [switch] $MarkNotCompleted,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [ValidatePattern("[ A-Z!]")]
        [string] $Priority
    )
   	    
    begin 
    {
        $File = Get-ToDoFileNameAndPath $File
        $ToDos = @($(Get-ToDoFileContent -File $File))
    }

    process
    {
        $CompletedDate = "{0:yyyy-MM-dd}" -f (Get-Date)
            
        $ToDo = $ToDos | Where-Object { $_.LineNumber -eq $LineNumber }
        
        if ($ToDo -eq $null)
        {
            #Write-Host -ForegroundColor Yellow "Unable to update item on line $LineNumber"
            $ToDo = ""
        }
        else
        {
            if ($MarkCompleted)
            {
                $ToDo.Completed = $true
                $ToDo.CompletedDate = $CompletedDate
            }
            
            if ($MarkNotcompleted)
            {
                $ToDo.Completed = $false
                $ToDo.CompletedDate = $null            
            }
            
            if ($Priority)
            {
                $ToDo.Priority = $Priority
            }

            #Write-Host -ForegroundColor Green "Updated '$($ToDo.Text)'"
            
        }
    }
    
    end
    {
        Set-ToDoFileContent -File $File -ToDos $ToDos
    }
}

