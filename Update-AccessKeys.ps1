[CmdletBinding(SupportsShouldProcess=$true)]
Param(
  [Parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$userName,
  [Parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$profileName,
  [Parameter(mandatory=$false)][ValidateSet("Credential","File")][string]$outputType = "File",
  [Parameter(mandatory=$false)][string]$outputPath = "$home\AWSNewAccessKeys"
)

process {

  #get current key
  $oldKey = Get-IAMAccessKey -username $userName -ProfileName $profileName -Region cn-northwest-1
  
  #check if key is over 90 days old
  if ($oldKey) { $keyAge = (Get-Date) - $oldKey.CreateDate }
  
  if ($keyAge.Days -lt 90 -and $oldKey) {
    write-host "Access key for $userName in $profileName is only $($keyAge.Days) days old. Rotation not needed (requires 90+ days)." -ForegroundColor Yellow
    return
  }

  if ($oldKey.Count -gt 1) {
    write-host "User $userName in $profileName has $($oldKey.Count) access keys. Rotation skipped (requires exactly 1 key)." -ForegroundColor Yellow
    return
  }
  
  if ($oldKey) { write-host "Access key is $($keyAge.Days) days old. Rotating..." -ForegroundColor Green }
  else { write-host "No access key found for $userName in $profileName. Creating new access key..." -ForegroundColor Green }
  
  if ($PSCmdlet.ShouldProcess("$userName in $profileName", "Create new access key")) {
    #create new access key
    $newKey=New-IAMAccessKey -userName $userName -ProfileName $profileName -Region cn-northwest-1
    #update credential
    if ($outputType -eq "Credential") {
      Set-AWSCredential -StoreAs $profileName -AccessKey $newKey.AccessKeyId -SecretKey $newKey.SecretAccessKey 
    }
    else {
      $fileName = "$outputPath\${userName}_${profileName}_AccessKey.txt"
      $newKey | Out-File -FilePath $fileName -Force
      write-host "Access key saved to: $fileName" -ForegroundColor Cyan
    }
    #delete old access key
    start-sleep -seconds 10
    if ($oldKey -and $PSCmdlet.ShouldProcess("$userName in $profileName", "Delete old access key $($oldKey.AccessKeyId)")) {
      Remove-IAMAccessKey -AccessKeyId $oldKey.AccessKeyId -ProfileName $profileName -username $userName -Confirm:$false -Region cn-northwest-1
    }
    Get-IAMAccessKey -username $userName -ProfileName $profileName -Region cn-northwest-1
    write-host "Updated Access Key for $userName in $profileName" -ForegroundColor Green
  }
}