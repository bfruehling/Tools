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
    CurrentItemCount
    TotalItemCount
    CurrentStep

.OUTPUTS
    Progress Bar to Stdout

.EXAMPLE
    Show-ProgressETA -CurrentItemCount $i -TotalItemCount $total -CurrentStep "Processing $object"

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
    [string]$currentStep
  ) 

  $currentTime=Get-Date
  $comppct = $CurrentItemCount/$TotalItemCount
  $totalTime = [math]::round(($currentTime-$startTime).TotalSeconds/$comppct,2)
  $ETA =  $startTime.AddSeconds($totalTime)
  $comppctDisp=[math]::round($CurrentItemCount/$TotalItemCount*100,1).ToString("0.0")
  if (!($CurrentStep)) { $currentStep = "$currentItemCount/$TotalItemCount"}
  write-progress -Status "$($currentStep)" -Activity "[$comppctDisp% Complete, ETA: $($ETA.ToString("dd-MMM-yyyy HH:mm"))]" -PercentComplete $comppctDisp
}