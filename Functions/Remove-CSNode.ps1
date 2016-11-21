# removes a nodes
function Remove-Node {

    Param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$ItemID,
        [Parameter(Mandatory=$true)][string]$Ticket,
        [bool]$Simulate = $false
    )

    # send the request
    $url = $Uri + "/api/v1/nodes/$ItemID"
    Invoke-RestMethod -Method Delete -Uri $url
    Write-Debug "Node deleted"

}
