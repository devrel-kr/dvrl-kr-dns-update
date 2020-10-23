Param(
    [string]
    [Parameter(Mandatory=$true)]
    $AppResourceGroupName,

    [string]
    [Parameter(Mandatory=$true)]
    $AppName,

    [string]
    [Parameter(Mandatory=$true)]
    $ZoneResourceGroupName,

    [string]
    [Parameter(Mandatory=$true)]
    $ZoneName
)

$clientId = ($env:AZURE_CREDENTIALS | ConvertFrom-Json).clientId
$clientSecret = ($env:AZURE_CREDENTIALS | ConvertFrom-Json).clientSecret | ConvertTo-SecureString -AsPlainText -Force
$tenantId = ($env:AZURE_CREDENTIALS | ConvertFrom-Json).tenantId

$credentials = New-Object System.Management.Automation.PSCredential($clientId, $clientSecret)

$connected = Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $tenantId

# Add/Update A Record
$app = Get-AzResource -ResourceType Microsoft.Web/sites -ResourceGroupName $AppResourceGroupName -ResourceName $AppName
$newIp4Address = $app.Properties.inboundIpAddress

$rs = Get-AzDnsRecordSet -ResourceGroupName $ZoneResourceGroupName -ZoneName $ZoneName -Name "@" -RecordType A
$oldIp4Address = $rs.Records[0].Ipv4Address

if ($oldIp4Address -eq $newIp4Address) {
    Write-Output "No need to update A record"

    Write-Output "::set-output name=updated::$false"

    return
}

$rs.Records[0].Ipv4Address = $newIp4Address
$updated = Set-AzDnsRecordSet -RecordSet $rs

Write-Output "A record has been updated"

Write-Output "::set-output name=updated::$true"

return
