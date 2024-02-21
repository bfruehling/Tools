<#
.SYNOPSIS
    <Enter a brief description of the script here>

.DESCRIPTION
    <Enter a detailed description of the script here>

.NOTES
    Author:
    Version:
    License:
    Date Written: 

.INPUTS
    <Enter any pipeline inputs here>

.OUTPUTS
    <Enter output details here>

.EXAMPLE
    <enter an example of the command here> (add additional .EXAMPLE entries for each example)

    <explain the example>
#>

#Requires -Modules @{ ModuleName="<Module Name>"; ModuleVersion="<Module Version>"} 
[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    #<parameter comment>
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
    [string]$var
) 

begin {
  $logfile = "$home\$($MyInvocation.MyCommand.Name)-$(get-date -Format FileDatetime).log"
  Start-Transcript -Path $logfile | out-host
}

process {

}

end {
  if($PSCmdlet.ShouldProcess($logfile,"Stop-Transcript")) {Stop-Transcript|out-host}
}