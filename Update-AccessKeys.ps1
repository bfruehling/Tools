Param(
  [Parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$userName,
  [Parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$profileName
)

process {
  #get current key
  $oldKey = Get-IAMAccessKey -username $userName -ProfileName $profileName -Region cn-northwest-1
  #create new access key
  $newKey=New-IAMAccessKey -userName $userName -ProfileName $profileName -Region cn-northwest-1
  #update credential
  Set-AWSCredential -StoreAs $profileName -AccessKey $newKey.AccessKeyId -SecretKey $newKey.SecretAccessKey 
  #delete old access key
  start-sleep -seconds 10
  Remove-IAMAccessKey -AccessKeyId $oldKey.AccessKeyId -ProfileName $profileName -username $userName -Confirm:$false -Region cn-northwest-1
  Get-IAMAccessKey -username $userName -ProfileName $profileName -Region cn-northwest-1
  write-host "Updated Access Key for $userName in $profileName"
}