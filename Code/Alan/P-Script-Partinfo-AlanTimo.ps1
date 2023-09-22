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
    la taille, l'espace utilisé, l'expace libre avec le poourcentage, et tous sa mis dans un fichier unique dans un dossier logs. 
  	
.PARAMETER Param1
    
	
.PARAMETER Param2
    
 	
.PARAMETER Param3
    

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

# Ce que fait le script, ici, afficher un message
# Spécifiez le chemin du dossier où vous souhaitez enregistrer les journaux
$logsFolderPath = "Z:\Logs\PartInfos"

# Créez le dossier s'il n'existe pas
if (-not (Test-Path -Path $logsFolderPath)) {
    New-Item -Path $logsFolderPath -ItemType Directory 
}


# Créez un objet personnalisé pour chaque lecteur
$diskInfoObjects = @()
foreach ($diskInfo in Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }) {
    $diskObject = [PSCustomObject]@{
        DriveLetter = $diskInfo.DeviceID
        TotalSizeGB = [math]::Round($diskInfo.Size / 1GB, 2)
        UsedSpaceGB = [math]::Round(($diskInfo.Size - $diskInfo.FreeSpace) / 1GB, 2)
        FreeSpaceGB = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
        FreeSpacePercentage = [math]::Round(($diskInfo.FreeSpace / $diskInfo.Size) * 100, 2)
    }
    $diskInfoObjects += $diskObject
}

# Créez un nom de fichier unique basé sur la date et l'heure actuelles
$logFilePath = Join-Path -Path $logsFolderPath -ChildPath $logFileName

# Exportez les informations dans un fichier texte
$diskInfoObjects | Format-Table -AutoSize | Out-File -FilePath $logFilePath

# Affichez les informations collectées
Write-Host "Informations sur l'espace disque collectées et enregistrées dans le fichier :"
Write-Host $logFilePath