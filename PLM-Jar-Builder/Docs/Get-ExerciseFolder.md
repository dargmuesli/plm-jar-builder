---
external help file: JAR-help.xml
Module Name: PLM-Jar-Builder
online version: https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Get-ExerciseFolder.md
schema: 2.0.0
---

# Get-ExerciseFolder

## SYNOPSIS
Gets exercise folders.

## SYNTAX

```
Get-ExerciseFolder [-ExerciseRootPath] <String> [-ExerciseNumber <Int32[]>] [-Newest]
```

## DESCRIPTION
The "Get-ExerciseFolder" cmdlet searches an exercise root path for folders matching the exercise folder regular expression and returns its findings.

## EXAMPLES

### -------------------------- BEISPIEL 1 --------------------------
```
Get-ExerciseFolder -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen"
```

Get-ExerciseFolder -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen" -ExerciseNumbers @(1, 2)
Get-ExerciseFolder -ExerciseRootPath "D:\Dokumente\Universität\Informatik\Semester 1\Einführung in die Programmierung\Übungen" -Newest

## PARAMETERS

### -ExerciseRootPath
The path to the directory that contains the exercise folders.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExerciseNumber
The exercise numbers for which folders are to be found.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Newest
Whether to return only the exercise folder with the highest exercise number.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Get-ExerciseFolder.md](https://github.com/Dargmuesli/plm-jar-builder/blob/master/PLM-Jar-Builder/Docs/Get-ExerciseFolder.md)
