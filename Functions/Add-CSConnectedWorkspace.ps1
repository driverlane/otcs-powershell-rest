# create a connected workspace and return the id
function Add-CSConnectedWorkspace {

    Param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$ItemName,
        [Parameter(Mandatory=$true)][int]$ParentId,
        [Parameter(Mandatory=$true)][string]$Ticket,
        [switch]$ReturnExisting,
        [bool]$Simulate = $false
    )

    if ($Simulate) {
        $newWorkspace = Get-Random -Maximum 100000
        Write-Debug "Random number created for workspace ID $newWorkspace"
    }
    else {

        $newWorkspace = 0

        # if requested, check for existing
        if ($ReturnExisting) {
            $existingId = Find-ExistingName -Uri $Uri -ItemName $ItemName -ParentId $ParentId -Simulate $Simulate -Ticket $Ticket
            if ($existingId -gt 0) {
                $newWorkspace = $existingId
                Write-Debug "Returned existing ID $newWorkspace for workspace $ItemName"
            }
        }

        # if there's no existing, create one
        if ($newWorkspace -eq 0) {

            # build the workspace object
            $workspace = @{
                template_id = $WorkspaceTemplateId
                name = $ItemName
                type = 848
                parent_id = $ParentId
                mime_type = "Business Workspace"
            }

            # turn it into a boundary based body
            $boundary = $boundary = [System.Guid]::NewGuid().ToString()
            $body = "--$boundary`r`nContent-Disposition: form-data; name=`"body`"`r`n`r`n" + (ConvertTo-Json $workspace -Compress) + "`r`n--$boundary--"

            # send the request
            $url = $Uri + "/api/v2/businessworkspaces/"
            $response = Invoke-RestMethod -Method Post -Uri $url -Header @{"otcsticket" = $Ticket} -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $body
            $newWorkspace = $response.results.id
            Write-Debug "Created workspace $ItemName with ID: $newWorkspace"

        }

    }
    return $newWorkspace
}
