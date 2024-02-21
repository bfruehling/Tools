<#
.SYNOPSIS
    Create a new powershell script using the template.ps1 template

.DESCRIPTION
    Create a new script, validate the file doesn't exist first, then create the script and open in code

.NOTES
    Author: Brian Fruehling
    Version: 1.0
    License: GPL
    Date Written: 21-Feb-2024

.INPUTS
    Filename - name of the script to be created, it will add .ps1 if not specified

.OUTPUTS
    File that is created

.EXAMPLE
    New-Script -filename New-PowershellScript.ps1

    Creates a new script 
#>

[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    #<parameter comment>
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
    [string]$filename
) 

begin {
  $logfile = "$home\$($MyInvocation.MyCommand.Name)-$(get-date -Format FileDatetime).log"
  Start-Transcript -Path $logfile | out-host
  $template=".\data\template.ps1"
}

process {
    if (!(Test-Path $filename)) {
      if ($filename -notmatch '\.ps1$') { $filename = $filename + ".ps1"}
      Copy-Item $template $filename
      code $filename
    }
    else {
        Write-warning "$filename exists"
        continue
    }

}

end {
  if($PSCmdlet.ShouldProcess($logfile,"Stop-Transcript")) {Stop-Transcript|out-host}
}