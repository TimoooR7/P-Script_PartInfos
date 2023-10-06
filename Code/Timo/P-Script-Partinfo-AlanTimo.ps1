<#
.NOTES
    *****************************************************************************
    ETML
    Nom du script:	P-Script_PartInfos 
    Auteur:	Alan Bitter et Timo Rouwenhorst
    Date de création:	22.09.2023
 	*****************************************************************************
   
.SYNOPSIS
	Obtenir des informations sur les disques et les stocker dans un fichier.
 	
.DESCRIPTION
   Le script permet d'obtenir des informations sur les disques tel que: 
   - La lettre du disque
   - La taille totale du disque
   - L'espace utilisé du disque
   - L'espace libre du disque
   - L'espace libre du disque, en %.

    Il enregistre toutes ces informations dans un fichier .log se trouvant
    dans le répertoire "Documents". Il a comme nom la date, le nom de l'ordinateur et
    le nom de la tâche, alias "DiskInfo".  
    
    Un fichier d'erreurs est crée mais il n'est rempli seulement si il y en a. Il a
    comme nom "ERRORS", la date, le nom de l'ordinateur et le nom de la tâche. 
  	
    Pour terminer, un message bleu s'affiche sur la console et affiche ces informations.

.OUTPUTS
	2 fichiers .log sont créées et mis dans une arborescence de dossiers, eux aussi
    créées. 
	
.EXAMPLE
	.\P-Script-Partinfos-AlanTimo.ps1 

    TODO ENTETE
	
.EXAMPLE
	
	
.LINK
    
#>

<# Le nombre de paramètres doit correspondre à ceux définis dans l'en-tête
   
#>
# La définition des paramètres se trouve juste après l'en-tête et un commentaire sur le.s paramètre.s est obligatoire 


###################################################################################################################
# Zone de définition des variables et fonctions, avec exemples
# Commentaires pour les variables


$logsFolderPath = "C:\Users\$env:USERNAME\Documents\Logs\LogsFiles"
$errorsFolderPath = "C:\Users\$env:USERNAME\Documents\Logs\ErrorFiles"

$computerName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$timeStamp = Get-Date -Format "dd-MM-yyyy_HHmm" # Les secondes sont à enlever. Les avoir c plus pratique pour les tests

$logFileName = "$timeStamp-$computerName-PartInfos.log"
$errorsFileName = "ERRORS-$timeStamp-$computerName-PartInfos.log"

$logsFilePath = "$logsFolderPath\$logFileName"
$errorsFilePath = "$errorsFolderPath\$errorsFileName"

# Messages d'erreurs
[string]$unauthorizedAccess_ErrorsFile = "{ERROR} Le fichier d'erreurs n'a pas été créée car vous n'avez pas les autorisations nécessaires."
[string]$invalidOperation_ErrorsFile = "{ERROR} Une erreur non-déterminée a empêché la création du fichier <$errorsFileName>. Vérifiez votre observateur d'évènement pour + d'infos"

[string]$unauthorizedAccess_LogFile = "{ERROR} Le fichier de logs n'a pas été créée car vous n'avez pas les autorisations nécessaires."
[string]$invalidOperation_LogFile = "{ERROR} Une erreur non-déterminée a empêché la création du fichier <$logFileName>. Vérifiez votre observateur d'évènement pour + d'infos"

[string]$unauthorizedAccess_Infos = "{ERROR} Les informations n'ont pas pu être collectées car vous n'avez pas les autorisations nécessaires."
[string]$invalidOperation_Infos = "{ERROR} Une erreur non-déterminée a empêché la collecte des infos. Vérifiez votre observateur d'évènement pour + d'infos"

[string]$unauthorizedAccess_Writing = "{ERROR} L'écriture dans le fichier .log n'a pas pu se faire car vous n'avez pas les autorisations nécessaires."
[string]$invalidOperation_Writing = "{ERROR} Une erreur non-déterminée empêche l'écriture dans le fichier <$logFileName>. Vérifiez votre observateur d'évènements pour + d'infos"

###################################################################################################################
# Zone de tests comme les paramètres renseignés ou les droits administrateurs

