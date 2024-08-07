<#
.SYNOPSIS
    Show progress bar including an ETA for completion
.DESCRIPTION
    Show progress bar including an ETA for completion
.NOTES
    Author: Brian Fruehling
    Version: 1.0
    Date Written: 07-Jun-2024
.INPUTS
    Parameters Only no pipeline input
.OUTPUTS
    Progress Bar to Stdout
.EXAMPLE
    $startTime = Get-Date
    foreach ($item in $items) {
      Show-ProgressETA -currentItemCount $items.IndexOf($item) -totalItemCount $items.count -currentStep $item -startTime $startTime
    }

    Shows a progress bar with the current percent complete, the current step and an ETA to complete
#>
Function Show-ProgressETA {
  [CmdletBinding()]
  Param(
    #current progress count
    [Parameter(Mandatory=$true)]
    [int]$currentItemCount,
    #total progress count
    [Parameter(Mandatory=$true)]
    [int]$totalItemCount,
    #script start time
    [Parameter(Mandatory=$true)]
    [datetime]$startTime,
    #Active step being processed
    [string]$currentStep,
    #passthru for nested progress bars
    [int]$ID,
    #passthru for nested progress bars
    [int]$ParentId
  ) 
  $currentTime=Get-Date
  $comppct=$CurrentItemCount/$TotalItemCount
  if ($comppct -le 0) {
    $totalTime=0.0
    $ETA="Unknown"
    $comppctDisp = "0.0"
  }
  else {
    $totalTime=[math]::round(($currentTime-$startTime).TotalSeconds/$comppct,2)
    $ETA=$startTime.AddSeconds($totalTime).ToString("dd-MMM-yyyy HH:mm")
    $comppctDisp=[math]::round($comppct*100,1).ToString("0.0")
  }
  if (!($CurrentStep)) { $currentStep = "$currentItemCount/$TotalItemCount"}
  if (-not($ParentId) -and -not($id)) { $ID=1}
  $Activity="[$comppctDisp% Complete, ETA: $($ETA)]" 
  $padlength = 115 - $currentStep.length - $Activity.length
  if ($padlength -le 0) { $padding ='' } else { $padding = '.' * $padlength }
  write-progress -Status "$($currentStep+$padding)" -Activity $Activity -PercentComplete $comppctDisp -ParentId $ParentId -ID $ID
  return $($currenttime - $starttime |select Hours,minutes,seconds)
}