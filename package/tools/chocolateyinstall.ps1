﻿$ErrorActionPreference = 'Stop'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://desktop.sunsama.com/'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'EXE'
  url           = $url
  checksum = 'ad102f0afca8b8a85519a44b5c580b7a3b783a8d2ccd30e2d87ff97819241219'
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512
  silentArgs   = '/S'
}

Install-ChocolateyPackage @packageArgs