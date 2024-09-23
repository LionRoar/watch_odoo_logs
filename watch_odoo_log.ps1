param (
    [Parameter(Mandatory = $true, HelpMessage = "Specify the log file path using -l or --log")]
    [Alias("l", "log")]
    [string]$LogFile
)

# Define a function to colorize each part of the log line based on its type
function Colorize-LogLine {
    param (
        [string]$LogLine
    )

    # Check for Traceback first
    if ($LogLine -match "^Traceback \(most recent call last\):") {
        Write-Host "$LogLine" -ForegroundColor Magenta
    }
    elseif ($LogLine -match "^  File \"".*\"", line \d+, in .+") {
        Write-Host "$LogLine" -ForegroundColor DarkYellow  # File paths in dark yellow
    }
    elseif ($LogLine -match "(?i)^\s*.*Error\s*:.*") {
        Write-Host "$LogLine" -ForegroundColor Red  # Error message in red
    }
    # Regular log handling with different shades for each part
    elseif ($LogLine -match "^(\S+ \S+) (\d+) (\S+) (\S+ \S+\.\S+): (.*)$") {
        $timestamp = $matches[1]
        $processNumber = $matches[2]
        $logType = $matches[3]
        $location = $matches[4]
        $message = $matches[5]

        # Color codes based on log type (base color + variations for location and message)
        switch ($logType) {
            "ERROR" {
                $baseColor = "Red"
                $shadeColor = "DarkRed"
                $quoteColor = "Yellow"
            }
            "WARNING" {
                $baseColor = "Yellow"
                $shadeColor = "DarkYellow"
                $quoteColor = "Cyan"
            }
            "INFO" {
                $baseColor = "Green"
                $shadeColor = "DarkGreen"
                $quoteColor = "Magenta"
            }
            "DEBUG" {
                $baseColor = "Blue"
                $shadeColor = "DarkBlue"
                $quoteColor = "White"
            }
            "TRACEBACK" {
                $baseColor = "Magenta"
                $shadeColor = "DarkMagenta"
                $quoteColor = "Cyan"
            }
            default {
                $baseColor = "White"
                $shadeColor = "Gray"
                $quoteColor = "DarkCyan"  # Use dimmed cyan for other logs
            }
        }

        # Timestamp in gray
        Write-Host "$timestamp" -ForegroundColor Gray -NoNewline

        # Process number in dimmed cyan
        Write-Host " $processNumber" -ForegroundColor DarkCyan -NoNewline

        # Log type in base color
        Write-Host " $logType" -ForegroundColor $baseColor -NoNewline

        # Location in shade color
        Write-Host " $location`: " -ForegroundColor $shadeColor -NoNewline

        # Message: handle quotes, Python code, and normal text separately
        Colorize-Message -MessageText $message -BaseColor $shadeColor -QuoteColor $quoteColor
    }
    else {
        # If the line doesn't match the expected format, print it normally
        Write-Host $LogLine
    }
}

# Define a function to handle the coloring of the message text
function Colorize-Message {
    param (
        [string]$MessageText,
        [string]$BaseColor,
        [string]$QuoteColor
    )

    # Match quoted text (both single and double quotes) and code-like patterns
    $pattern = "([""'].*?[""']|[\w]+\s*=\s*.+|[\w]+\s*:\s*.+)"

    # Split the message based on the pattern and process each part
    $matches = [regex]::Matches($MessageText, $pattern)

    if ($matches.Count -gt 0) {
        $cursor = 0
        foreach ($match in $matches) {
            # Write the non-matching part of the message in base color
            if ($cursor -lt $match.Index) {
                $nonMatchingPart = $MessageText.Substring($cursor, $match.Index - $cursor)
                Write-Host $nonMatchingPart -ForegroundColor $BaseColor -NoNewline
            }

            # Write the matching part (quoted text or code-like structure) in the quote color
            Write-Host $match.Value -ForegroundColor $QuoteColor -NoNewline
            $cursor = $match.Index + $match.Length
        }

        # Write the remaining part of the message in base color
        if ($cursor -lt $MessageText.Length) {
            $remainingPart = $MessageText.Substring($cursor)
            Write-Host $remainingPart -ForegroundColor $BaseColor
        } else {
            Write-Host ""
        }
    } else {
        # If no matches, print the entire message in the base color
        Write-Host $MessageText -ForegroundColor $BaseColor
    }
}

# Define a function to read and colorize the log file in real-time
function TailLogWithColor {
    param (
        [string]$LogFilePath
    )

    # Check if the log file exists
    if (-not (Test-Path $LogFilePath)) {
        Write-Error "Log file does not exist: $LogFilePath"
        exit 1
    }

    # Tail the log file and pass each line to Colorize-LogLine for coloring
    Get-Content -Path $LogFilePath -Wait | ForEach-Object {
        Colorize-LogLine -LogLine $_
    }
}

# Main execution
try {
    TailLogWithColor -LogFilePath $LogFile
} catch {
    Write-Error "An error occurred while processing the log file."
}
