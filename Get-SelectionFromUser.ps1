<#
.SYNOPSIS
    Get a selection from the user from a list of options

.DESCRIPTION
    This function prompts the user to select an option from a list of options. 
    The user can select an option by entering the corresponding number. 
    The function returns the selected option.

.NOTES
    Author: Brian Fruehling
    Version: 1.0
    Date Written: Jan-2025

.INPUTS
    [string[]]$Options - An array of options to display to the user
    [string]$Prompt - The prompt to display to the user

.OUTPUTS
    Returns the selected option as a string

.EXAMPLE
    $options = @("Option 1", "Option 2", "Option 3")
    $selectedOption = Get-SelectionFromUser -Options $options -Prompt "Please select an option"
    Write-Host "You selected: $selectedOption"
#>
function Get-SelectionFromUser {
  param (
      [Parameter(Mandatory=$true)]
      [string[]]$Options,
      [Parameter(Mandatory=$true)]
      [string]$Prompt        
  )
  
  [int]$Response = 0;
  [bool]$ValidResponse = $false    

  # Add an "Exit" option to the list
  $Options += "Exit"

  while (!($ValidResponse)) {            
      [int]$OptionNo = 0
      Write-Host
      $padLength = $options.count.ToString().Length
      foreach ($Option in $Options) {
          $OptionNo += 1
          $paddedOptionNo = $OptionNo.ToString().PadLeft($padLength, ' ')
          Write-Host ("[$paddedOptionNo]: {0}" -f $Option)
      }
      Write-Host -NoNewLine "$Prompt`: " -ForegroundColor DarkYellow
      if ([Int]::TryParse((Read-Host), [ref]$Response)) {
          if($Response -le $OptionNo -and $response -gt 0 -and $response -match "\d") { $ValidResponse = $true }
          else { Write-Host "Invalid selection. Please try again." -ForegroundColor Red }
      }
  }
  return $Options.Get($Response - 1)
} 