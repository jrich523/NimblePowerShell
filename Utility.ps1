function New-DynamicParam {
param(
[string]
$Name,
[string[]]
$Options=$null,
[switch]
$Mandatory,
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
    if($Mandatory){ $ParamAttr.Mandatory = $True }
    if($Position -ne $null){$ParamAttr.Position=$Position}
    if($ValueFromPipelineByPropertyName){$ParamAttr.ValueFromPipelineByPropertyName = $True}
    if($HelpMessage){$ParamAttr.HelpMessage = $HelpMessage}

    $AttributeCollection = New-Object 'Collections.ObjectModel.Collection[System.Attribute]' 
    $AttributeCollection.Add($ParamAttr)

    if($Options)
    {
        $ParamOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $options
        $AttributeCollection.Add($ParamOptions)
    }

    $Parameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter `
    -ArgumentList @($Name, [string], $AttributeCollection)
            
    $Dictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    $Dictionary.Add($Name, $Parameter)
    $Dictionary
}


function Convert-SecureStringToString
{
param([securestring]$securestring)
    $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($securestring)
    [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
}


function Convert-NSTime
{
param($dt)
(new-object DateTime 1970,1,1,0,0,0,([DateTimeKind]::Utc)).addseconds($dt)
}