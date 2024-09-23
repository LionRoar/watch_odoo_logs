# Watch odoo logs in color (Live) (Tail)

A PowerShell tool that colorizes Odoo log files in real-time, making it easier to identify important information such as errors, tracebacks, warnings, and more. The tool highlights different parts of the logs with color-coded output, providing a clearer view of the log structure.

## Features

- **Real-time log monitoring**: Continuously tail a log file and update the terminal as new entries appear.
- **Color-coded output**:
  - **Timestamps**: Gray.
  - **Process numbers**: Dimmed cyan.
  - **Log types**: Color-coded for clarity:
    - **ERROR**: Red
    - **WARNING**: Yellow
    - **INFO**: Green
    - **DEBUG**: Blue
  - **Tracebacks**: Python-style tracebacks are colorized to make file paths, line numbers, and error messages stand out.
  - **Quoted text**: Text enclosed in `'` or `"` is highlighted.
  - **Code-like structures**: Key-value pairs like `key = value` or `key: value` are highlighted for easier identification.

## Requirements

- PowerShell 7 (recommended for modern PowerShell scripting).
- A log file to monitor (e.g., `odoo.log`).

## Installation

1. Clone this repository to your local machine:
    ```bash
    git clone https://github.com/LionRoar/watch_odoo_logs.git
    ```

2. Navigate to the directory:
    ```bash
    cd watch_odoo_logs
    ```

## Usage

To use the tool, run the PowerShell script and pass the path of the Odoo log file you want to monitor:

```powershell
.\watch_odoo_logs.ps1 -l "C:\path\to\your\odoo.log"
```

## Customization
Adding or Modifying Log Colors
You can easily modify the colors assigned to various parts of the log by editing the script:

Log Type Colors: The color scheme for log types (ERROR, WARNING, INFO, etc.) can be changed by updating the color values in the switch block of the Colorize-LogLine function.

Traceback Coloring: Traceback lines, file paths, and error messages are highlighted separately. You can customize their colors as well.

Example Changes
```powershell
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
}

```