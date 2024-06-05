<#
.SYNOPSIS
Creates a new random password, to replace Windows Powershell system.web.security GeneratePassword Method

.DESCRIPTION
The function takes 0-9 parameters to create a new random password. The length of the password, the minimum number of 
each character class, and whether the output should be a secure string can all be specified.  The minimum password
length is 4, the maximum is the Int32 limit and the password will have characters from each character class; 
uppercase, lowercase, numeric and special characters. If the sum of all of the minimum values is greater than the specified 
length, the length will be increased to the sum of the minimum values.  The character classes can be specified if necessary.

.NOTES
Date Written: Oct-2021
Author: Brian Fruehling
Version:  1.0

.INPUTS
None, does not accept pipeline input

.OUTPUTS
System.String
System.Security.SecureString if -secure flag is used

.EXAMPLE
New-Password -length 20 -minspecial 5 

Set a length of 20 with at least 5 special characters and output as a plain text string
.EXAMPLE
New-Password -length 15 -minspecial 3 -secure

Set a length of 15 with at least 3 special characters and output as a secure string object
.EXAMPLE
New-Password -length 40 -specials '-_.~'

Generate a password with a length of 40 and using only the specified special characters and default characters from the three other classes
#>
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
       
    $CharacterList = @{
      Upper = @{Elements=($Uppers); Min=$MinUpper}
      Lower = @{Elements=($Lowers); Min=$MinLower}
      Digit = @{Elements=($Digits); Min=$MinDigit}
      Special = @{Elements=($Specials); Min=$MinSpecial}
    }
    $Length = ($($MinSpecial+$MinUpper+$MinLower+$MinDigit),$Length|Measure-Object -Maximum).Maximum
    $CharacterList['All']= @{Elements=$Lowers+$Uppers+$Digits+$Specials; Min=$Length - $CharacterList.Digit.Min - $CharacterList.Lower.Min - $CharacterList.Special.Min - $CharacterList.Upper.Min}
    
    $Password=($(foreach($Key in $CharacterList.Keys) {
      If($CharacterList.$key.Min){(0..($CharacterList.$Key.Min-1)) | Foreach-object {
        $CharacterList[$Key]['Elements'][$(get-random -minimum 0 -maximum $CharacterList[$Key]['Elements'].length)]
      }} 
    }) | Get-Random -Count $Length) -join ""

    If(!($Secure)){$Password}
    Else{$Password | ConvertTo-SecureString -AsPlainText}
}