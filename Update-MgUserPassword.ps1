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

[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    #<parameter comment>
    [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
    [object]$user
) 

begin {
  Function New-Password {
    [CmdletBinding()]
    param(
        #Specifies the desired length of the password, 12 is the default.  Minimum length of 4, length will be overridden if the sum of all the Min values is greater
        [ValidateRange(4,[Int32]::MaxValue)]
        [int]$Length = 12,
        #string of allowed uppercase characters
        [string]$Uppers = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        #string of allowed lowercase characters
        [string]$Lowers = 'abcdefghijklmnopqrstuvwxyz',
        #string of allowed numeric characters
        [string]$Digits = '0123456789',
        #string of allowed special characters
        [string]$Specials = '!@#$%^&*()_-+=[{]};:<>|./?',
        #Specifies the minimum number of special characters in the password, 1 is the default. 
        [ValidateRange(1,[Int32]::MaxValue)]
        [int]$MinSpecial = 1,
        #Specifies the minimum number of upper case characters in the password, 1 is the default. 
        [ValidateRange(1,[Int32]::MaxValue)]
        [int]$MinUpper = 1,
        #Specifies the minimum number of lower case characters in the password, 1 is the default. 
        [ValidateRange(1,[Int32]::MaxValue)]
        [int]$MinLower = 1,
        #Specifies the minimum number of numeric characters in the password, 1 is the default. 
        [ValidateRange(1,[Int32]::MaxValue)]
        [int]$MinDigit = 1,
        #Specifies the password to be output as a secure string
        [switch]$Secure
    )
       
    $Length = ($($MinSpecial+$MinUpper+$MinLower+$MinDigit),$Length|Measure-Object -Maximum).Maximum
    $CharacterList = @{
      Upper = @{Elements=$Uppers; Min=$MinUpper}
      Lower = @{Elements=$Lowers; Min=$MinLower}
      Digit = @{Elements=$Digits; Min=$MinDigit}
      Special = @{Elements=$Specials; Min=$MinSpecial}
      All = @{Elements=$Lowers+$Uppers+$Digits+$Specials; Min=$Length-$MinUpper-$MinLower-$MinDigit-$MinSpecial}
    }
    
    $Password=($(foreach($Key in $CharacterList.Keys) {
      If($CharacterList.$key.Min){(0..($CharacterList.$Key.Min-1)) | Foreach-object {
        $CharacterList[$Key]['Elements'][$(get-random -minimum 0 -maximum $CharacterList[$Key]['Elements'].length)]
      }} 
    }) | Get-Random -Count $Length) -join ""

    If(!($Secure)){$Password}
    Else{$Password | ConvertTo-SecureString -AsPlainText}
  }
  $outputdir = "$home\AzureNewUsers"
  $logfile = "$home\logs\$($MyInvocation.MyCommand.Name)-$(get-date -Format FileDatetime).log"
  Start-Transcript -Path $logfile | out-host
}

process {
    $password = New-Password -Length 16 -Specials "@%^&-_"
    $params = @{
      passwordProfile = @{
	    forceChangePasswordNextSignIn = $true
	    password = $password
	  }
  }
    Write-Output "Updating Password for $($user.UserPrincipalName)"
    update-mguser -userid $user.id -bodyparameter $params
    Set-Content $password -Path "$outputDir\$($user.UserPrincipalName).txt"
}

end {
  if($PSCmdlet.ShouldProcess($logfile,"Stop-Transcript")) {Stop-Transcript|out-host}
}