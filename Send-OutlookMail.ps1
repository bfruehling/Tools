
  $outlook = New-Object -ComObject Outlook.Application
  $AWSAttachments = (Get-ChildItem -Path C:\users\v0x0706\AWSNewUsers\*$(get-date -format "ddMMMyyyy")*.csv).VersionInfo.Filename
  #$EntraAttachments = (Get-ChildItem -Path C:\users\v0x0706\AzureNewUsers\*.txt | where { $_.CreationTime -gt $(get-date).AddDays(-1)}).VersionInfo.Filename
  $AWSTemplate = "C:\Users\V0X0706\AppData\Roaming\Microsoft\Templates\CFC AWS Credentials.oft"
  $EntraTemplate = "C:\Users\V0X0706\AppData\Roaming\Microsoft\Templates\Singapore Entra Credentials.oft" 
  $attachments = $AWSAttachments
  $template = $AWSTemplate
  foreach ($attachment in $attachments) { 
     $mail = $outlook.CreateItemFromTemplate($Template)
     $mail.Attachments.Add($attachment)
     $mail.To = $attachment.split("\")[-1].split("-")[0]
     $mail.Send()
  }