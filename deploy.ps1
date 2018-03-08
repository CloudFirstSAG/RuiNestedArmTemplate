<#
 .SYNOPSIS
    Deploys a template to Azure  

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 
 .PARAMETER deployType
   The deploy type. Options can be: Test or New.


 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

.PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER templateFilePath
   Path to the template file. 
#>


param(
    #[Parameter(Mandatory=$True)]
    [string]
    $deployType="Test",
    
    #[Parameter(Mandatory=$True)]
    [string]
    $subscriptionId="7ea7be65-ca57-4517-b54c-819295b4c9b4",

    #[Parameter(Mandatory=$True)]
    [string]
    $resourceGroupName="AD003SharedService-Northeurope-Prod-RG",

    #[Parameter(Mandatory=$True)]
    [string]
    #$templateFilePath="https://code.siemens.com/DEC/SharedServices/AzureAD003DomainJoin/raw/master/Peerings/prodTemplate.json"
    $templateFilePath="https://raw.githubusercontent.com/CloudFirstSAG/RuiNestedArmTemplate/master/prodTemplate.json"
)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.network");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

  
# Start the deployment
Write-Host "Starting deployment...";
if($deployType = "New") {
    New-AzureRmResourceGroupDeployment -Mode Incremental -ResourceGroupName $resourceGroupName -TemplateUri $templateFilePath
}
elseif ($deployType = "Test") {
    Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateFilePath
}
Write-Host "End deployment.";


