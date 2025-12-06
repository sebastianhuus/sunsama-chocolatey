# Technology Stack

## Package Management

- **Chocolatey**: Windows package manager for distribution
- **NuGet**: Package format (.nuspec for metadata)
- **PowerShell**: Installation scripts (chocolateyinstall.ps1)

## Automation

- **Python 3.12+**: Automation scripts
- **uv**: Python package manager and runner
- **Dependencies**: pefile (PE file parsing)
- **Shell**: Bash scripts for update workflow

## Tools Required

- `choco`: Chocolatey CLI
- `7zz`: 7-Zip for extracting NSIS installers
- `exiftool`: Metadata extraction from executables
- `curl`: Downloading installers
- `shasum`: SHA256 checksum calculation

## Common Commands

### Package Operations
```bash
# Pack the package
choco pack

# Test locally
choco install --source=. sunsama
choco upgrade --source=. sunsama

# Push to community repository
choco push sunsama.<VERSION>.nupkg --source https://push.chocolatey.org/ --api-key YOUR-API-KEY
```

### Automation
```bash
# Run update check (from automation directory)
./update-sunsama.sh

# Run with debug output
./update-sunsama.sh --debug

# Extract version from installer
uv run extract-version.py <path-to-installer>
```

### Manual Update Process
```bash
# 1. Download installer from https://www.sunsama.com/desktop
# 2. Generate checksum
checksum -t sha256 -f "path\to\installer.exe"
# 3. Update checksum in package/tools/chocolateyinstall.ps1
# 4. Update version in package/sunsama.nuspec
```
