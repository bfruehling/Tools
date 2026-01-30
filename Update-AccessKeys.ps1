Param(
  [Parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$userName,
  [Parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$profileName
)

process {
  #get current key
  $oldKey = Get-IAMAccessKey -username $userName -ProfileName $profileName -Region cn-northwest-1
  
  #check if key is over 90 days old
  $keyAge = (Get-Date) - $oldKey.CreateDate
  
  if ($keyAge.Days -lt 90) {
    write-host "Access key for $userName in $profileName is only $($keyAge.Days) days old. Rotation not needed (requires 90+ days)." -ForegroundColor Yellow
    return
  }

  if ($oldKey.Count -gt 1) {
    write-host "User $userName in $profileName has $($oldKey.Count) access keys. Rotation skipped (requires exactly 1 key)." -ForegroundColor Yellow
    return
  }
  
  write-host "Access key is $($keyAge.Days) days old. Rotating..." -ForegroundColor Green
  #create new access key
  $newKey=New-IAMAccessKey -userName $userName -ProfileName $profileName -Region cn-northwest-1
  #update credential
  Set-AWSCredential -StoreAs $profileName -AccessKey $newKey.AccessKeyId -SecretKey $newKey.SecretAccessKey 
  #delete old access key
  start-sleep -seconds 10
  Remove-IAMAccessKey -AccessKeyId $oldKey.AccessKeyId -ProfileName $profileName -username $userName -Confirm:$false -Region cn-northwest-1
  Get-IAMAccessKey -username $userName -ProfileName $profileName -Region cn-northwest-1
  write-host "Updated Access Key for $userName in $profileName" -ForegroundColor Green
}