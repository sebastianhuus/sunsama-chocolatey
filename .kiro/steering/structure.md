# Project Structure

## Root Directory

```
.
├── automation/          # Python automation scripts
├── package/            # Chocolatey package files
└── readme.md          # Development documentation
```

## Package Directory (`package/`)

Contains all Chocolatey package files:

- `sunsama.nuspec`: Package metadata (version, description, authors, tags)
- `sunsama.nuspec.bak`: Backup file (auto-generated)
- `sunsamaicon.png`: Package icon
- `tools/`: Installation scripts directory
  - `chocolateyinstall.ps1`: PowerShell installation script with download URL and checksum
  - `chocolateyinstall.ps1.bak`: Backup file (auto-generated)

## Automation Directory (`automation/`)

Python-based automation for package updates:

- `pyproject.toml`: Python project configuration (uv-managed)
- `uv.lock`: Locked dependencies
- `.python-version`: Python version specification (3.12+)
- `update-sunsama.sh`: Main update script (downloads, checks hash, updates files)
- `extract-version.py`: Extracts version from NSIS installer using 7zz/exiftool
- `main.py`: Placeholder for future automation

## Key Files to Modify

When updating the package:

1. **package/tools/chocolateyinstall.ps1**: Update `checksum` value
2. **package/sunsama.nuspec**: Update `<version>` tag

Both files have `.bak` backups created automatically by the update script.

## Conventions

- Backup files (`.bak`) are created when automation modifies package files
- Version numbers follow semantic versioning (e.g., 3.1.2)
- Checksums are SHA256 format
- Silent installation flag: `/S`
