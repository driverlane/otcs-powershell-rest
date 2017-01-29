function CreateFile {

    Param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$ItemName,
        [Parameter(Mandatory=$true)][int]$ParentId,
        [Parameter(Mandatory=$true)][string]$FilePath,
        [Parameter(Mandatory=$true)][string]$Ticket,
        [switch]$ReturnExisting,
        [bool]$LogOnly = $false
    )

    if ($LogOnly) {
        $newFile = Get-Random -Maximum 100000
        Write-Debug "Random number created for file ID $newFile"
    }
    else {

        $newFile = 0

        # if requested, check for existing
        if ($ReturnExisting) {
            $existingId = CheckNames -Uri $Uri -ItemName $ItemName -ParentId $ParentId -LogOnly $LogOnly -Ticket $Ticket
            if ($existingId -gt 0) {
                $newFile = $existingId
                Write-Debug "Returned existing ID for file ID $newFile"
            }
        }

        # if there's no existing, create one
        if ($newFile -eq 0) {

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
            $url = $Uri + "/api/v2/nodes/"
            $response = Invoke-RestMethod -Method Post -Uri $url -Header @{"otcsticket" = $Ticket} -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $body
            $newFile = $response.results.id
            Write-Debug "Created file $ItemName with ID: $newFile"

        }

    }
    return $newFile
}
