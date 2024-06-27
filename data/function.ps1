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
Function FunctionName {
  [CmdletBinding()]
    Param(
        #<parameter comment>
        [Parameter(ValueFromPipelineByPropertyName,Mandatory=$true)]
        [string]$var
    ) 
}