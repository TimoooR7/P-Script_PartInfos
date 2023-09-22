<#
.NOTES
    *****************************************************************************
    ETML
    Nom du script:	PScript_Sched-PartInfos.ps1
    Auteur:	Timo Rouwenhorst & Alan Bitter
    Date:	22.09.2023
 	*****************************************************************************
    Modifications
 	Date  : -
 	Auteur: -
 	Raisons: -
 	*****************************************************************************
.SYNOPSIS
	Obtenir des infos sur les disques à des heures précises dans la journée
 	
.DESCRIPTION
   Le script va créer une tâche sur l'ordinateur local et va obtenir des informations sur les disques toutes les x minutes. 
  	

.OUTPUTS
	Une tâche est créée dans le planificateur de tâches
	
.EXAMPLE
	.\Timo-Create-Groupe.ps1
	La ligne que l'on tape pour l'exécution du script.
	Résultat : par exemple un fichier, une modification, un message d'erreur
	
	
#>

<# Le nombre de paramètres doit correspondre à ceux définis dans l'en-tête
   Il est possible aussi qu'il n'y ait pas de paramètres mais des arguments
   Un paramètre peut être typé : [string]$Param1
   Un paramètre peut être initialisé : $Param2="Toto"
   Un paramètre peut être obligatoire : [Parameter(Mandatory=$True][string]$Param3
#>
# La définition des paramètres se trouve juste après l'en-tête et un commentaire sur le.s paramètre.s est obligatoire 
#param($GroupName)

###################################################################################################################
# Zone de définition des variables et fonctions, avec exemples
# Commentaires pour les variables






###################################################################################################################
# Zone de tests comme les paramètres renseignés ou les droits administrateurs

Set-ExecutionPolicy Unrestricted

###################################################################################################################
# Corps du script
$NomTache = "Tache-DiskInfo"
$tache = Get-ScheduledTask -TaskName $NomTache

$action = New-ScheduledTaskAction -Execute '%windir%\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe' -Argument 'Y:\Projet\Scheduling-DiskInfo.ps1'
$trigger = New-ScheduledTaskTrigger -Once -RepetitionInterval ([TimeSpan]::FromMinutes(30))


if ($tache -ne $null)
{
    # Créer la tâche avec action et trigger 
}
else 
{
    # Suprimme la tâche si elle existe déjà
    Unregister-ScheduledTask -TaskName $NomTache
}



