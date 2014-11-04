Import-Module ToDo -Force

$base_dir = split-path -parent $MyInvocation.MyCommand.Definition

$file = Join-Path -Path $base_dir -ChildPath "todo.txt"

Describe "Set-ToDo" {

    Context "When an item is marked completed" {

        If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1","This is item 2","This is item 3"
	
		Set-Todo -File $file -LineNumber 2 -MarkCompleted
	
		$result = Get-ToDo -File $file
	
		It "will no longer appears in the default list of items" {
			$result[0].Text | Should Be "This is item 1"
			$result[1].Text | Should Be "This is item 3"
		}
	}
  
    Context "When a completed item is marked not completed" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1","This is item 2","This is item 3"
	
		Set-Todo -File $file -LineNumber 2 -MarkCompleted
        Set-Todo -File $file -LineNumber 2 -MarkNotCompleted
	
		$result = Get-ToDo -File $file
	
		It "will appear in the default list of items" {
			$result[0].Text | Should Be "This is item 1"
            $result[1].Text | Should Be "This is item 2"
			$result[2].Text | Should Be "This is item 3"
		}
	}

    Context "When an item is given an 'A' priority" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1"
	
		Set-Todo -File $file -LineNumber 1 -Priority "A"
	
		$result = Get-ToDo -File $file
	
		It "will have its priority set to 'A'" {
			$result.Priority | Should Be "A"
		}
	}

    Context "When an item is given a ' ' (blank) priority" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "(A) This is item 1"
	
		Set-Todo -File $file -LineNumber 1 -Priority " "
	
		$result = Get-ToDo -File $file
	
		It "will have its priority cleared" {
			$result.Priority | Should Be ""
		}
	}

    Context "When an item is marked completed" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1"
	
		Set-Todo -File $file -LineNumber 1 -MarkCompleted
	
		$result = Get-ToDo -File $file -IncludeCompleted $true
	
		It "will have its completed flag set to true" {
			$result.Completed | Should Be $True
		}

        It "will have its completed date set to today" {
            $result.CompletedDate | Should Be $("{0:yyyy-MM-dd}" -f (Get-Date))
        }
	}

    Context "When a completed item is marked not completed" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "x 2014-11-03 This is item 1"
	
		Set-Todo -File $file -LineNumber 1 -MarkNotcompleted
	
		$result = Get-ToDo -File $file
	
		It "will have its completed flag set to false" {
			$result.Completed | Should Be $false
		}

        It "will have its completed date cleared" {
            $result.CompletedDate | Should Be ""
        }
	}

    Context "When an item is given an invalid priority" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "(A) This is item 1"
	
        It "will cause an exception to be thrown" {
		    { Set-Todo -File $file -LineNumber 1 -Priority "1" } | Should Throw
	    }

        $result = Get-ToDo -File $file 

		It "will have its current priority unchanged" {
    		$result.Priority | Should Be "A"
		}

	}

    Context "When an invalid line number is specified" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1"
	
		Set-Todo -File $file -LineNumber 2 -Priority "A"
	
		$result = Get-ToDo -File $file
	
		It "the file remains unchanged" {
			$result.Text | Should Be "This is item 1"
            $result.Priority | Should Be ""
		}
	}
}
