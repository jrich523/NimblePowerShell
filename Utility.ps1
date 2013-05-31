Function New-DynamicParam {
param(
[string]
$Name,
[string[]]
$Options,
[switch]
$Manditory,
[string]
$SetName="__AllParameterSets",
[int]
$Position,
[switch]
$ValueFromPipelineByPropertyName,
[string]
$HelpMessage

)
    #param attributes   
    $ParamAttr = New-Object System.Management.Automation.ParameterAttribute
    $ParamAttr.ParameterSetName = $SetName
    if($Manditory){ $ParamAttr.Mandatory = $True }
    if($Position -ne $null){$ParamAttr.Position=$Position}
    if($ValueFromPipelineByPropertyName){$ParamAttr.ValueFromPipelineByPropertyName = $True}
    if($HelpMessage){$ParamAttr.HelpMessage = $HelpMessage}

    ##param validation set
    $ParamOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $options

    $AttributeCollection = New-Object 'Collections.ObjectModel.Collection[System.Attribute]' 
    $AttributeCollection.Add($ParamAttr)
    $AttributeCollection.Add($ParamOptions)

    $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter `
    -ArgumentList @($Name, [string], $AttributeCollection)
            
    $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $Dictionary.Add($Name, $Parameter)
    $Dictionary
}