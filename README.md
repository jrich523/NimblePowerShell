NimblePowerShell
================

PowerShell Module for Nimble Storage

[http://www.nimblestorage.com](http://www.nimblestorage.com "Nimble Storage")

Community Thread

[https://connect.nimblestorage.com/thread/1277](https://connect.nimblestorage.com/thread/1277 "Community Thread")

# Install #
Copy all files to the module profile (use the download zip button)

1. Download ZIP and Unblock file.
2. Extra files to
	**\Documents\WindowsPowerShell\Modules\Nimble**
3. Load PowerShell and Import-Module Nimble

I am working towards an easier install method.


#Examples#

    Connect-NSArray -name 10.20.30.40 -password <clear text for now>
    Get-NSVolume
	New-NSVolume -name myvol -size 2tb



This module is still a work in progress but basic functionality is available and most tasks should be doable.

Please let me know if any features are needed.

Thanks
Justin 
