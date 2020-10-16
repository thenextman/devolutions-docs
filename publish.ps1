
function Publish-DocfxSite {
	param(
    )
    
    $RootPath = Get-Location
    $SitePath = Join-Path $RootPath '_site'

    $DomainName = 'docs.devolutions.net'
    $GitUrl = 'git@github.com:Devolutions/devolutions-docs.git'

    $DocfxCommand = Get-Command -Name 'docfx' -ErrorAction SilentlyContinue

    if (-Not $DocfxCommand) {
        throw "'docfx' command was not found"
    }

    Remove-Item -Path $SitePath -Recurse -Force -ErrorAction SilentlyContinue

    & 'docfx' 'build' 'docs/docfx.json' '-o' $RootPath '--warningsAsErrors'

    if ($LASTEXITCODE -ne 0) {
        throw "docfx build command failed with exit code: $LASTEXITCODE"
    }

    if (-Not (Test-Path -Path $SitePath -PathType 'Container')) {
        throw "docfx site output path is empty ($SitePath)"
    }

    # Add CNAME file for github pages
    Set-Content -Path $(Join-Path $SitePath 'CNAME') -Value $DomainName -NoNewLine

    Push-Location
    Set-Location $SitePath

    & 'git' 'init' '.'
    & 'git' 'checkout' '-b' 'gh-pages'
    & 'git' 'remote' 'add' 'origin' $GitUrl
    & 'git' 'add' '-A'
    & 'git' 'commit' '-m' 'devolutions-docs: update site'

    & 'git' 'push' '-f' 'origin' 'gh-pages'

    Pop-Location
}

Publish-DocfxSite @args
