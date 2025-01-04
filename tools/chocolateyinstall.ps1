$ErrorActionPreference = 'Stop'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://desktop.sunsama.com/'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'EXE'
  url           = $url
  checksum      = '07292508E8BFE72D661732B87DAE4B9B'
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512
  silentArgs   = '/S'
}

Install-ChocolateyPackage @packageArgs