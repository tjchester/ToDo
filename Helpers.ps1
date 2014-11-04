function New-ToDoObjectFromTextLine([string] $line)
{
    if ($line -eq $null -Or $line.Trim() -eq "")
    {
        #Write-Host -ForegroundColor Yellow "New-ToDoObjectFromTextLine: New-ToDoObjectFromTextLine: Got empty line."
        return ""
    }

    New-ToDo $line

    #Write-Host "Input Line: $line"

    $completed = $false;
    $completedDate = "";
    $createdDate = "";
    $priority = "";
    $text = "";
    $contexts = @();
    $projects = @();
    $metadata = @();
    
    $patterns = @{
        "completed"     = "^x ";
        "completedDate" = "^(\d\d\d\d-\d\d-\d\d) ";
        "priority"      = "^\(([A-Z])\) ";
        "createdDate"   = "^(\d\d\d\d-\d\d-\d\d) ";
        "projects"      = " \+([^\s]+[\w_])";
        "contexts"      = " \@([^\s]+[\w_])";
        "metadata"      = " ([^\s:]+:[^\s:]+)";
    }
    
    # Complete Tasks
    # Rule 1: If a task starts with an x (case-sensitive lowercase) followed directly
    # by a space, it is complete.
    if ($line -cmatch $patterns["completed"])
    {
        $line = $line -replace $patterns["completed"], ""
    
        $completed = $true;
        
        # Rule 2: The date of completion appears directly after the x, separated by
        # a space. The date should be in "yyyy-mm-dd format".       
        $completedDate = [regex]::matches($line, $patterns["completedDate"]) | %{[string]$_.Groups[1]}

        $line = $line -replace $patterns["completedDate"], ""        
    }

    # Rule 1: If priority exists, it ALWAYS appears first. The priority is an uppercase character
    # from A-Z enclosed in parentheses and followed by a space.
    $priority = [regex]::matches($line, $patterns["priority"]) | %{[string]$_.Groups[1]}  
    $line = $line -replace $patterns["priority"]

    # Rule 2: A task's creation date may optionally appear directly after priority and
    # a space. If the creation date exists, it should be in format YYYY-MM-DD.
    $createdDate = [regex]::matches($line, $patterns["createdDate"]) | %{[string]$_.Groups[1]}
    $line = $line -replace $patterns["createdDate"]

    # Rule 3: Projects may appear anywhere in the line after priority/prepended date. A
    # project contains any non-whitespace character and must end in an alphanumeric or
    # a "_". A project is preceded by a "+" sign.
    $projects = @([regex]::matches($line, $patterns["projects"]) | %{[string]$_.Groups[1]})
    $line = $line -replace $patterns["projects"]

    # Rule 3: Contexts may appear anywhere in the line after priority/prepended date. A
    # context contains any non-whitespace character and must end in an alphanumeric or
    # a "_". A context is preceded by an "@" sign.
    $contexts = @([regex]::matches($line, $patterns["contexts"]) | %{[string]$_.Groups[1]})
    $line = $line -replace $patterns["contexts"]
    
    # In general, additional metadata should be defined as key:value pairs.
    $metadataItems = @([regex]::matches($line, $patterns["metadata"]) | %{[string]$_.Groups[1]})
    $line = $line -replace $patterns["metadata"], ""

    #foreach($item in $metadataItems)
    #{
    #    $key = $item.Split(":")[0]
    #    $value = $item.Split(":")[1]
    #    
    #    $metadata[$key] = $value
    #}

    New-Object -TypeName PSObject -Property @{
        'LineNumber' = 0;
        'Completed' = $completed;
        'CompletedDate' = $completedDate;
        'CreatedDate' = $createdDate;
        'Priority' = $priority;
        'Text' = $line.Trim();
        'Contexts' = $contexts;
        'Projects' = $projects;
        'Metadata' = $metadataItems;
    }

}

