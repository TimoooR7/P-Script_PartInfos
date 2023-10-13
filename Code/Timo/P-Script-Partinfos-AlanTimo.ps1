<#
.NOTES
    *****************************************************************************
    ETML
    Nom du script:	P-Script_PartInfos 
    Auteur:	Alan Bitter et Timo Rouwenhorst
    Date de création:	22.09.2023
    Date de fin : 11.10.2023
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
    créées. Ils se trouvent dans le répertoire "documents". 
    Un texte est écrit sur la console confirmant la création des dossiers/fichiers, ainsi
    que toutes les informations collectées sur les disques.
	

.EXAMPLE
	.\P-Script-Partinfos-AlanTimo.ps1 

    *Message de création des fichiers/dossiers*

    Informations sur l'espace disque collectées et enregistrées dans le fichier :
    
    DriveLetter TotalSizeGB UsedSpaceGB FreeSpaceGB FreeSpacePercentage
    ----------- ----------- ----------- ----------- -------------------
    C:                34,44       28,38        6,06               17,59
    S:                14,65        0,05        14,6               99,68
    T:                25,35        0,06       25,28               99,75
    X:               465,74      278,65      187,09               40,17
    Y:               471,56      128,32      343,24               72,79
    Z:               931,51       46,08      885,43               95,05
	

.EXAMPLE
	.\P-Script-Partinfos-AlanTimo.ps1 
    
    *EXEMPLE DE MESSAGE D'ERREUR*

    {ERROR} Le fichier d'erreurs n'a pas été créée car vous n'avez pas les droits administrateur. 
    Au caractère votrechemin\P-Script-Partinfos-AlanTimo.ps1:x : y
         throw [System.UnauthorizedAccessException]::new("{ERROR} Le fichier d'  ...
    +     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (:) [], UnauthorizedAccessException
    + FullyQualifiedErrorId : {ERROR} Le fichier d'erreurs n'a pas été créée car vous n'avez pas
                              les droits administrateurs

.LINK 
    Documentation Microsoft pour Powershell : https://learn.microsoft.com/en-us/powershell/ 
#>

###################################################################################################################
# Zone de définition des variables et fonctions, avec exemples
# Commentaires pour les variables


$logsFolderPath = "C:\Users\$env:USERNAME\Documents\Logs\LogsFiles" # Le chemin du dossier de logs
$errorsFolderPath = "C:\Users\$env:USERNAME\Documents\Logs\ErrorFiles" # Le chemin du dossier d'erreurs

$computerName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name # Le nom de l'ordinateur
$timeStamp = Get-Date -Format "dd-MM-yyyy_HHmm" # La date et heure du jour

$logFileName = "$timeStamp-$computerName-PartInfos.log" # Nom du fichier de logs
$errorsFileName = "ERRORS-$timeStamp-$computerName-PartInfos.log" # Nom du fichier d'erreurs

$logsFilePath = "$logsFolderPath\$logFileName" # Le chemin du fichier de logs
$errorsFilePath = "$errorsFolderPath\$errorsFileName" # Le chemin du fichier d'erreurs

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

# Teste si on a les droits admin
[bool]$isUserAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsAdmin



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
    # Un message d'erreur apparaît si on n'a pas les droits admin pour créer les dossiers/fichiers
    if ($isUserAdmin -eq $false)
    {
        throw [System.UnauthorizedAccessException]::new($unauthorizedAccess_ErrorsFile)
    }

    # Un message d'erreur apparaît si le fichier n'a tout de même pas été créée
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
    if ($isUserAdmin -eq $false)
    {
        Write-Output $unauthorizedAccess_LogFile > $errorsFilePath # Envoie l'erreur dans le fichier d'erreurs
        throw [System.UnauthorizedAccessException]::new($unauthorizedAccess_LogFile)
    }
    
    # Un message d'erreur apparaît si le fichier n'a pas été créée.
    if (-not(Test-Path -Path $logsFilePath))
    {
        Write-Output $invalidOperation_LogFile > $errorsFilePath 
        throw [System.InvalidOperationException]::new($invalidOperation_LogFile)
    } 
}




# Tableau qui contient les infos de chaque disque
$diskInfoObjects = @()

foreach ($diskInfo in Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 -or $_.DriveType -eq 4 -or $_.DriveType -eq 5}) 
{
   
    # Pour éviter toute erreur de division par 0
    if ($diskInfo.Size -lt 1)
    { 
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
        
        #Enregistrement du tableau associatif dans une case du tableau $diskInfoObjects (tableau dans un tableau)
        $diskInfoObjects += $diskObject
    }
    catch 
    {
        # Un message d'erreur apparaît si on a pas les droits admin pour aller chercher les informations des partitions
        if ($isUserAdmin -eq $false)
        {
            Write-Output $unauthorizedAccess_Infos > $errorsFilePath
            throw [System.UnauthorizedAccessException]::new($unauthorizedAccess_Infos)
        }

        # Un message d'erreur apparaît si les informations n'ont tout de même pas pu être récoltées
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
    if ($isUserAdmin -eq $false)
    {
        Write-Output $unauthorizedAccess_Infos > $errorsFilePath
        throw [System.UnauthorizedAccessException]::new($unauthorizedAccess_Infos)
    }
    else
    { 
        # Message d'erreur si l'écriture dans le fichier n'a pas été faite pour une quelconque raison
        Write-Output $invalidOperation_Infos > $errorsFilePath
        throw [System.InvalidOperationException]::new($invalidOperation_Infos)
    }
}


# Affiche les informations des disques sur la console en allant les chercher dans le fichier .log
Write-Host "`nInformations sur l'espace disque collectées et enregistrées dans le fichier :" -ForegroundColor Cyan
Get-Content -Path $logsFilePath

# Pas nécessaire. Attend 3 sec pour avoir le temps de lire la console, se ferme après.
Start-Sleep -Seconds 3