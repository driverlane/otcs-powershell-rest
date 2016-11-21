# get a CS ticket
function Get-CSTicket {

    Param(
        [Parameter(Mandatory=$true)][string]$Uri,
        [Parameter(Mandatory=$true)][string]$Username,
        [Parameter(Mandatory=$true)][string]$Password,
        [boolean]$Simulate = $false
    )

    if ($Simulate) {
        $ticket = Get-Random -Maximum 100000
        Write-Debug "Random number created for a ticket $ticket"
    }
    else {

        # create the object
        $user = @{
            username = $Username
            password = $Password
        }

        # send the request
        $url = $Uri + "/api/v1/auth/"
        $response = Invoke-RestMethod -Method Post -Uri $url -Body $user
        $ticket = $response.ticket
        Write-Debug "Ticket received $ticket"
    }
    return $ticket
}
