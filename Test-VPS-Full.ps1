param(
    [string]$VPSIP = "192.3.253.2",   # VPS IP to test
    [int]$PingCount = 5,              # Number of ping attempts
    [string]$DownloadTestURL = "http://speedtest.tele2.net/10MB.zip" # Small file for simple download speed test
)

Write-Host "===== VPS Network Test ====="
Write-Host "Target VPS IP:" $VPSIP
Write-Host "============================="

# 1. Ping test
Write-Host "`n1. Ping Test ($PingCount times)"
$pingResults = Test-Connection -ComputerName $VPSIP -Count $PingCount
$avgLatency = ($pingResults | Measure-Object ResponseTime -Average).Average
$packetLoss = ((1 - ($pingResults.Count / $PingCount)) * 100)
Write-Host ("Average latency: " + [math]::Round($avgLatency,2) + " ms")
Write-Host ("Packet loss: " + [math]::Round($packetLoss,2) + " %")

# 2. Traceroute
Write-Host "`n2. Traceroute"
try {
    Test-NetConnection -ComputerName $VPSIP -TraceRoute
} catch {
    Write-Host "Traceroute failed. Use PowerShell 7 or admin privileges." 
}

# 3. Simple download speed test
Write-Host "`n3. Download Speed Test (approximate)"
$tempFile = Join-Path $env:TEMP "vps_speed_test.tmp"
$startTime = Get-Date
try {
    Invoke-WebRequest -Uri $DownloadTestURL -OutFile $tempFile
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    $fileSizeMB = (Get-Item $tempFile).Length / 1MB
    $speedMbps = ($fileSizeMB * 8) / $duration
    Write-Host ("Downloaded " + [math]::Round($fileSizeMB,2) + " MB in " + [math]::Round($duration,2) + " s")
    Write-Host ("Approximate speed: " + [math]::Round($speedMbps,2) + " Mbps")
} catch {
    Write-Host "Download test failed. Check network or URL."
} finally {
    if (Test-Path $tempFile) { Remove-Item $tempFile }
}

Write-Host "`nTest completed."
Write-Host "============================="