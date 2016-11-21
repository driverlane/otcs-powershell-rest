# cs-powershell-rest

PowerShell wrapper functions for working with the Content Server REST API.

Use at your own risk. These **do not** replace a proper migration tool.

## Available functions

Refer to the function itself for the parameters it supports

* Add-CSFolder
* Add-CSConnectedWorkspace
* Get-CSTicket
* Find-ExistingName
* Remove-Node

## Common switches

A number of the functions have switches for handling a request to create an item with the sname name in the target container. These are:

* ReturnExisting - return the existing ID number rather than trying to create a new item
* AddVersion - if the file modified date is different to the existing file modified date, add a version instead of trying to create a new item

## Simulate

Most of the functions have a simulate mode where a random number is returned instead of querying the server. Set -Simluate to $true for this mode.

## Example

This will copy a folder hierarchy from a file system to Content Server

```
# import the REST api wrapper functions
. ./cs-powershell-rest.ps1

# set some defaults
$serverUrl = "http:\\server.name\otcs\cs.exe"
$rootFolder = 45959
$sourcePath = "E:\your\path"
$levelsToRecurse = 99
$level = 0

# creates the item then recurses any children
function CreateItems {

    Param(
        [Parameter(Mandatory=$true)][System.IO.DirectoryInfo]$Directory,
        [Parameter(Mandatory=$true)][int]$ParentId,
        [Parameter(Mandatory=$true)][string]$Ticket
    )

    # create the folder
    $ItemID = Add-CSFolder -Uri $serverUrl -ItemName $Directory.BaseName -ParentId $ParentId -Ticket $Ticket
    [System.Console]::WriteLine("Created folder {0} in {1} with ID {2}", $Directory.BaseName, $ParentId, $ItemId)

    # if we're not at the bottom level run this over any children
    if ($ItemID -ne 0 -and $level -lt $levelsToRecurse) {
        Get-ChildItem -Path $Directory.FullName -Directory | ForEach-Object {
            $level++
            CreateItems -Directory $_ -ParentId $ItemID
            $level--
        }
    }

}

# get the username and password
$user = Get-Credential -Message "Enter user details"
$username = $user.UserName
$password = $user.GetNetworkCredential().Password

# get a ticket
$ticket = Get-CSTicket -Uri $serverUrl -Username $username -Password $password

# kick off the transfer
Get-ChildItem -Path $sourcePath -Directory | ForEach-Object {
    CreateItems -Directory $_ -ParentId $rootFolder -Ticket $ticket
}
```

There are more examples in the system-test.ps1 file.

## Development

This project uses pester for unit testing. Download the latest release from [github](https://github.com/pester/Pester/releases)
and copy the contents to your modules folder, removing the version number from the folder name.

```
function Get-UserModulePath {
    $Path = $env:PSModulePath -split ";" -match $env:USERNAME
    if (-not (Test-Path -Path $Path)){
        New-Item -Path $Path -ItemType Container | Out-Null
    }
    $Path
}
Invoke-Item (Get-UserModulePath)
```