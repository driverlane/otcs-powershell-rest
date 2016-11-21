# checks if a name exists in a folder
function Find-CSExistingName {

    Param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$ItemName,
        [Parameter(Mandatory=$true)][int]$ParentId,
        [Parameter(Mandatory=$true)][string]$Ticket,
        [bool]$Simulate = $false
    )

    if ($Simulate) {
        $existingId = Get-Random -Maximum 100000
        if ($existingId -lt 80000) {
            $existingId = 0
            Write-Debug "Random number not created for existing ID"
        }
        else {
            Write-Debug "Random number created for existing ID $existingId"
        }
    }
    else {

        # create the folder object
        $checkNames = @{
            parent_id = $ParentId
            names = @($ItemName)
        }

        # turn it into a boundary based body
        $boundary = $boundary = [System.Guid]::NewGuid().ToString()
        $body = "--$boundary`r`nContent-Disposition: form-data; name=`"body`"`r`n`r`n" + (ConvertTo-Json $checkNames -Compress) + "`r`n--$boundary--"

        # send the request
        $url = $Uri + "/api/v1/validation/nodes/"
        $response = Invoke-RestMethod -Method Post -Uri $url -Header @{"otcsticket" = $Ticket} -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $body
        $existingId = 0
        foreach ($result in $response.results) {
            if ($result.id -ne $null){
                $existingId = $result.id
                Write-Debug "Returned existing ID $existingId"
            }
        }
    }
    return $existingId
}
