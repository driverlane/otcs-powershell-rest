# import the REST api wrapper functions


# set some defaults
$serverUrl = "http:\\server.name\otcs\cs.exe"
$rootFolder = 45959
$sourcePath = ".\data"
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

# kick off the work
Get-ChildItem -Path $sourcePath -Directory | ForEach-Object {
    CreateItems -Directory $_ -ParentId $rootFolder -Ticket $ticket
}
