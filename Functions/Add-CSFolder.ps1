# create a folder and return the id
function Add-CSFolder {

    Param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$ItemName,
        [Parameter(Mandatory=$true)][int]$ParentId,
        [Parameter(Mandatory=$true)][string]$Ticket,
        [switch]$ReturnExisting,
        [bool]$Simulate = $false
    )

    if ($Simulate) {
        $newFolder = Get-Random -Maximum 100000
        Write-Debug "Random number created for folder ID $newFolder"
    }
    else {

        $newFolder = 0

        # if requested, check for existing
        if ($ReturnExisting) {
            $existingId = Find-ExistingName -Uri $Uri -ItemName $ItemName -ParentId $ParentId -Simulate $Simulate -Ticket $Ticket
            if ($existingId -gt 0) {
                $newFolder = $existingId
                Write-Debug "Returned existing ID $newFolder for folder $ItemName"
            }
        }

        # if there's no existing, create one
        if ($newFolder -eq 0) {

            # create the folder object
            $folder = @{
                type = 0
                parent_id = $ParentId
                name = $ItemName
            }

            # send the request
            $url = $Uri + "/api/v2/nodes/"
            $response = Invoke-RestMethod -Method Post -Uri $url -Body $folder -Header @{"otcsticket" = $Ticket}
            $newFolder = $response.results.data.properties.id
            Write-Debug "Created folder $ItemName with ID: $newFolder"

        }

    }
    return $newFolder
}
