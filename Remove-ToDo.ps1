<#
.Synopsis 
   Removes the todo item at the specified line number
   
.Description
   Removes the todo item at the specified line number
   
.Notes
   The first line of the todo file is considered to be line 1.
   
.Example
   Remove-ToDo -LineNumber 10
   
   Removes the todo item on line 10 in the file in the default location.
   
.Example
   Remove-ToDo 5 -File C:\ToDo.txt
   
   Removes the todo item at line 5 in the file C:\ToDo.txt.
      
.Parameter LineNumber
   The number of the line of the todo item you want to delete. The first line of the file is 1.
   
.Parameter File
   The absolute or relative path of the todo file you want to remove the item from. If this is not specified, the default file will be C:\Users\UserName\Documents\todo.txt.
#>
function Remove-ToDo
{
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [int] $LineNumber,
        
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $File=$null
    )
 
    begin 
    {
        $File = Get-ToDoFileNameAndPath $File
    }
    
    process 
    {        
        $ToDosRevised = @($(Get-ToDoFileContent -File $File))
        $PriorCount = $ToDosRevised.Count
        
        $ToDosRevised = @($ToDosRevised | Where-Object { $_.LineNumber -ne $LineNumber })
        $AfterCount = $ToDosRevised.Count
        
        if ($PriorCount -eq $AfterCount)
        {
            # Write-Host -ForegroundColor Yellow "Unable to remove item on line $LineNumber"
        }        
    }
    
    end 
    {	
        Set-ToDoFileContent -File $File -ToDos $ToDosRevised
    }
}
