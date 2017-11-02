﻿<#
    .SYNOPSIS
    Finds a matriculation number.

    .DESCRIPTION
    The "Find-MatriculationNumber" cmdlet searches an exercise root path for files matching the jar file regular expression, then extracts and included matriculation numbers.

    .PARAMETER ExerciseRootPath
    The path to the directory that contains the exercise folders.

    .PARAMETER All
    Whether to return all findings.
    Without this switch only unique values are returned.

    .EXAMPLE
    Find-MatriculationNumber -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen"
    Find-MatriculationNumber -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen" -All

    .LINK
    https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Find-MatriculationNumber.md
#>
Function Find-MatriculationNumber {
    Param (
        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [ValidateScript({Test-Path -Path $PSItem})]
        [String] $ExerciseRootPath,

        [Switch] $All
    )

    # Search jar files matching a pattern and extract the matriculation numbers
    $JarFileRegex = [Regex] (Get-PlmJarBuilderConfigProperty -PropertyName "JarFileRegex")
    $FoundMatriculationNumbers = Get-ChildItem -Path $ExerciseRootPath -Filter "*.jar" -File -Recurse |
        ForEach-Object {
        Return $JarFileRegex.Match($PSItem.Name).Groups[1].Value
    }

    $MatriculationNumber = @()

    # Filter found matriculation numbers
    ForEach ($FoundMatriculationNumber In $FoundMatriculationNumbers) {
        If ($All -Or (-Not ($MatriculationNumber -Contains $FoundMatriculationNumber))) {
            $MatriculationNumber += $FoundMatriculationNumber
        }
    }

    Return $MatriculationNumber
}

<#
    .SYNOPSIS
    Gets exercise folders.

    .DESCRIPTION
    The "Get-ExerciseFolder" cmdlet searches an exercise root path for folders matching the exercise folder regular expression and returns its findings.

    .PARAMETER ExerciseRootPath
    The path to the directory that contains the exercise folders.

    .PARAMETER ExerciseNumber
    The exercise numbers for which folders are to be found.

    .PARAMETER Newest
    Whether to return only the exercise folder with the highest exercise number.

    .EXAMPLE
    Get-ExerciseFolder -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen"
    Get-ExerciseFolder -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen" -ExerciseNumbers @(1, 2)
    Get-ExerciseFolder -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen" -Newest

    .LINK
    https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Get-ExerciseFolder.md
#>
Function Get-ExerciseFolder {
    Param (
        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [ValidateScript({Test-Path -Path $PSItem})]
        [String] $ExerciseRootPath,

        [ValidateNotNullOrEmpty()]
        [Int[]] $ExerciseNumber,

        [Switch] $Newest
    )

    $ExerciseSheetRegex = [Regex] (Get-PlmJarBuilderConfigProperty -PropertyName "ExerciseSheetRegex")

    # Get all exercise directories
    $ExercisePath = Get-ChildItem -Path $ExerciseRootPath -Directory |
        Where-Object {
        $PSItem.Name -Match $ExerciseSheetRegex
    }

    # Filter exercise numbers
    If ($ExerciseNumber.Length) {
        $ExercisePath = $ExercisePath |
            Where-Object {
            $ExerciseNumber -Contains $ExerciseSheetRegex.Match($PSItem.Name).Groups[1].Value
        }
    }

    # Return (filtered) path(s) or null
    If ($ExercisePath) {
        If ($Newest) {
            Return $ExercisePath[$ExercisePath.Length - 1]
        } Else {
            Return $ExercisePath
        }
    } Else {
        Return $Null
    }
}

<#
    .SYNOPSIS
    Create new PLM-Jar archives.

    .DESCRIPTION
    The "New-PlmJar" cmdlet checks for overlapping items in the $Include and $Exclude parameters.
    If none are found, the exercise folder paths are retrieved.
    For each exercise folder a jar file, containing the folder's contents, is created in that folder.

    .PARAMETER ExerciseRootPath
    The path to the directory that contains the exercise folders.

    .PARAMETER ExerciseNumber
    The exercise numbers for which jar files are to be generated.

    .PARAMETER All
    Whether to create jar files for all exercise folders.
    Default is to generate a jar only for the newest folder / the folder with the highest exercise number.

    .PARAMETER NoNote
    Whether to exclude a note regarding this tool in the jar.

    .PARAMETER Include
    A list of file extensions to include when packing the jar.

    .PARAMETER Exclude
    A list of file extensions to exclude when packing the jar.

    .PARAMETER MatriculationNumber
    The user's matriculation number.

    .EXAMPLE
    New-PlmJar -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen"

    .LINK
    https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/New-PlmJar.md
