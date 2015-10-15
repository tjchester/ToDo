Import-Module ToDo -Force

$base_dir = split-path -parent $MyInvocation.MyCommand.Definition

$file = Join-Path -Path $base_dir -ChildPath "todo.txt"

Describe "Get-ToDo" {
  
    Context "When file does not exist" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		$result = Get-ToDo -File $file

        It "it contains no items" {
			$result | Should Be $null
        }
    }

	Context "When an item is added to the file" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1"
			
		$result = Get-ToDo -File $file
		
		It "contains one items" {
		  $result.Text | Should Be "This is item 1"
		}
	}
	
	Context "When a priority item is added to the file" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "(A) This is item 1"
			
		$result = Get-ToDo -File $file
		
		It "contains one item" {
		  $result.Text | Should Be "This is item 1"
		}
		
		It "has the specified priority" {
		  $result.Priority | Should Be "A"
		}
	}
	
	Context "When a priority item is added to the file with a specific create date" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "(A) 2014-11-03 This is item 1"
			
		$result = Get-ToDo -File $file
		
		It "contains one item" {
		  $result.Text | Should Be "This is item 1"
		}
		
		It "has the specified priority" {
		  $result.Priority | Should Be "A"
		}
		
		It "has the specified create date" {
		  $result.CreatedDate | Should Be "2014-11-03"
		}
	}
	
	Context "When two items are added to the file" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1", "This is item 2"
			
		$result = Get-ToDo -File $file
		
		It "contains two items" {
		  $result.Count | Should Be 2
		}
	}
	
<#
    Context "When a file contains prioritized and non-prioritized items" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1", "(A) This is item 2"
			
		$result = Get-ToDo -File $file
		
		It "will display prioritized items first" {
		  $result[0].Text | Should Be "This is item 2"
          $result[1].Text | Should Be "This is item 1"
		}
    }
#>

    Context "When a file contains completed items" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "x 2014-10-31 This is item 1"

        It "will only display them if the include completed flag is true" {
            $result = Get-ToDo -File $file -IncludeCompleted
            $result.Text | Should Be "This is item 1"
        }

        It "will not display them if the include completed flag is false" {
            $result = Get-ToDo -File $file
            $result | Should Be $null
        }
    }

    Context "When a search term is supplied" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item foo"

        It "will only display items whose text contains the search term" {
            $result = Get-ToDo -File $file -SearchText "foo"
            $result.Text | Should Be "This is item foo"
        }

        It "will not display items whose text does not contain the search term" {
            $result = Get-ToDo -File $file -SearchText "bar"
            $result | Should Be $null
        }
    }

    Context "When a search project is supplied" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1 +Foo"

        It "will only display items whose project list contains the search term" {
            $result = Get-ToDo -File $file -SearchProject "foo"
            $result.Text | Should Be "This is item 1"
        }

        It "will not display items whose project list does not contain the search term" {
            $result = Get-ToDo -File $file -SearchProject "bar"
            $result | Should Be $null
        }
    }

    Context "When a search context is supplied" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "This is item 1 @Foo"

        It "will only display items whose context list contains the search term" {
            $result = Get-ToDo -File $file -SearchContext "foo"
            $result.Text | Should Be "This is item 1"
        }

        It "will not display items whose context list does not contain the search term" {
            $result = Get-ToDo -File $file -SearchContext "bar"
            $result | Should Be $null
        }
    }

    Context "When viewing a prioritized list" {
		If (Test-Path -Path $file) {
			Remove-Item -Path $file
		}

		Set-Content -Path $file -Value "(A) This is item 1","This is item 2"

        It "will only display items that have a priority set" {
            $result = @(Get-ToDo -File $file -PrioritizedOnly)
            $result.Count | Should Be 1
            $result.Text | Should Be "This is item 1"
            $result.Priority | Should Be "A"
        }

    }
    
}
