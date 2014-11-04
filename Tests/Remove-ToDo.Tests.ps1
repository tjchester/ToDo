Import-Module ToDo -Force

$base_dir = split-path -parent $MyInvocation.MyCommand.Definition

$file = Join-Path -Path $base_dir -ChildPath "todo.txt"

Describe "Remove-ToDo" {
  
	Context "When a file contains two items and the last one is removed" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1","This is item 2"
	
		Remove-Todo -File $file -LineNumber 2
	
		$result = Get-ToDo -File $file
	
		It "will only contain the first item" {
			$result.Text | Should Be "This is item 1"
		}
	}
 
	Context "When a file contains three items and the second one is removed" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1","This is item 2","This is item 3"
	
		Remove-Todo -File $file -LineNumber 2
	
		$result = Get-ToDo -File $file
	
		It "will only contain the first and third items" {
			$result[0].Text | Should Be "This is item 1"
			$result[1].Text | Should Be "This is item 3"
		}
	}

	Context "When a file contains one item and it is removed" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1"
	
		Remove-Todo -File $file -LineNumber 1
	
		$result = Get-ToDo -File $file
	
		It "will contain no items" {
			$result | Should Be $null
		}
	}

	Context "When an invalid line number is specified" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1"
	
		Remove-Todo -File $file -LineNumber 2
	
		$result = Get-ToDo -File $file
	
		It "the file remains unchanged" {
			$result.Text | Should Be "This is item 1"
		}
	}
	
}
