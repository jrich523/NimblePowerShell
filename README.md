NimblePowerShell
================

> This is now fairly old and out of date (they thankfully moved to REST) so this likely wont work for you and even if it does, you probably shouldnt use it.

[![Join the chat at https://gitter.im/jrich523/NimblePowerShell](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/jrich523/NimblePowerShell?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

PowerShell Module for Nimble Storage

[http://www.nimblestorage.com](http://www.nimblestorage.com "Nimble Storage")

Community Thread

[https://connect.nimblestorage.com/thread/1277](https://connect.nimblestorage.com/thread/1277 "Community Thread")

# Install #
	iex (new-object System.Net.WebClient).DownloadString('https://raw.github.com/jrich523/NimblePowerShell/master/Install.ps1')


#Examples#

    Connect-NSArray -name 10.20.30.40 -password <clear text for now>
    Get-NSVolume
	New-NSVolume -name myvol -size 2tb



A VDI type example would be something like this. It assume you have a CloneTest volume, it snaps it and creates a clone from it and then provides the same security access. From this point you could mount the volume as a datastore in the vm environment.

	Get-NSVolume
	Get-NSSnapShot -Volume clonetest
	Get-NSVolume -Name clonetest| New-NSSnapshot -Name CloneTest2 | New-NSClone -Name CloneTest2
	Get-NSSnapShot -Volume clonetest
	Get-NSVolume
	Get-NSVolume clonetest2 | Get-NSVolumeACL
	Get-NSInitiatorGroup
	Add-NSInitiatorGroupToVolume -InitiatorGroup esx -Volume clonetest2 -Access Volume
	Get-NSVolume clonetest2 | Get-NSVolumeACL
	Get-NSVolume clonetest2 | Get-NSVolumeACL | Get-NSInitiatorGroup
Remove the clone and snapshot
	Remove-NSVolume clonetest2 -Force
	Get-NSVolume clonetest | Get-NSSnapShot | Remove-NSSnapShot

![](https://connect.nimblestorage.com/servlet/JiveServlet/showImage/2-1708-1408/example.gif)


Please let me know if any features are needed.

Thanks
Justin 
