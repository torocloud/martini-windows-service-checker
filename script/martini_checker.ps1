# First we create the request.
$HTTP_Request = [System.Net.WebRequest]::Create('http://localhost:8080/api/sample/hello/Martini')

# We then get a response from the site.
$HTTP_Response = $HTTP_Request.GetResponse()

# We then get the HTTP code as an integer.
$HTTP_Status = [int]$HTTP_Response.StatusCode

If ($HTTP_Status -eq 200) {
    Write-Host "Martini is OK!"
}
Else {
    Write-Host "Martini not responding, restarting service..."
    Restart-Service -Name "Martini Runtime"
}

# Finally, we clean up the http request by closing it.
If ($HTTP_Response -eq $null) { } 
Else { $HTTP_Response.Close() }