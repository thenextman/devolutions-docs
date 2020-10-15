
$RootPath = Get-Location
$SitePath = Join-Path $RootPath '_site'

Remove-Item -Path $SitePath -Recurse -Force -ErrorAction SilentlyContinue
& 'docfx' 'build' 'docs/docf.json' '-o' $RootPath
Set-Content -Path $(Join-Path $SitePath 'CNAME') -Value 'docs.devolutions.net' -NoNewLine
Set-Location $SitePath
& 'git' 'init' '.'
& 'git' 'checkout' '-b' 'gh-pages'
& 'git' 'remote' 'add' 'origin' 'git@github.com:Devolutions/devolutions-docs.git'
& 'git' 'add' '-A'
& 'git' 'commit' '-m' 'devolutions-docs: update site'
#& 'git' 'push' '-f' 'origin' 'gh-pages'
