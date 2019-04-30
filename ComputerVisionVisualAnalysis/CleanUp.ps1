$acctDetails=Get-AzureRmContext
if ([string]::IsNullOrEmpty($acctDetails.Account)) {
    $null=Connect-AzureRmAccount 
}
$subscriptions=Get-AzureRmSubscription -- | Select -ExpandProperty Name
Write-Host "* Logged in"

if (@($subscriptions).Count > 1) {
    $title="Choose subscription"
    $info="Choose the subscription to use for this demo.  Resources will be created on your behalf"
    $options=[System.Management.Automation.Host.ChoiceDescription[]]$subscriptions
    $optionChosen=$host.UI.PromptForChoice($title, $info, $options, 0)
}
else {
  $optionChosen = $subscriptions
}

$null=Select-AzureRmSubscription $optionChosen
Write-Host "* Subscription set"

$demoResourceGroupName="centriqazuredemo"
Remove-AzureRmResourceGroup -Name $demoResourceGroupName -Force
Write-Host "Resource Group Deleted"

Remove-Item "keys.json"
Write-Host "Key file deleted"
