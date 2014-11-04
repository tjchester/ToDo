Import-Module ToDo -Force

$base_dir = split-path -parent $MyInvocation.MyCommand.Definition

$file = Join-Path -Path $base_dir -ChildPath "todo.txt"

Describe "Add-ToDo" {

    Context "When an item is added" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1"
		
		$result = Get-ToDo -File $file
	
		It "will be saved with its text property set" {
			$result.Text | Should Be "This is item 1"
		}
	}

    Context "When an item is added with a priority of 'B'" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1" -Priority "B"
		
		$result = Get-ToDo -File $file
	
		It "will be saved with a priority of 'B'" {
			$result.Text | Should Be "This is item 1"
            $result.Priority | Should Be "B"
		}
	}

    Context "When an item is added with a specified created date" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1" -CreatedDate "2014-10-31"
		
		$result = Get-ToDo -File $file
	
		It "will be saved that created date" {
			$result.Text | Should Be "This is item 1"
            $result.CreatedDate | Should Be "2014-10-31"
		}
	}

    Context "When an item is added without a created date" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1"
		
		$result = Get-ToDo -File $file
	
		It "will be saved that the current date" {
			$result.Text | Should Be "This is item 1"
            $result.CreatedDate | Should Be $("{0:yyyy-MM-dd}" -f (Get-Date))
		}
	}

    Context "When a completed item is added with a specified completion date" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1" -Completed $true -CompletedDate "2014-10-31"
		
		$result = Get-ToDo -File $file -IncludeCompleted $true
	
		It "will be saved that completed date" {
			$result.Text | Should Be "This is item 1"
            $result.Completed | Should Be $true
            $result.CompletedDate | Should Be "2014-10-31"
		}
	}

    Context "When a completed item is added without a completion date" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1" -Completed $true
		
		$result = Get-ToDo -File $file -IncludeCompleted $true
	
		It "will be saved with the current date" {
			$result.Text | Should Be "This is item 1"
            $result.Completed | Should Be $true
            $result.CompletedDate | Should Be $("{0:yyyy-MM-dd}" -f (Get-Date))
		}
	} 

    Context "When an item is added with a specified completion date but not marked completed" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1" -CompletedDate "2014-10-31"
		
		$result = Get-ToDo -File $file
	
		It "will be saved without the specified completed date" {
			$result.Text | Should Be "This is item 1"
            $result.Completed | Should Be $false
            $result.CompletedDate | Should Be ""
		}
	}
 
     Context "When an item is added a list of projects" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1" -Projects "Project1","Project2"
        Add-ToDo -File $file -Text "This is item 2" -Projects "Project1"
		
		$result = Get-ToDo -File $file
	
		It "will be saved with those projects" {
			$result[0].Text | Should Be "This is item 1"
            $result[0].Projects.Count | Should Be 2
            $result[0].Projects[0] | Should Be "Project1"
            $result[0].Projects[1] | Should Be "Project2"

			$result[1].Text | Should Be "This is item 2"
            $result[1].Projects.Count | Should Be 1
            $result[1].Projects[0] | Should Be "Project1"
		}
	}

     Context "When an item is added a list of contexts" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1" -Contexts "Context1","Context2"
        Add-ToDo -File $file -Text "This is item 2" -Contexts "Context1"
		
		$result = Get-ToDo -File $file
	
		It "will be saved with those contexts" {
			$result[0].Text | Should Be "This is item 1"
            $result[0].Contexts.Count | Should Be 2
            $result[0].Contexts[0] | Should Be "Context1"
            $result[0].Contexts[1] | Should Be "Context2"

            $result[1].Text | Should Be "This is item 2"
            $result[1].Contexts.Count | Should Be 1
            $result[1].Contexts[0] | Should Be "Context1"
		}
	}

     Context "When an item is added a list of metadata (key:value pairs)" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Add-ToDo -File $file -Text "This is item 1" -Metadata "Key1:Value1","Key2:Value2"
        Add-ToDo -File $file -Text "This is item 2" -Metadata "Key1:Value1"
		
		$result = Get-ToDo -File $file
	
		It "will be saved with that metadata" {
			$result[0].Text | Should Be "This is item 1"
            $result[0].Metadata.Count | Should Be 2
            $result[0].Metadata[0] | Should Be "Key1:Value1"
            $result[0].Metadata[1] | Should Be "Key2:Value2"

            $result[1].Text | Should Be "This is item 2"
            $result[1].Metadata.Count | Should Be 1
            $result[1].Metadata[0] | Should Be "Key1:Value1"
		}
	}
}
