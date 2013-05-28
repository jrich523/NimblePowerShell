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