# Affiche l'aide si un ou plusieurs paramètres ne sont par renseignés, "safe guard clauses" permet d'optimiser l'exécution et la lecture des scripts


###################################################################################################################
# Corps du script


# Création du dossier & fichier .log des erreurs avec -Force. 
try 
{
    # Créé le fichier d'erreurs si il n'existe pas 
    if (-not(Test-Path -Path "$errorsFilePath"))
    {
        New-Item -Path $errorsFilePath -ItemType File -Force
    }
}
catch
{
    if (-not [bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsAdmin)
    {
        throw [System.UnauthorizedAccessException]::new($unauthorizedAccess_ErrorsFile)
    }

    if (-not(Test-Path -Path "$errorsFilePath"))
    {
        throw [System.InvalidOperationException]::new($invalidOperation_ErrorsFile)
    }
}

# Création du dossier & fichier .log de logs avec -Force
try 
{
    # Créé le fichier logs s'il n'existe pas
    if (-not (Test-Path -Path $logsFilePath)) 
    {
        New-Item -Path $logsFilePath -ItemType File -Force
    }
}
catch
{
    # Un message d'erreur est affiché si on a pas les autorisations nécessaires
    if (-not [bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsAdmin)
    {
        Write-Output $unauthorizedAccess_LogFile > $errorsFilePath # Envoie l'erreur dans le fichier d'erreurs
        throw [System.UnauthorizedAccessException]::new($unauthorizedAccess_LogFile)
    }
    
    if (-not(Test-Path -Path $logsFilePath))
    {
        Write-Output $invalidOperation_LogFile > $errorsFilePath 
        throw [System.InvalidOperationException]::new($invalidOperation_LogFile)
    } 
}




# Tableau qui contient les infos de chaque disque
$diskInfoObjects = @()

foreach ($diskInfo in Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 -or $_.DriveType -eq 4 -or $_.DriveType -eq 5}) {
   
    if ($diskInfo.Size -lt 1)
    {
        # Pour éviter une erreur de division par 0
        continue
    }
    
    try 
    {
        # Enregistrement de toutes les informations du disque dans le tableau associatif $diskObject
        $diskObject = [PSCustomObject]@{
        DriveLetter = $diskInfo.DeviceID
        TotalSizeGB = [math]::Round($diskInfo.Size / 1GB, 2)
        UsedSpaceGB = [math]::Round(($diskInfo.Size - $diskInfo.FreeSpace) / 1GB, 2)
        FreeSpaceGB = [math]::Round($diskInfo.FreeSpace / 1GB, 2)
        FreeSpacePercentage = [math]::Round(($diskInfo.FreeSpace / $diskInfo.Size) * 100, 2)
        }
        
        #Enregistrement du tableau associatif dans un tableau
        $diskInfoObjects += $diskObject
    }
    catch 
    {
        if (-not [bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsAdmin)
        {
            Write-Output $unauthorizedAccess_Infos > $errorsFilePath
            throw [System.UnauthorizedAccessException]::new($unauthorizedAccess_Infos)
        }

        if ($diskInfo -eq $null)
        {
            Write-Output $invalidOperation_Infos > $errorsFilePath
            throw [System.InvalidOperationException]::new($invalidOperation_Infos)
        }
    }
        
    
    
}

try 
{
    # Ecrire toutes les infos des disques dans le fichier .log
    $diskInfoObjects | Format-Table -AutoSize | Out-File -FilePath $logsFilePath
}
catch
{
    # Message d'erreur si on a pas les droits admin. Sinon, c'est une erreur non-identifée.
    if (-not [bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsAdmin)
    {
        Write-Output $unauthorizedAccess_Infos > $errorsFilePath
        throw [System.UnauthorizedAccessException]::new($unauthorizedAccess_Infos)
    }
    else
    { 
        Write-Output $invalidOperation_Infos > $errorsFilePath
        throw [System.InvalidOperationException]::new($invalidOperation_Infos)
    }
}


# Affiche les informations des disques sur la console en allant les chercher dans le fichier .log
Write-Host "`nInformations sur l'espace disque collectées et enregistrées dans le fichier :" -ForegroundColor Cyan
Get-Content -Path $logsFilePath


Start-Sleep -Seconds 3
