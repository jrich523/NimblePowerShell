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
function Remove-NSInitiatorFromGroup
{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipeline=$true,Position=0,parametersetname='name')]
        $Name,
        [Parameter(ValueFromPipeline=$true,Position=0,parametersetname='ip')]
        $IP,
        # group name
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        $InitiatorGroup,
        #force
        [switch]
        $Force
    )

    Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        if($Force){$ConfirmPreference= 'None'} 
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
function New-NSInitiatorGroup
{
    [CmdletBinding()]
    Param
    (
        # group name
        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=0)]
        [ValidatePattern('^[a-z,A-Z,\d,\.,-]+$')]
        $Name,
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        $Description
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
        foreach($gname in $Name)
        {
            $g = New-Object InitiatorGrpCreateAttr
            $g.name = $gname
            $g.description = $Description
            $rtncode = $Script:NSUnit.CreateInitiatorGrp($sid.Value,$g)
            if($rtncode -ne "Smok")
            {
                Write-Error "Error creating $gname initiator group! code: $rtncode"
            }
        }
        Get-NSInitiatorGroup $gname
    }
    End
    {
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
function Remove-NSInitiatorGroup
{
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='High')]
    Param
    (
        # group name
        [Parameter(ValueFromPipeline=$true,Position=0)]
        $Name
    )

    Begin
    {
        if(-not $Script:NSUnit)
        {
            Write-Error "Connect to unit first!" -ErrorAction Stop
        }
        if($Force){$ConfirmPreference= 'None'}
        $volumes = Get-NSVolume
        $RejectAll = $false;
        $ConfirmAll = $false;
    }
    Process
    {
        foreach($gname in $Name)
        {
            $InUseVols = ($volumes | ?{$_.acllist.initiatorgrp -eq $gname} | select -exp name) -join ", "
            if($InUseVols)
            {
                if($PSCmdlet.ShouldContinue("Remove in use initiator $gname? It's currently in use on $InUseVols","In use initiator group",[ref]$ConfirmAll,[ref]$RejectAll))
                {
                    $rtncode = $Script:NSUnit.DeleteInitiatorGrp($sid.Value,$gname)
                }
            }
            else
            {
                $rtncode = $Script:NSUnit.DeleteInitiatorGrp($sid.Value,$gname)
            }
            if($rtncode -ne "Smok" -and $rtncode)
            {
                Write-Error "Error deleting '$gname' initiator group! code: $rtncode"
            }
        }
    }
    End
    {
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
function Add-NSInitiatorGroupToVolume
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=0)]
        $InitiatorGroup,
        # group name
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=1)]
        $Volume,
        #access type
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=2)]
        [ValidateSet("Both", "Snapshot", "Volume")]
        $Access="Both"
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
        #if object given, get names
        if($Volume.gettype().name -eq "vol"){$Volume=$Volume.name}
        if($InitiatorGroup.gettype().name -eq "initiatorgrp"){$InitiatorGroup=$InitiatorGroup.name}
        
        $applyto = switch($Access){
                    "Both"{[smvolaclapply]::SMvolaclapplytoboth}
                    "Snapshot"{[smvolaclapply]::SMvolaclapplytosnap}
                    "Volume"{[smvolaclapply]::SMvolaclapplytovol}
                    }

        $rtncode = $Script:NSUnit.addVolAcl($script:sid.value,$Volume,$applyto ,"*",$InitiatorGroup)
        if($rtncode -ne "Smok")
        {
            Write-Error "Error adding $init to the list! code: $rtncode"
        }
    }
    End
    {
    }
}