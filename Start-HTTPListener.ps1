function Start-HttpListener {
  param (
    [int]$Port = 54559,
    [int]$Timeout = 60
  )

  # Create a listener
  $listener = New-Object System.Net.HttpListener
  $listener.Prefixes.Add("http://127.0.0.1:$Port/")
  $listener.Start()
  Write-Host "Listening for response on port $Port..."

  $startTime = Get-Date

  try {
    $contextTask = $listener.GetContextAsync()
    while (-not $contextTask.AsyncWaitHandle.WaitOne(200)) { 
      if ((Get-Date) -gt $startTime.AddSeconds($Timeout)) {
          $listener.Stop()
          $listener.Close()
          Write-Host "Listener stopped."
          break
      }
    }
    #get the context
    if ($listener.IsListening) {
      $context = $contextTask.GetAwaiter().GetResult()
      Write-Host "Received response"
      #Read Response
      $reader = New-Object System.IO.StreamReader $context.Request.InputStream
      $HTTPResponse = $reader.ReadToEnd()
      $reader.Close()

      #send response
      $context.Response.StatusCode = 200
      $context.Response.ContentType = 'application/json'
      $responseJson = 'Authentication complete. You can return to the command prompt. Feel free to close this browser tab.'
      $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
      $context.Response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
      start-sleep -Seconds 1
      $context.Response.Close() # end the response
      return $HTTPResponse
    }
  } finally {
      if ($listener.IsListening) {$listener.Stop();Write-Host "Listener stopped."}
      if ($listener) {$listener.Close()}
  }
}