#>
Function New-PlmJar {
    [CmdletBinding(DefaultParametersetName = "Default")]

    Param (
        [Parameter(Mandatory = $True)]
        [ValidateScript({Test-Path -Path $PSItem})]
        [String] $ExerciseRootPath,

        [Parameter(
            ParameterSetName = "ExerciseNumber",
            Mandatory = $True
        )]
        [ValidateNotNullOrEmpty()]
        [Int[]] $ExerciseNumber,

        [Parameter(
            ParameterSetName = "All",
            Mandatory = $True
        )]
        [Switch] $All,

        [Switch] $NoNote,

        [ValidateNotNull()]
        [String[]] $Include,

        [ValidateNotNull()]
        [String[]] $Exclude = @("*.jar"),

        [ValidateNotNullOrEmpty()]
        [Int] $MatriculationNumber
    )

    # Ensure $Include and $Exclude do not overlap
    ForEach ($Element In $Include) {
        If ($Exclude -Contains $Element) {
            # Include and Exclude parameters overlap
            Throw "Include und Exclude parameters overlap at `"$Element`"!"
        }
    }

    # Get the exercise folders in scope
    $ExercisePaths = $Null

    Switch ($PSCmdlet.ParameterSetName) {
        "ExerciseNumber" {
            $ExercisePaths = Get-ExerciseFolder -ExerciseRootPath $ExerciseRootPath -ExerciseNumber $ExerciseNumber
            Break
        }
        "All" {
            $ExercisePaths = Get-ExerciseFolder -ExerciseRootPath $ExerciseRootPath
            Break
        }
        "Default" {
            $ExercisePaths = Get-ExerciseFolder -ExerciseRootPath $ExerciseRootPath -Newest
            Break
        }
    }

    # Create the jar file(s)
    ForEach ($ExercisePath In $ExercisePaths) {
        $NoteFilePath = Get-PlmJarBuilderVariable -Name "NoteFilePath"
        $ExerciseSheetRegex = [Regex] (Get-PlmJarBuilderConfigProperty -PropertyName "ExerciseSheetRegex")
        $ExerciseNumberFormat = [String] (Get-PlmJarBuilderVariable -Name "ExerciseNumberFormat")
        $ExerciseNumberZeroed = ([Int] $ExerciseSheetRegex.Match($ExercisePath.Name).Groups[1].Value).ToString($ExerciseNumberFormat)
        $SolutionPath = Get-PlmJarBuilderConfigProperty -PropertyName "SolutionPath"
        $SolutionPathAbsolute = "$($ExercisePath.FullName)\$SolutionPath"

        If (-Not (Test-Path $SolutionPathAbsolute)) {
            # Solution path does not exist
            Throw "Solution path does not exist!"
        }

        $Files = @(Get-ChildItem -Path "$SolutionPathAbsolute" -Include:$Include -Exclude:$Exclude -Recurse -File)

        # Add an optional note
        If (-Not $NoNote) {
            $Files += Get-Item -Path $NoteFilePath
        }

        # Create the jar command
        $FileString = $Null

        ForEach ($File In $Files) {
            $IsSolutionPathSubdirectory = ($File.DirectoryName).StartsWith($SolutionPathAbsolute)
            If ($IsSolutionPathSubdirectory) {
                $RelativeFilePath = ($File.FullName).Replace("$SolutionPathAbsolute\", "")
                $FileString += " -C `"$SolutionPathAbsolute`" `"$RelativeFilePath`""
            } Else {
                $FileString += " -C `"$($File.DirectoryName)`" `"$($File.Name)`""
            }
        }

        $JarName = $Null

        If ($MatriculationNumber) {
            $JarName = "${MatriculationNumber}_$ExerciseNumberZeroed.jar"
        } Else {
            $JarName = "Lösung_$ExerciseNumberZeroed.jar"
        }

        $JarFullName = "$SolutionPathAbsolute\$JarName"

        Write-Verbose "Executing `"jar cvf`""
        Invoke-Expression "jar cvfM `"$JarFullName`"$FileString"
    }
}