<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-NSInitiatorGroup
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,Position=0)]
        $Name
    )

    Begin
    {
        $rtnigrp = @()
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        $igrp = New-Object initiatorgrp
        $rtncode = $Script:NSUnit.getinitiatorgrpList($sid.Value, [ref]$igrp)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error getting volume list! code: $rtncode" -ErrorAction Stop
        }
            
    }
    Process
    {
        
        ##todo:
        ##process date
        #[TimeZone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($igrp.creationtime))
        if($name)
        {
            $rtnigrp += $igrp | where {$_.name -like $name}
        }
        else
        {
            $rtnigrp = $igrp
        }
    }
    End
    {
        $rtnigrp
    }
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Add-NSInitiatorToGroup
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,Position=0)]
        $Name,
        # group name
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        $InitiatorGroup
    )

    Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
            
    }
    Process
    {
        foreach($init in $Name)
        {
            $i = New-Object initiator
            $i.name = $init
            $rtncode = $Script:NSUnit.addInitiatort($sid.Value,$InitiatorGroup, $i)
            if($rtncode -ne "Smok")
            {
                Write-Error "Error adding $init to the list! code: $rtncode"
            }
        }
    }
    End
    {
    }
}