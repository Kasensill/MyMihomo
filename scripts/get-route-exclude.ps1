function Get-RouteExcludeAddress {

    param (
        [string]$Server
    )

    if ($Server -match ":") {
        return "$Server/128"
    }

    return "$Server/32"
}