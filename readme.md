# Development Info

## How to Choco
When updating the package, pack it using:
`choco pack`

Test it locally using:
`choco install --source=. sunsama` (or upgrade with the below command)
`choco upgrade --source=. sunsama` 

Push update to community repo using:
`choco push sunsama.<VERSION>.nupkg --source https://push.chocolatey.org/ --api-key YOUR-API-KEY` (remember version)

## What to do when it breaks
1. Go to https://www.sunsama.com/desktop and download the desktop installer
2. Generate the checksum using:
```powershell
choco install checksum # you can skip this if you already have it
checksum -t sha256 -f "path\to\installer.exe"
```
3. Update the checksum in chocolateyinstall.ps1
4. Update the nuspec file with the new version number

# Notes
This is a manually updated package. Create an issue if this is out of date, or make a pull request.