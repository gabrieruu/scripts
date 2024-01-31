# Set the source and destination paths
$backupFolderPath = "C:\Path\To\Backup\Folder"
$localSSRSServerUrl = "http://localhost/ReportServer"

# Set the credentials for the local SSRS server
$credential = Get-Credential

# Import reports using PowerShell
$rdlFiles = Get-ChildItem -Path $backupFolderPath -Filter "*.rdl" -File

foreach ($rdlFile in $rdlFiles) {
    $reportName = $rdlFile.BaseName
    $reportPath = "/Reports/$reportName"

    $reportContent = Get-Content $rdlFile.FullName -Raw
    New-RsWebServiceProxy -Uri $localSSRSServerUrl -Credential $credential -UseDefaultCredentials | Set-RsCatalogItem -Path $reportPath -PropertyType Report -Overwrite -Content $reportContent
    Write-Host "Report '$reportName' imported successfully."
}

# Import subscriptions using rs.exe
$xmlFiles = Get-ChildItem -Path $backupFolderPath -Filter "*.xml" -File

foreach ($xmlFile in $xmlFiles) {
    $subscriptionName = $xmlFile.BaseName

    # Build rs.exe command for subscriptions
    $rsExeCommand = @"
    "C:\Program Files\Microsoft SQL Server\{Your SQL Server Version}\Tools\Binn\rs.exe" -i "$backupFolderPath\$subscriptionName.xml" -s $localSSRSServerUrl -v username={$credential.UserName} -v password={$credential.GetNetworkCredential().Password} -l DEBUG
"@

    Invoke-Expression -Command $rsExeCommand
    Write-Host "Subscription '$subscriptionName' imported successfully."
}

Write-Host "Import process completed."

