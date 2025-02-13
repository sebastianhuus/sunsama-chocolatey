$ErrorActionPreference = 'Stop'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://desktop.sunsama.com/'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'EXE'
  url           = $url
  checksum      = 'A0FEB53CB11987EA692AE5EBC8A1147F466E4B9F66233CFF2C2D370A6327EBDE'
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512
  silentArgs   = '/S'
}

Install-ChocolateyPackage @packageArgs