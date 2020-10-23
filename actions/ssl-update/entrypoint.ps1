Param(
    [string]
    [Parameter(Mandatory=$true)]
    $ApiEndpoint,

    [string]
    [Parameter(Mandatory=$true)]
    $HostNames
)

# Issue new SSL certificate
$dnsNames = $HostNames -split ","
$body = @{ DnsNames = $dnsNames }
$issued = Invoke-RestMethod -Method Post -Uri $ApiEndpoint -ContentType "application/json" -Body ($body | ConvertTo-Json)

Write-Output "New SSL certificate has been issued to $HostNames"

Write-Output "::set-output name=updated::$true"
