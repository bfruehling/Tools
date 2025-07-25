Param(
  [Parameter(Mandatory=$true)]
  [string]$username
)

$profiles = Get-AWSCredentials -ListProfileDetail 
$output = foreach ($profile in $profiles) {
  $compPct = $profiles.IndexOf($profile) / $profiles.Count * 100
  write-progress -activity "Processing Profile" -status $profile.profileName -PercentComplete $compPct
  $user=get-IAMUser -userName $username -profileName $profile.profileName
  $mfa=Get-IAMMfaDevice -userName $username -profileName $profile.profileName
  $AK=Get-IAMAccessKey -userName $username -profileName $profile.profileName
  [psCustomObject]@{ 
    ARN=$user.arn
    profile=$profile.profileName
    LastUsed=$user.PasswordLastUsed
    MFA=$MFA.SerialNumber
    AKCreateDate=$AK.createDate
  }
} 
$output | ft -a