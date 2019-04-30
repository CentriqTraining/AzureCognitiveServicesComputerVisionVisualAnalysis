$demoResourceGroupName="centriqazuredemo"
$keys = New-Object -TypeName psobject

$acctDetails=Get-AzureRmContext
if ([string]::IsNullOrEmpty($acctDetails.Account)) {
    $null=Connect-AzureRmAccount 
}
$prog+=5
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
$resourceGroupList=Get-AzureRmResourceGroup | Select -ExpandProperty ResourceGroupName
if ($demoResourceGroupName -in $resourceGroupList) {
    Write-Host "* Using existing Resource Group $($demoResourceGroupName)"
} else {
    Write-Host "* Creating Resource Group $($demoResourceGroupName)..." -NoNewline
    $null=New-AzureRmResourceGroup -Name $demoResourceGroupName -Location 'East US' -ErrorAction SilentlyContinue -ErrorVariable $rgfail
    if ($rgfail) {
        Write-Host "* ERROR: Creating $($demoResourceGroupName)"
    } else {
        Write-Host "Success" 
    }
}

$types=@{
ComputerVision="demovision"
}
$cognitiveServices = Get-AzureRmCognitiveServicesAccount -ResourceGroupName $demoResourceGroupName | select -ExpandProperty AccountName 
foreach ($type in $types.keys)  {
    if ($types[$type] -in @($cognitiveServices)) {
        Write-Host  "* Cognitive Services Account ($($type)) Account exists for $($types[$type])"
    } else  {
        if ($type -eq "Bing.Search.v7") {
            Write-Host "* Creating Cognitive Services  ($($type)) called $($types[$type])..." -NoNewline
            $null=New-AzureRmCognitiveServicesAccount -Location 'global' -Name $types[$type] -SkuName "F0" -ResourceGroupName $demoResourceGroupName -Type $type -Force 3> $null -ErrorVariable $safail
        } else {
            Write-Host "* Creating Cognitive Services ($($type)) called $($types[$type])..." -NoNewline
            $null=New-AzureRmCognitiveServicesAccount -Location 'East US' -Name $types[$type] -SkuName "F0" -ResourceGroupName $demoResourceGroupName -Type $type -Force 3> $null -ErrorVariable $safail
        }
        if ($safail) {
            Write-Host "* Error: Creating $($types[$type])" 
        } else {
            Write-Host "Success"
        }
    }
    $prog+=5
    Write-Host "* Fetch key for $($type)"
    $keys | Add-Member -MemberType NoteProperty -Name $type -Value $(Get-AzureRmCognitiveServicesAccountKey -ResourceGroupName $demoResourceGroupName -Name $types[$type] | Select -ExpandProperty key2)
}

Write-Host "* Writing key file Keys.json"
$keys
Add-Content Keys.json $($keys | ConvertTo-Json)

