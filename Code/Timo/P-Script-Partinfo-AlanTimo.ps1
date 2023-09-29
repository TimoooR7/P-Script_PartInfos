<#
.NOTES
    *****************************************************************************
    ETML
    Nom du script:	P-Script_PartInfos 
    Auteur:	Alan Bitter et Timo Rouwenhorst
    Date:	22.09.2023
 	*****************************************************************************
    Modifications
 	Date  : -
 	Auteur: -
 	Raisons: -
 	*****************************************************************************
.SYNOPSIS
	
 	
.DESCRIPTION
    Ce script permmetera de collecté les données suivante du PC : 
    la taille, l'espace utilisé, l'expace libre avec le poourcentage, et tous ca mis dans un fichier unique dans un dossier logs. 
  	

.OUTPUTS
	
	
.EXAMPLE
	
	
.EXAMPLE
	
	
.LINK
    
#>

<# Le nombre de paramètres doit correspondre à ceux définis dans l'en-tête
   
#>
# La définition des paramètres se trouve juste après l'en-tête et un commentaire sur le.s paramètre.s est obligatoire 


###################################################################################################################
# Zone de définition des variables et fonctions, avec exemples
# Commentaires pour les variables


###################################################################################################################
# Zone de tests comme les paramètres renseignés ou les droits administrateurs

# Affiche l'aide si un ou plusieurs paramètres ne sont par renseignés, "safe guard clauses" permet d'optimiser l'exécution et la lecture des scripts


###################################################################################################################
# Corps du script

$logsFolderPath = "$PWD\Logs\LogsFiles"
$errorsFolderPath = "$PWD\Logs\ErrorFiles"

$timeStamp = Get-Date -Format "yyyyMMddHHmmss"


# Créé le dossier logs s'il n'existe pas
if (-not (Test-Path -Path $logsFolderPath)) {
    New-Item -Path $logsFolderPath -ItemType Directory 
}

# Pareil pour le dossier des erreurs
if (-not (Test-Path -Path $errorsFolderPath))
{
    New-Item -Path $errorsFolderPath -ItemType Directory
}


# Créez un objet personnalisé pour chaque lecteur
$diskInfoObjects = @()

foreach ($diskInfo in Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 -or $_.DriveType -eq 4 -or $_.DriveType -eq 5}) {
   if ($diskInfo.Size -lt 1)
    {
        # Pour éviter une erreur de division par 0
        continue
    }
    
    # Enregistrement de toutes les informations du disque dans le tableau
    $diskObject = [PSCustomObject]@{
        DriveLetter = $diskInfo.DeviceID
        TotalSizeGB = [math]::Round($diskInfo.Size / 1GB, 2)
        UsedSpaceGB = [math]::Round(($diskInfo.Size - $diskInfo.FreeSpace) / 1GB, 2)
        FreeSpaceGB = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
        FreeSpacePercentage = [math]::Round(($diskInfo.FreeSpace / $diskInfo.Size) * 100, 2)
    }
    
    $diskInfoObjects += $diskObject
}



# Création du dossier et du fichier logs
New-Item -ItemType File -Name "DiskInfo-$timeStamp.log" -Path $logsFolderPath -Force
$logsFilePath = "$PWD\Logs\LogsFiles\DiskInfo-$timeStamp.log"

# Ecrire toutes les infos des disques dans le fichier .log
$diskInfoObjects | Format-Table -AutoSize | Out-File -FilePath $logsFilePath

# Affiche les informations des disques sur la console.
Write-Host "`nInformations sur l'espace disque collectées et enregistrées dans le fichier :" -ForegroundColor Cyan
Get-Content -Path $logsFilePath


### TO DO Mettre les erreurs éventuelles dans le fichier error.log dans son dossier. 

