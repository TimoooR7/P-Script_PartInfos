# Spécifiez le chemin du dossier où vous souhaitez enregistrer les journaux
$logsFolderPath = "C:\logs"

# Créez le dossier s'il n'existe pas
if (-not (Test-Path -Path $logsFolderPath)) {
    New-Item -Path $logsFolderPath -ItemType Directory
}

# Définissez le chemin du fichier de journalisation
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFileName = "DiskInfo_$timestamp.log"
$logFilePath = Join-Path -Path $logsFolderPath -ChildPath $logFileName

# Définissez le chemin du fichier d'erreurs
$errorFileName = "Errors_$timestamp.log"
$errorFilePath = Join-Path -Path $logsFolderPath -ChildPath $errorFileName

# Obtenez les informations sur le disque dur du système et gérez les erreurs
try {
    $diskInfo = Get-WmiObject -Class Win32_LogicalDisk -ErrorAction Stop | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 -or $_.DriveType -eq 4 -or $_.DriveType -eq 5 }

    # Créez un objet personnalisé pour le disque
    $diskInfoObject = [PSCustomObject]@{
        DriveLetter = $diskInfo.DeviceID
        TotalSizeGB = [math]::Round($diskInfo.Size / 1GB, 2)
        UsedSpaceGB = [math]::Round(($diskInfo.Size - $diskInfo.FreeSpace) / 1GB, 2)
        FreeSpaceGB = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
        FreeSpacePercentage = [math]::Round(($diskInfo.FreeSpace / $diskInfo.Size) * 100, 2)
    }

    # Exportez les informations dans un fichier texte (format log)
    Add-Content -Path $logFilePath -Value ("Drive Letter: " + $diskInfoObject.DriveLetter)
    Add-Content -Path $logFilePath -Value ("Total Size (GB): " + $diskInfoObject.TotalSizeGB)
    Add-Content -Path $logFilePath -Value ("Used Space (GB): " + $diskInfoObject.UsedSpaceGB)
    Add-Content -Path $logFilePath -Value ("Free Space (GB): " + $diskInfoObject.FreeSpaceGB)
    Add-Content -Path $logFilePath -Value ("Free Space Percentage: " + $diskInfoObject.FreeSpacePercentage + "%")
} catch {
    # En cas d'erreur, ajoutez l'erreur au fichier d'erreurs
    $_.Exception.Message | Out-File -FilePath $errorFilePath -Append

    # Affichez un message d'erreur
    Write-Host "Une erreur s'est produite. Les détails de l'erreur sont enregistrés dans le fichier :"
    Write-Host $errorFilePath

    # Affichez l'erreur dans la console
    Write-Error $_.Exception.Message
}
  
  # Exportez les informations dans un fichier texte
    $diskInfoObjects | Format-Table -AutoSize | Out-File -FilePath $logFilePath

  # Affichez les informations collectées
    Write-Host "Informations sur l'espace disque collectées et enregistrées dans le fichier :"
    write-Host $logFilePath


