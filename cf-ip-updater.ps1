# Variables
$accountID = ""
$groupUID = ""
$apiToken = ""
$groupName = "IPs"

function Get-LocalIP {
    $response = Invoke-RestMethod -Method Get -Uri "https://ifconfig.co/json"
    $script:localIP = $response.ip
}

function Get-LocalIP {
  $response = curl "https://ipinfo.io/json"
  $jsonContent = $response.Content | ConvertFrom-Json
  $script:localIP = $jsonContent.ip
  # $response = Invoke-RestMethod -Method Get -Uri "https://ifconfig.co/json"
  # $script:localIP = $response.ip
}

function Get-AccessGroupIP {
    $headers = @{
        "Authorization" = "Bearer $apiToken"
        "Content-Type"  = "application/json"
    }

    $uri = "https://api.cloudflare.com/client/v4/accounts/$accountID/access/groups/$groupUID"
    $response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers

    # Extract IP addresses from the response
    $currentGroupIPs = $response.result.include | Where-Object { $_.ip } | Select-Object -ExpandProperty ip | Select-Object -ExpandProperty ip

    # Remove "/32" from the IP addresses
    $script:currentGroupIP = ($currentGroupIPs -replace '/32', '') -join ','
}

function Update-IP {
    $headers = @{
        "Authorization" = "Bearer $apiToken"
        "Content-Type"  = "application/json"
    }

    $uri = "https://api.cloudflare.com/client/v4/accounts/$accountID/access/groups/$groupUID"

    $body = @{
        "name"    = "$groupName"
        "include" = @(
            @{
                "ip" = @{
                    "ip" = "$localIP/32"
                }
            }
        )
        "exclude" = @()
        "require" = @()
    } | ConvertTo-Json -Depth 4

    Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $body
}

function Compare-IP {
    if ($localIP -eq $currentGroupIP) {
        Write-Host "IPs are the same, nothing to do."
        exit 0
    } else {
        Write-Host "IPs are different, updating the Access Group."
        Update-IP
    }
}

function Invoke-Action {
    Get-LocalIP
    Get-AccessGroupIP
    Compare-IP
}

Invoke-Action
