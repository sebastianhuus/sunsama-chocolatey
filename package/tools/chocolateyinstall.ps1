$ErrorActionPreference = 'Stop'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://desktop.sunsama.com/'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'EXE'
  url           = $url
  checksum = 'd9764f27f6be3d0f6a93711c2891e409be7b2604f104b0f958445617d4ae07bd'
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512
  silentArgs   = '/S'
}

Install-ChocolateyPackage @packageArgs