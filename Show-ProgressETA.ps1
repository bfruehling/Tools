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
    #pass thru for nested progress bars
    [int]$ID,
    #pass thru for nested progress bars
    [int]$ParentId
  ) 
  $currentTime=Get-Date
  $compPct=$CurrentItemCount/$TotalItemCount
  if ($compPct -le 0) {
    $totalTime=0.0
    $ETA="Unknown"
    $compPctDsp = "0.0"
  }
  else {
    $totalTime=[math]::round(($currentTime-$startTime).TotalSeconds/$compPct,2)
    $ETA=$startTime.AddSeconds($totalTime).ToString("dd-MMM-yyyy HH:mm")
    $compPctDsp=[math]::round($compPct*100,1).ToString("0.0")
  }
  if (!($CurrentStep)) { $currentStep = "$currentItemCount/$TotalItemCount"}
  if (-not($ParentId) -and -not($id)) { $ID=1}
  $Activity="[$compPctDsp% Complete, ETA: $($ETA)]" 
  $padLength = 115 - $currentStep.length - $Activity.length
  if ($padLength -le 0) { $padding ='' } else { $padding = '.' * $padLength }
  write-progress -Status "$($currentStep+$padding)" -Activity $Activity -PercentComplete $compPctDsp -ParentId $ParentId -ID $ID
  return $($currentTime - $starttime |Select-Object Hours,minutes,seconds)
}