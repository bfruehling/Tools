<#
.SYNOPSIS
Creates a new random password, to replace Windows Powershell system.web.security GeneratePassword Method

.DESCRIPTION
The function takes 0-6 parameters to create a new random password. The length of the password, the minimum number of 
each character class, and whether the output should be a secure string can all be specified.  The minimum password
length is 4, the maximum is the Int32 limit and the password will always have at least 1 character from each character class; 
uppercase, lowercase, numeric and special characters. If the sum of all of the minimum values is greater than the specified 
length, the length will be increase to the sum of the minimum values.

.NOTES
Date Written: Oct-2021
Author: Brian Fruehling
Version:  1.0

.INPUTS
None, does not accept pipeline input

.OUTPUTS
System.Security.SecureString
System.String if -insecure flag is used

.EXAMPLE
New-Password -length 20 -minspecial 5 -insecure

Set a length of 20 with at least 5 special characters and output as a plain text string
.EXAMPLE
New-Password -length 15 -minspecial 3

Set a length of 15 with at least 3 special characters and output as a secure string object
.EXAMPLE
New-Password

Use the defaults of a length of 12 and 1 special character and output a secure string object
#>
Function New-Password {
    [CmdletBinding()]
    param(
        #Specifies the desired length of the password, 12 is the default.  Minimum length of 4, length will be overridden if the sum of all the Min values is greater
        [ValidateRange(4, [Int32]::MaxValue)]
        [int] $Length = 12,
        #string of allowed uppercase characters
        [string] $Uppers='ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        #string of allowed lowercase characters
        [string] $Lowers='abcdefghijklmnopqrstuvwxyz',
        #string of allowed digits
        [string]  $Digits='0123456789',
        #string of allowed special characters
        [string] $Specials = '!@#$%^&*()_-+=[{]};:<>|./?',
        #Specifies the minimum number of Special characters in the password, 1 is the default. 
        [int] $MinSpecial = 1,
        #Specifies the minimum number of Upper Case characters in the password, 1 is the default. 
        [int] $MinUpper = 1,
        #Specifies the minimum number of Lower Case characters in the password, 1 is the default. 
        [int] $MinLower = 1,
        #Specifies the minimum number of Numeric characters in the password, 1 is the default. 
        [int] $MinDigit = 1,
        #Specifies the password to be output in plain text
        [switch] $Insecure
    )
       
    $CharacterList = @{
      Upper = @{Elements=($Uppers); Min=$MinUpper}
      Lower = @{Elements=($Lowers); Min=$MinLower}
      Digit = @{Elements=($Digits); Min=$MinDigit}
      Special = @{Elements=($Specials); Min=$MinSpecial}
    }
    $Length = ($($MinSpecial+$MinUpper+$MinLower+$MinDigit),$Length|Measure-Object -Maximum).Maximum
    $CharacterList['All']= @{Elements=$Lowers+$Uppers+$Digits+$Specials; Min=$Length - $CharacterList.Digit.Min - $CharacterList.Lower.Min - $CharacterList.Special.Min - $CharacterList.Upper.Min}
    
    $Password=foreach ($Key in $CharacterList.Keys){
      If($CharacterList.$key.Min){(0..($CharacterList.$Key.Min-1)) | Foreach-object {
        $CharacterList[$Key]['Elements'][$(get-random -minimum 0 -maximum $CharacterList[$Key]['Elements'].length)]
      }} 
    } | Get-Random -Count $Length) -join ""

    If($Insecure){$Password}
    Else{$Password | ConvertTo-SecureString -AsPlainText}
}
