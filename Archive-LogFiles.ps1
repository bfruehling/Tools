<#
.SYNOPSIS
    Archives log files matching *-*.log pattern by month of modified date.

.DESCRIPTION
    Groups log files by their LastWriteTime month/year and creates compressed archives.
    Excludes files modified in the current month.
    Deletes original files after successful archiving.
    written by copilot

.PARAMETER LogPath
    Path containing the log files to archive. Defaults to current directory.

.PARAMETER ArchivePath
    Path where archive files will be created. Defaults to .\Archives

.PARAMETER DeleteOriginals
    If specified, deletes original log files after successful archiving.

.EXAMPLE
    .\Archive-LogFilesByMonth.ps1 -LogPath "C:\Logs" -ArchivePath "C:\Archives" -DeleteOriginals
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [string]$LogPath = "$home",
    
    [Parameter()]
    [string]$ArchivePath = "$home\Archives",
    
    [Parameter()]
    [switch]$DeleteOriginals
)

# Ensure archive path exists
if (-not (Test-Path $ArchivePath)) {
    New-Item -Path $ArchivePath -ItemType Directory -Force | Out-Null
    Write-Verbose "Created archive directory: $ArchivePath"
}

# Get current month/year
$currentMonth = Get-Date -Format "yyyy-MM"

# Get all log files matching pattern, excluding current month
$logFiles = Get-ChildItem -Path $LogPath -Filter "*-*.log" -File | 
    Where-Object { 
        $fileMonth = $_.LastWriteTime.ToString("yyyy-MM")
        $fileMonth -ne $currentMonth 
    }

if ($logFiles.Count -eq 0) {
    Write-Host "No log files found to archive (excluding current month)."
    return
}

# Group files by month
$filesByMonth = $logFiles | Group-Object { $_.LastWriteTime.ToString("yyyy-MM") }

foreach ($monthGroup in $filesByMonth) {
    $monthName = $monthGroup.Name
    $archiveFileName = "Logs_$monthName.zip"
    $archiveFullPath = Join-Path $ArchivePath $archiveFileName
    
    Write-Host "Archiving $($monthGroup.Count) files for $monthName..."
    
    if ($PSCmdlet.ShouldProcess($archiveFullPath, "Create archive")) {
        try {
            # Create or update archive
            foreach ($file in $monthGroup.Group) {
                Compress-Archive -Path $file.FullName -DestinationPath $archiveFullPath -Update -ErrorAction Stop
                Write-Verbose "  Added: $($file.Name)"
            }
            
            Write-Host "  Created archive: $archiveFileName" -ForegroundColor Green
            
            # Delete originals if requested
            if ($DeleteOriginals) {
                foreach ($file in $monthGroup.Group) {
                    if ($PSCmdlet.ShouldProcess($file.FullName, "Delete original file")) {
                        Remove-Item -Path $file.FullName -Force
                        Write-Verbose "  Deleted: $($file.Name)"
                    }
                }
                Write-Host "  Deleted $($monthGroup.Count) original files" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Error "Failed to archive files for $monthName : $_"
        }
    }
}

Write-Host "`nArchiving complete. Archives located in: $ArchivePath"