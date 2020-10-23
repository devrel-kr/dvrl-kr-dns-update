Param(
    [string]
    [Parameter(Mandatory=$true)]
    $CertificateResourceGroupName,

    [string]
    [Parameter(Mandatory=$true)]
    $CertificateName,

    [string]
    [Parameter(Mandatory=$false)]
    $ApiVersion = "2018-11-01"
)

$clientId = ($env:AZURE_CREDENTIALS | ConvertFrom-Json).clientId
$clientSecret = ($env:AZURE_CREDENTIALS | ConvertFrom-Json).clientSecret | ConvertTo-SecureString -AsPlainText -Force
$tenantId = ($env:AZURE_CREDENTIALS | ConvertFrom-Json).tenantId
$subscriptionId = ($env:AZURE_CREDENTIALS | ConvertFrom-Json).subscriptionId

$credentials = New-Object System.Management.Automation.PSCredential($clientId, $clientSecret)

$connected = Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $tenantId

# Get Access Token
$tokenCachedItems = (Get-AzContext).TokenCache.ReadItems()
$tokenCachedItem = $tokenCachedItems | Where-Object { $_.ClientId -eq $clientId }
$accessToken = ConvertTo-SecureString -String $tokenCachedItem.AccessToken -AsPlainText -Force

# Get Existing Certificate Details
$epoch = ([DateTimeOffset](Get-Date)).ToUnixTimeMilliseconds()
$endpoint = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Web/certificates/{2}" -f $subscriptionId, $CertificateResourceGroupName, $CertificateName

$cert = Invoke-RestMethod -Method GET `
    -Uri "{0}?api-version={1}&_={2}" -f $endpoint, $ApiVersion, $epoch`
    -ContentType "application/json" `
    -Authentication Bearer `
    -Token $accessToken
$certJson = $cert | ConvertTo-Json

$certJson

# Sync Certificate
$result = Invoke-RestMethod -Method PUT `
    -Uri "{0}?api-version={1}" -f $endpoint, $ApiVersion`
    -ContentType "application/json" `
    -Authentication Bearer `
    -Token $accessToken `
    -Body $certJson

$status = $result.properties.keyVaultSecretStatus

# Set Output
if ($status.ToLower() -eq "succeeded") {
    Write-Output "::set-output name=updated::$true"
} else {
    Write-Output "::set-output name=updated::$false"
}