function New-TextLineFromToDoObject($todo)
{
    #Write-Host "Inside New-TextLineFromToDoObject"
    #Write-Host $todo

    $textLine = ""

    #Write-Host $(New-Todo $todo)

    if ($todo.Completed -eq $true)
    {
        $textLine += "x "
        $textLine += "{0:yyyy-MM-dd} " -f $todo.CompletedDate
    }

    if ($todo.Priority -cmatch "[A-Z]")
    {
        $textLine += "(" + $todo.Priority + ") "    
    }

    if ($todo.CreatedDate)
	{
		$textLine += "{0:yyyy-MM-dd} " -f $todo.CreatedDate
	}

    $textLine += $todo.Text + " "
    
	#Write-Host "TextLine:$textLine"
	
	if ($todo.Projects -ne $null -And $todo.Projects.Count -gt 0)
	{
		foreach ($project in $todo.Projects)
		{
			$textLine += "+" + $project + " "   
		}
    }
	
    if ($todo.Contexts -ne $null -And $todo.Contexts.Count -gt 0)
	{
		foreach ($context in $todo.Contexts)
		{
			$textLine += "@" + $context + " "
		}
	}
    
    if ($todo.Metadata -ne $null -And $todo.Metadata.Count -gt 0)
    {
        foreach ($pair in $todo.Metadata)
        {
            $textLine += " " + $pair
        }
    }
    
    $textLine
}

function Get-ToDoFileNameAndPath()
{
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $File = $null
    )

    if ($File -eq $null -Or $File -eq "")
    {
        $File = Join-Path -Path $([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments)) -ChildPath "todo.txt"
        
    }
	
    #Write-Host -ForegroundColor Green "Using todo file $File"

	if ($(Test-Path -Path "$File" -PathType Leaf) -eq $false)
    {
        #Write-Host -ForegroundColor Yellow "Get-ToDoFileNameAndPath: Default todo file does not exist, creating"
        Set-Content -Path "$File" -Value ""
    }
                
    return "$File"
}

function Get-ToDoFileContent
{
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $File = $null
    )

    $File = Get-ToDoFileNameAndPath $File
    
    $todos = @()
    
    [int] $lineNumber = 0;
    
    foreach($line in Get-Content -Path $File)
    {  
        if ($line -ne $null -And $line.Trim() -ne "")
        {
            $lineNumber += 1
            $todo = New-ToDoObjectFromTextLine $line
            $todo.LineNumber = $lineNumber;

            $todos += ,$todo
        }
    } 
    
    #Write-Host "Get-ToDoFileContent: List contains # items: " $todos.Count
    
    $todos
}

function Set-ToDoFileContent
{
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [object]$ToDos,
    
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [string] $File = $null
    )

	begin {
	    $File = Get-ToDoFileNameAndPath $File
		$contents = ""
	}

	process {
		if ($ToDos.Count -ne 0) {
			$contents = $ToDos | Sort-Object LineNumber | %{ (New-TextLineFromToDoObject $_).Trim() } | Where-Object { $_ -ne "" }
		}
    }
	
	end {
		Set-Content -Path $File -Value $contents
	}
}



filter Format-ColoredRow([string] $Property="Priority", $ColorSchemes)
{
    # Save the console's current color scheme
    $foregroundSaved = [console]::ForegroundColor
    $backgroundSaved = [console]::BackgroundColor

    try
    {       
        $colorScheme = $ColorSchemes[$_.Priority]
    
        if ($colorScheme)
        {
            if ($colorScheme["Foreground"] -ne 'System') { [console]::ForegroundColor = $colorScheme["Foreground"] }
            if ($colorScheme["Background"] -ne 'System') { [console]::BackgroundColor = $colorScheme["Background"] }
        }    
    }
    catch 
    {
    }
    finally
    {
        $_
    }
    
    # Restore the console's color scheme
    [console]::ForegroundColor = $foregroundSaved
    [console]::BackgroundColor = $backgroundSaved
}

function New-ToDo
{
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [object] $Item = [string] ""
    )
    
    begin
    {
        #Write-Host "DEBUG: New-ToDo called with type: " $Item.GetType()
        #Write-Host ">> $Item  "
    }
            
    process
    {
    
        if ($Item.GetType() -eq "System.String")
        {
            Return New-ToDoObjectFromTextLine $Item
        }
        elseif ($Item.GetType() -eq "System.Management.Automation.PSCustomObject")
        {
            Return New-TextLineFromToDoObject $Item
        }
       
    }
    
    end
    {
    
    }
}
