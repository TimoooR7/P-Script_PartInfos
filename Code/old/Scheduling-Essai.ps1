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
	Obtenir des infos sur les disques � des heures pr�cises dans la journ�e
 	
.DESCRIPTION
   Le script va cr�er une t�che sur l'ordinateur local et va obtenir des informations sur les disques toutes les x minutes. 
  	

.OUTPUTS
	Une t�che est cr��e dans le planificateur de t�ches
	
.EXAMPLE
	.\Timo-Create-Groupe.ps1
	La ligne que l'on tape pour l'ex�cution du script.
	R�sultat : par exemple un fichier, une modification, un message d'erreur
	
	
#>

<# Le nombre de param�tres doit correspondre � ceux d�finis dans l'en-t�te
   Il est possible aussi qu'il n'y ait pas de param�tres mais des arguments
   Un param�tre peut �tre typ� : [string]$Param1
   Un param�tre peut �tre initialis� : $Param2="Toto"
   Un param�tre peut �tre obligatoire : [Parameter(Mandatory=$True][string]$Param3
#>
# La d�finition des param�tres se trouve juste apr�s l'en-t�te et un commentaire sur le.s param�tre.s est obligatoire 
#param($GroupName)

###################################################################################################################
# Zone de d�finition des variables et fonctions, avec exemples
# Commentaires pour les variables






###################################################################################################################
# Zone de tests comme les param�tres renseign�s ou les droits administrateurs

Set-ExecutionPolicy Unrestricted

###################################################################################################################
# Corps du script
$NomTache = "Tache-DiskInfo"


$action = New-ScheduledTaskAction -Execute 'C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe' -Argument 'X:\Code\Timo\Scheduling-DiskInfo.ps1'
$trigger = New-ScheduledTaskTrigger -Once -RepetitionInterval ([TimeSpan]::FromMinutes(5))

try
{
    $tache = Get-ScheduledTask -TaskName $NomTache
}
catch
{
    # Attribue null � la t�che si elle n'existe pas.
    $tache = $null
}


if ($tache -ne $null)
{

    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $NomTache -TaskPath \Projet -Description "T�che du projet I122"
    # Cr�er la t�che avec action et trigger 
}