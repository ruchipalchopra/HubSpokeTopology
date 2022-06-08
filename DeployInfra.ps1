param(
    [string] $preferences = "./Preferences/Dev.psm1"
)

Import-Module $Preferences -force

Add-Type -AssemblyName System.Web

Function ToParamsFilePath([string] [Parameter(Position=0, ValueFromPipeline=$true)] $Filename)
{
    return join-path -Path "./Parameters" -ChildPath $Filename
}

$webClient = New-Object -TypeName System.Net.WebClient
$webClient.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
Write-Host "Logging In to Azure......"

try
{
# Login (logs for all powershell sessions)
Connect-AzAccount -Tenant $tenantId -Subscription $subscriptionId
Write-Host "Logged In to Azure"

$resourceGroup = New-AzDeployment -Location $defaultLocation -TemplateFile "./ARM/CreateResourceGroup.json" -TemplateParameterFile("ResourceGroup.parameters.json" | ToParamsFilePath)

$resourceGroupName = $resourceGroup.Parameters['rgName'].Value
Write-Host "Resource Group $resourceGroupName Deployed"


New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "./ARM/HubandSpokemodel.json"
Write-Host "Hub Virtual Network and Subnets deployed"

} 
catch 
{
    #Catch general exceptions and ensure proper debug logging is output.
    Write-Host "Something went wrong"
    Write-Host $_.ScriptStackTrace
    Write-Host $_.Exception
    Write-Host $_.ErrorDetails
}
finally 
{
    #Logout a connected azure account.
    Write-Host "Logging out of Azure"
   # Disconnect-AzAccount
}