# Parameters
param(
    [string]$tenantId,  # Replace with your Azure AD Tenant ID
    [string]$clientId,  # Replace with your Application (client) ID
    [string]$scope = "api://312e13ac-497a-40a4-b98c-7da389fa0a86/user_impersonation",  # Replace with your API scope
    [string]$redirectUri = "http://localhost",  # Redirect URI configured in Azure AD
    [string]$clientSecret  # Optional: Include if your app has a client secret
)

# Authorization and Token Endpoints
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$authUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize"

# Construct the Authorization Request URL
$authRequest = "${authUrl}?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&scope=$scope&response_mode=query"

#$authRequest = "${authUrl}?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&scope=$scope"
# Open the browser for user authentication
Start-Process $authRequest

# Prompt the user to paste the authorization code
Write-Host "Please paste the authorization code from the browser:"
#$authCode = Read-Host "Authorization Code"
Add-Type -AssemblyName Microsoft.VisualBasic
$authCode = [Microsoft.VisualBasic.Interaction]::InputBox("Paste the authorization code below:", "Authorization Code Input", "")
write-host "Authorization Code: $authCode"

# Exchange the authorization code for an access token
$body = @{
    grant_type    = "authorization_code"
    client_id     = $clientId
    code          = $authCode
    redirect_uri  = $redirectUri
    scope         = $scope
    client_secret = $clientSecret  # Optional: Include if your app has a client secret
}

$response = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body $body -ContentType "application/x-www-form-urlencoded"

$response

# Extract the access token
$accessToken = $response.access_token
Write-Host "access Token: $accessToken"

# Decode the token to verify the claims (optional)
$decodedToken = $accessToken -split '\.' | Select-Object -Index 1
$decodedJson = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($decodedToken))
Write-Host "Decoded Token: $decodedJson"