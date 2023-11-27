<# 
    .Synopsis
    Create an BC21 Extension with default values
    .Description
    Creates the full extension structure
    .Parameter Path
    Path for the destination for the extension structure
    .Parameter AppName
    Specifies the app name
    .Parameter Version
    Specifies the app version
    .Parameter Publisher
    Specifies the publisher of the app. Default is 'SOCITAS'
    .Parameter SupportedCounties
    Specifies the supported countries for the appsourcecop. Default is '"US", "DE"'
    .Parameter MandatoryAffixes
    Specifies the affix for object and field names. Defaultvalue is 'SOC'
    .Parameter FromIdRange
    Id range where the objects have to start. Defaultvalue is '50500'
    .Parameter ToIdRange
    Id range where the objects id range ends. Defaultvalue is '99999'
    .Parameter RunTime
    Specifies the runtime version. Defaultvalue is '10.0'
    .Parameter Target
    Specifies the target of the extension. Defaultvalue is 'Cloud'
    .Example
    New-BC21Extension "C:\Temp" 'Example App Name'
    .Example
    New-BC21Extension "C:\Temp" 'Example App Name' -Version '21.0.0.0' -Publisher 'SOCITAS' -MandatoryAffixes 'SOC' -FromIdRange 60000 -ToIdRange 70000 -Target OnPrem
#>

function New-BC21Extension {
  [cmdletbinding()]
  Param (
    [Parameter(Position = 0, Mandatory = $true)]
    [String]$Path,
    [Parameter(Position = 1, Mandatory = $true)]
    [String]$AppName,    
    [String]$Version = '21.0.0.0',
    [String]$Publisher = 'SOCITAS',
    [String]$SupportedCountries = '"US", "DE"',
    [String]$MandatoryAffixes = 'SOC',
    [Int32]$FromIdRange = 50500,
    [Int32]$ToIdRange = 94999,
    [Int32]$TestAppFromIdRange = 95000,
    [Int32]$TestAppToIdRange = 99999,  
    [String]$RunTime = '10.0',
    [Parameter(Mandatory = $false)]    
    [ValidateSet('OnPrem', 'Cloud')]
    [string] $Target = 'Cloud'
  )
  
  $AppId = [guid]::NewGuid()
  $TestAppId = [guid]::NewGuid()

  function GetStandardLogo() {
    return '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'
  }

  function GetAppJson([Parameter(Mandatory = $true)]$Publisher, [Parameter(Mandatory = $true)]$AppName, [Parameter(Mandatory = $true)]$Version, [Parameter(Mandatory = $true)]$fromId, [Parameter(Mandatory = $true)]$toId) {
    $json = 
    '{
  "id": "' + $AppId + '",
  "name": "' + $AppName + '",
  "publisher": "' + $Publisher + '",
  "version": "' + $Version + '",
  "brief": "",
  "description": "",
  "privacyStatement": "http://www.socitas.de",
  "EULA": "http://www.socitas.de",
  "help": "http://www.socitas.de",
  "url": "http://www.socitas.de",
  "contextSensitiveHelpUrl": "http://www.socitas.de",  
  "logo": "res/logo.png",
  "application": "21.0.0.0",
  "platform": "21.0.0.0",
  "idRanges": [
    {
      "from": ' + $fromId + ',
      "to": ' + $toId + '
    }
  ],
  "dependencies": [],
  "internalsVisibleTo": [
    {
      "id": "' + $TestAppId + '",
      "name": "' + $AppName + ' TestApp",
      "publisher": "' + $Publisher + '"
    }
  ],   
  "resourceExposurePolicy": {
    "allowDebugging": true,
    "allowDownloadingSource": true,
    "includeSourceInSymbolFile": true
  },
  "runtime": "' + $RunTime + '",
  "target": "' + $Target + '",  
  "features": [
    "TranslationFile", 
    "NoImplicitWith"
  ],
  "supportedLocales": [
    "en-US",
    "de-DE"
  ],
  "applicationInsightsConnectionString": "InstrumentationKey=55dfa04d-b15c-49d4-956c-f764e9b87576;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/"  
}'
    return $json
  }

  function GetTestAppJson([Parameter(Mandatory = $true)]$Publisher, [Parameter(Mandatory = $true)]$AppName, [Parameter(Mandatory = $true)]$Version, [Parameter(Mandatory = $true)]$fromId, [Parameter(Mandatory = $true)]$toId) {
    $json = 
    '{
  "id": "' + $TestAppId + '",
  "name": "' + $AppName + ' TestApp",
  "publisher": "' + $Publisher + '",
  "version": "' + $Version + '",
  "brief": "Various Tests",
  "description": "Various Tests",
  "privacyStatement": "http://www.socitas.de",
  "EULA": "http://www.socitas.de",
  "help": "http://www.socitas.de",
  "url": "http://www.socitas.de",
  "contextSensitiveHelpUrl": "http://www.socitas.de",  
  "logo": "res/logo.png",
  "application": "21.0.0.0",
  "platform": "21.0.0.0",
  "idRanges": [
    {
      "from": ' + $fromId + ',
      "to": ' + $toId + '
    }
  ],
  "dependencies": [
    {
      "id": "' + $AppId + '",
      "name": "' + $AppName + '",
      "publisher": "' + $Publisher + '",
      "version": "' + $Version + '"
    }
  ],
  "resourceExposurePolicy": {
    "allowDebugging": true,
    "allowDownloadingSource": true,
    "includeSourceInSymbolFile": true
  },
  "runtime": "' + $RunTime + '",
  "target": "' + $Target + '",  
  "features": [
    "TranslationFile", 
    "NoImplicitWith"
  ],
  "supportedLocales": [
    "en-US",
    "de-DE"
  ]
}'

    return $json
  }

  function GetAppSourceCopJson([Parameter(Mandatory = $true)]$SupportedCountries, [Parameter(Mandatory = $true)]$MandatoryAffixes) {
    $json = 
    '{
  "mandatoryAffixes": ["' + $MandatoryAffixes + '"],
  "supportedCountries": [' + $SupportedCountries + ']
}'
    return $json
  }

  function GetSettingsJson() {
    $json = 
    '{
  "al.codeAnalyzers": [
    "${AppSourceCop}",
    "${CodeCop}",
    "${PerTenantExtensionCop}",
    "${UICop}"
  ],
  "al.enableCodeActions": true,
  "al.enableCodeAnalysis": true,
  "CRS.RemoveSuffixFromFilename": true,
  "CRS.ObjectNameSuffix": " SOC",
  "CRS.FileNamePattern": "<ObjectNameShort>.<ObjectTypeShortPascalCase>.al",
  "CRS.FileNamePatternExtensions": "<ObjectNameShort>.<ObjectTypeShortPascalCase>.al",
  "CRS.FileNamePatternPageCustomizations": "<ObjectNameShort>.<ObjectTypeShortPascalCase>.al",
  "CRS.OnSaveAlFileAction": "Reorganize",
  "al.ruleSetPath": ".codeanalyzer/SOCITAS.ruleset.json",
  "search.exclude": {
    "**/node_modules": true,
    "**/bower_components": true,
    "**/*.code-search": true,
    "**/.alcache": true,
  },
  "git.enabled": true,
  "git.autofetch": true,
  "git.autofetchPeriod": 30,
  "git.fetchOnPull": true,
  "rest-client.enableTelemetry": false,
  "al.compilationOptions": {
    "maxDegreeOfParallelism": 16,
    "parallel": true
  },
  "al.assemblyProbingPaths": [
    "./.netpackages",
    "c:/Windows/assembly/",
    "C:/Program Files/Microsoft Dynamics 365 Business Central/210/Service/Add-ins"
  ],
  "editor.codeActionsOnSave": {
    "source.fixAll.al": true,          
  },
  "alOutline.codeActionsOnSave": [
    "SortProcedures", "SortProperties", "SortReportColumns", "SortVariables",
  ],   
}'
    return $json 
  }

  function GetGitIgnore() {
    $content = 
    '*/[Tt]emp/
*/.vscode/launch*.json
*/.vscode/.alcache/*
*/.vscode/.altemplates
*/.vscode/rad.json
*/permissionsAnalyzer.json
*/extensionsPermissionSet.xml
*/.alpackages/
*/.altestrunner/
*.g.xlf
*.app
!/test/dependencies/*
!/app/dependencies/*
*/.snapshots/'

    return $content
  }

  function GetWorkspace() {
    $json = 
    '{
  "folders": [
    {
      "path": "app"
    },
    {
      "path": "test"
    }
  ],
  "settings": {
    "todo-tree.general.tags": [
      "BUG",
      "FIXME",
      "TODO",
      "REFACT"
    ],
    "git.confirmSync": false,
    "git.postCommitCommand": "sync",
    "objectIdNinja.backEndUrl": "socfaalninja.azurewebsites.net",
    "objectIdNinja.backEndAPIKey": "QQQkuWPjnqzcZBZPreLt+oN0Ppoll1h6WMaS4wIOaNcAtyv5Kaq4RxefthgIWzwR0Dh5j3MfOsQDzpE4GUr76Q==",
    "objectIdNinja.backEndUrlPoll": "socfaalpoll.azurewebsites.net",
    "objectIdNinja.backEndAPIKeyPoll": "Qgt5Nc/Ovy0H0jNlJS8jai8XjiId1AAEDwXNUgjycOZI+jFrCfhZWWkV23c5i2eMaEBg8L1aiLdbkG2F/Mn9EQ==",
  }
}'

    return $json
  }

  function GetExtensionRecommendations() {
    $json = '{
      "recommendations": [
          "ms-dynamics-smb.al",
          "usernamehw.errorlens",
          "vjeko.vjeko-al-objid"
      ]
  }'

    return $json
  }

  function GetRuleset() {
    $json =  
    '{
  "name": "Socitas Ruleset",
  "rules": [
    {
      "id": "AS0053",
      "action": "None",
      "justification": "Ignore SaaS environment check"
    },
    {
      "id": "PTE0005",
      "action": "None",
      "justification": "Ignore SaaS environment check"
    },
    {
      "id": "AA0214",
      "action": "None",
      "justification": "Not possible to solve"
    },
    {
      "id": "AS0084",
      "action": "None",
      "justification": "Ignore AppStore Id Range"
    },
    {
      "id": "AS0092",
      "action": "None",
      "justification": "Ignore Application Insight"
    },
    {
      "id": "AS0081",
      "action": "None",
      "justification": "Disabled for Test App"
    },
    {
      "id": "PTE0012",
      "action": "None",
      "justification": "Disabled for Test App"
    }
  ]
}'

    return $json
  }

  function GetPipelineSettings() {
    $content = 
    '{
    "name":"' + $AppName + '",
    "memoryLimit": "10G",
    "installApps": "",
    "installTestApps": "",
    "previousApps": "",
    "appFolders": "app",
    "doNotRunTests": false,    
    "installTestRunner": false,
    "installTestFramework": false,
    "installTestLibraries": false,
    "installPerformanceToolkit": false,
    "doNotSignApps": false,
    "enableCodeCop": true,
    "enableAppSourceCop": true,
    "enablePerTenantExtensionCop": true,
    "enableUICop": true,
    "bcContainerHelperVersion": "preview",
    "additionalCountries": "",
    "vaultNameForLocal": "KeyVault",
    "rulesetFile": "app/.codeanalyzer/SOCITAS.ruleset.json",
    "AppSourceCopMandatoryAffixes": "SOC",
    "AppSourceCopSupportedCountries": "US,DE",    
    "versions": [
        {
            "version": "ci",
            "artifact": "/onprem/21.0.46256.46853/de",
            "cacheImage": true,
            "CreateRuntimePackages": true
        },
        {
            "version": "current",
            "artifact": "///de/Current"
        },
        {
            "version": "cloud",
            "artifact": "///de/Current"
        },
        {
            "version": "nextmajor",
            "artifact": "///de/NextMajor/{INSIDERSASTOKEN}"
        },
        {
            "version": "nextminor",
            "artifact": "///de/NextMinor/{INSIDERSASTOKEN}"
        }
    ]
}'

    return $content
  }

  function GetReadSettings {
    $Content = 
    'Param(
  [Parameter(Mandatory=$false)]
  [ValidateSet(''Local'', ''AzureDevOps'', ''GithubActions'', ''GitLab'')]
  [string] $environment = ''Local'',
  [string] $version = ""
)

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

$agentName = ""
if ($environment -ne ''Local'') {
    $agentName = $ENV:AGENT_NAME
}

$settings = (Get-Content (Join-Path $PSScriptRoot "settings.json") | ConvertFrom-Json)
if ("$version" -eq "")  {
    $version = $settings.versions[0].version
    Write-Host "Version not defined, using $version"
}

$buildversion = $settings.versions | Where-Object { $_.version -eq $version }
if ($buildversion) {
    Write-Host "Set artifact = $($buildVersion.artifact)"
    Set-Variable -Name "artifact" -Value $buildVersion.artifact
}
else {
    throw "Unknown version: $version"
}

$pipelineName = "$($settings.Name)-$version"
Write-Host "Set pipelineName = $pipelineName"

if ($agentName) {
    $containerName = "$($agentName -replace ''[^a-zA-Z0-9---]'', '''')-$($pipelineName -replace ''[^a-zA-Z0-9---]'', '''')".ToLowerInvariant()
}
else {
    $containerName = "$($pipelineName.Replace(''.'',''-'') -replace ''[^a-zA-Z0-9---]'', '''')".ToLowerInvariant()
}
Write-Host "Set containerName = $containerName"
if ($environment -eq ''AzureDevOps'') {
    Write-Host "##vso[task.setvariable variable=containerName]$containerName"
}

"installApps", "installTestApps", "previousApps", "appSourceCopMandatoryAffixes", "appSourceCopSupportedCountries", "appFolders", "testFolders", "memoryLimit", "additionalCountries", "genericImageName", "vaultNameForLocal", "bcContainerHelperVersion", "rulesetFile" | ForEach-Object {
    $str = ""
    if ($buildversion.PSObject.Properties.Name -eq $_) {
        $str = $buildversion."$_"
    }
    elseif ($settings.PSObject.Properties.Name -eq $_) {
        $str = $settings."$_"
    }
    Write-Host "Set $_ = ''$str''"
    Set-Variable -Name $_ -Value "$str"
}

"doNotRunTests","doNotRunBcptTests","installTestRunner", "installTestFramework", "installTestLibraries", "installPerformanceToolkit", "enableCodeCop", "enableAppSourceCop", "enablePerTenantExtensionCop", "enableUICop", "doNotSignApps", "doNotRunTests", "cacheImage", "CreateRuntimePackages" | ForEach-Object {
    $str = "False"
    if ($buildversion.PSObject.Properties.Name -eq $_) {
        $str = $buildversion."$_"
    }
    elseif ($settings.PSObject.Properties.Name -eq $_) {
        $str = $settings."$_"
    }
    Write-Host "Set $_ = $str"
    Set-Variable -Name $_ -Value ($str -eq "True")
}

$imageName = ""
if ($cacheImage -and ("$AgentName" -ne "Hosted Agent" -and "$AgentName" -notlike "Azure Pipelines*")) {
    $imageName = "bcimage"
}'

    return $content
  }

  function GetBcContainerHelper {
    $content =
    'Param(
    [string] $bcContainerHelperVersion = "",
    [string] $genericImageName = ""
)

if ($bcContainerHelperVersion -eq "") { $bcContainerHelperVersion = "latest" }
if ($bccontainerHelperVersion -eq "dev") { $bccontainerHelperVersion = "https://github.com/microsoft/navcontainerhelper/archive/dev.zip" }

if ((Test-Path $bcContainerHelperVersion) -and (Test-Path (Join-Path $bcContainerHelperVersion "bcContainerHelper.ps1"))) {
    $path = $bcContainerHelperVersion
}
elseif ($bccontainerHelperVersion -like "https://*") {
    $path = Join-Path $env:TEMP ([Guid]::NewGuid().ToString())
}
else {
    $bcbaseurl = "https://bccontainerhelper.azureedge.net/public"
    $versionsxml = [xml](New-Object System.Net.WebClient).DownloadString("$($bcbaseurl)?comp=list&restype=container")
    
    $latestVersion = $versionsxml.EnumerationResults.Blobs.Blob.Name | Where-Object { $_ -ne "latest.zip" -and $_ -notlike "*preview*" } | ForEach-Object { $_.replace(''.zip'','''') } | Sort-Object { [Version]$_ } | Select-Object -Last 1
    $previewVersion = $versionsxml.EnumerationResults.Blobs.Blob.Name | Where-Object { $_ -like "*-preview*" } | ForEach-Object { $_.replace(''.zip'','''') } | Sort-Object { [Version]($_.replace(''-preview'',''.'')) } | Select-Object -Last 1
    if ([version]$latestVersion -ge [version]($previewVersion.split(''-'')[0])) {
        $previewVersion = $latestVersion
    }
    
    if ($bccontainerHelperVersion -eq "latest") {
        $bccontainerHelperVersion = $latestVersion
    }
    elseif ($bccontainerHelperVersion -eq "preview") {
        $bccontainerHelperVersion = $previewVersion
    }
    $basePath = Join-Path $env:ProgramFiles "WindowsPowerShell\Modules\BcContainerHelper"
    if (!(Test-Path $basePath)) { New-Item $basePath -ItemType Directory | Out-Null }
    $path = Join-Path $basePath $bccontainerHelperVersion
    $bccontainerHelperVersion = "$bcbaseurl/$bccontainerHelperVersion.zip"
}

$bchMutexName = "bcContainerHelper"
$bchMutex = New-Object System.Threading.Mutex($false, $bchMutexName)
try {
    try { $bchMutex.WaitOne() | Out-Null } catch {}
    if (!(Test-Path $path)) {
        $tempName = Join-Path $env:TEMP ([Guid]::NewGuid().ToString())
        Write-Host "Downloading $bccontainerHelperVersion"
        (New-Object System.Net.WebClient).DownloadFile($bccontainerHelperVersion, "$tempName.zip")
        Expand-Archive -Path "$tempName.zip" -DestinationPath $tempName
        $folder = (Get-Item -Path (Join-Path $tempName ''*'')).FullName
        [System.IO.Directory]::Move($folder,$path)
    }
}
finally {
    $bchMutex.ReleaseMutex()
}
. (Join-Path $path "BcContainerHelper.ps1")

if ($genericImageName) {
    $bcContainerHelperConfig.genericImageName = $genericImageName
}'

    return $content
  }

  function GetDevOpsPipeline {
    $content =
    'Param(
    [Parameter(Mandatory=$false)]
    [ValidateSet(''AzureDevOps'',''GithubActions'',''GitLab'')]
    [string] $environment = ''AzureDevOps'',
    [Parameter(Mandatory=$true)]
    [string] $version,
    [Parameter(Mandatory=$false)]
    [int] $appBuild = 0,
    [Parameter(Mandatory=$false)]
    [int] $appRevision = 0
)

if ($environment -eq "AzureDevOps") {
    $buildArtifactFolder = $ENV:BUILD_ARTIFACTSTAGINGDIRECTORY
}
elseif ($environment -eq "GitHubActions") {
    $buildArtifactFolder = Join-Path $ENV:GITHUB_WORKSPACE "output"
    New-Item $buildArtifactFolder -ItemType Directory | Out-Null
}

$baseFolder = (Get-Item (Join-Path $PSScriptRoot "..")).FullName
. (Join-Path $PSScriptRoot "Read-Settings.ps1") -environment $environment -version $version
. (Join-Path $PSScriptRoot "Install-BcContainerHelper.ps1") -bcContainerHelperVersion $bcContainerHelperVersion -genericImageName $genericImageName

$authContext = $null
$refreshToken = "$($ENV:BcSaasRefreshToken)"
$environmentName = "$($ENV:EnvironmentName)"
if ($refreshToken -and $environmentName) {
    $authContext = New-BcAuthContext -refreshToken $refreshToken
    if (Get-BcEnvironments -bcAuthContext $authContext | Where-Object { $_.Name -eq $environmentName -and  $_.type -eq "Sandbox" }) {
        Remove-BcEnvironment -bcAuthContext $authContext -environment $environmentName
    }
    $countryCode = $artifact.Split(''/'')[3]
    New-BcEnvironment -bcAuthContext $authContext -environment $environmentName -countryCode $countrycode -environmentType "Sandbox" | Out-Null
    do {
        Start-Sleep -Seconds 10
        $baseApp = Get-BcPublishedApps -bcAuthContext $authContext -environment $environmentName | Where-Object { $_.Name -eq "Base Application" }
    } while (!($baseApp))
    $baseapp | Out-Host

    $artifact = Get-BCArtifactUrl `
        -country $countryCode `
        -version $baseApp.Version `
        -select Closest
    
    if ($artifact) {
        Write-Host "Using Artifacts: $artifact"
    }
    else {
        throw "No artifacts available"
    }
}

$params = @{}
$insiderSasToken = "$ENV:insiderSasToken"
$licenseFile = "$ENV:licenseFile"
$codeSigncertPfxFile = "$ENV:CodeSignCertPfxFile"
if (!$doNotSignApps -and $codeSigncertPfxFile) {
    if ("$ENV:CodeSignCertPfxPassword" -ne "") {
        $codeSignCertPfxPassword = try { "$ENV:CodeSignCertPfxPassword" | ConvertTo-SecureString } catch { ConvertTo-SecureString -String "$ENV:CodeSignCertPfxPassword" -AsPlainText -Force }
        $params = @{
            "codeSignCertPfxFile" = $codeSignCertPfxFile
            "codeSignCertPfxPassword" = $codeSignCertPfxPassword
        }
    }
    else {
        $codeSignCertPfxPassword = $null
    }
}

$allTestResults = "testresults*.xml"
$testResultsFile = Join-Path $baseFolder "TestResults.xml"
$testResultsFiles = Join-Path $baseFolder $allTestResults
if (Test-Path $testResultsFiles) {
    Remove-Item $testResultsFiles -Force
}

Run-AlPipeline @params `
    -pipelinename $pipelineName `
    -containerName $containerName `
    -imageName $imageName `
    -bcAuthContext $authContext `
    -environment $environmentName `
    -artifact $artifact.replace(''{INSIDERSASTOKEN}'',$insiderSasToken) `
    -memoryLimit $memoryLimit `
    -baseFolder $baseFolder `
    -licenseFile $LicenseFile `
    -installApps $installApps `
    -installTestApps $installTestApps `
    -previousApps $previousApps `
    -appFolders $appFolders `
    -testFolders $testFolders `
    -doNotRunTests:$doNotRunTests `
    -testResultsFile $testResultsFile `
    -testResultsFormat ''JUnit'' `
    -installTestRunner:$installTestRunner `
    -installTestFramework:$installTestFramework `
    -installTestLibraries:$installTestLibraries `
    -installPerformanceToolkit:$installPerformanceToolkit `
    -enableCodeCop:$enableCodeCop `
    -enableAppSourceCop:$enableAppSourceCop `
    -enablePerTenantExtensionCop:$enablePerTenantExtensionCop `
    -enableUICop:$enableUICop `
    -azureDevOps:($environment -eq ''AzureDevOps'') `
    -gitLab:($environment -eq ''GitLab'') `
    -gitHubActions:($environment -eq ''GitHubActions'') `
    -failOn ''error'' `
    -AppSourceCopMandatoryAffixes $appSourceCopMandatoryAffixes `
    -AppSourceCopSupportedCountries $appSourceCopSupportedCountries `
    -additionalCountries $additionalCountries `
    -buildArtifactFolder $buildArtifactFolder `
    -CreateRuntimePackages:$CreateRuntimePackages `
    -appBuild $appBuild -appRevision $appRevision `
    -rulesetFile $rulesetFile `
    -accept_insiderEula

if ($environment -eq ''AzureDevOps'') {
    Write-Host "##vso[task.setvariable variable=TestResults]$allTestResults"
}'
    return $content
  }

  function GetCleanup {
    $content = 
    'Param(
    [Parameter(Mandatory=$false)]
    [ValidateSet(''Local'', ''AzureDevOps'', ''GithubActions'', ''GitLab'')]
    [string] $environment = ''Local''
)

. (Join-Path $PSScriptRoot "Read-Settings.ps1") -environment $environment
. (Join-Path $PSScriptRoot "Install-BcContainerHelper.ps1") -bcContainerHelperVersion $bcContainerHelperVersion

$refreshToken = "$($ENV:BcSaasRefreshToken)"
$environmentName = "$($ENV:EnvironmentName)"

if ($refreshToken -and $environmentName) {
    $authContext = New-BcAuthContext -refreshToken $refreshToken
    if (Get-BcEnvironments -bcAuthContext $authContext | Where-Object { $_.Name -eq $environmentName -and  $_.type -eq "Sandbox" }) {
        Remove-BcEnvironment -bcAuthContext $authContext -environment $environmentName
    }
}

if ("$AgentName" -ne "Hosted Agent" -and "$AgentName" -notlike "Azure Pipelines*") {
    $cleanupMutexName = "Cleanup"
    $cleanupMutex = New-Object System.Threading.Mutex($false, $cleanupMutexName)
    try {
        try {
            if (!$cleanupMutex.WaitOne(1000)) {
                Write-Host "Waiting for other process to finish cleanup"
                $cleanupMutex.WaitOne() | Out-Null
                Write-Host "Other process completed"
            }
        }
        catch [System.Threading.AbandonedMutexException] {
            Write-Host "Other process terminated abnormally"
        }
    
        Remove-BcContainer -containerName $containerName
        Flush-ContainerHelperCache -KeepDays 2
        
        Remove-Module BcContainerHelper
        $path = Join-Path $ENV:Temp $containerName
        if (Test-Path $path) {
            Remove-Item $path -Recurse -Force
        }
    }
    finally {
        $cleanupMutex.ReleaseMutex()
    }
}'

    return $content
  }

  function GetCiYml {
    $content = 
    'trigger:
- none

pool:
  name: SOCITAS

variables:
- group: KeyVault

jobs:
- job: Build
  timeoutInMinutes: 300
  variables:
    build.clean: all
    platform: x64
    version: ''ci''
    appVersion: ''21.0''
    appBuild: $(Build.BuildID)
    appRevision: 0
    skipComponentGovernanceDetection: True

  steps:
  - task: PowerShell@2
    displayName: ''Set BuildNumber''
    inputs:
      targetType: inline
      script: ''Write-Host "##vso[build.updatebuildnumber]$(appVersion).$(appBuild).$(appRevision)"''

  - task: PowerShell@2
    displayName: ''Run Pipeline''
    env:
      InsiderSasToken: ''$(InsiderSasToken)''
      LicenseFile: ''$(BcLicenseFile)''
      CodeSignCertPfxFile: ''$(CodeSignCertPfxFile)''
      CodeSignCertPfxPassword: ''$(CodeSignCertPfxPassword)''
    inputs:
      targetType: filePath
      filePath: ''scripts\DevOps-Pipeline.ps1''
      arguments: ''-environment "AzureDevOps" -version "$(version)" -appBuild $(appBuild) -appRevision $(appRevision)''
      failOnStderr: true

  - task: PublishTestResults@2
    displayName: ''Publish Test Results''
    condition: and(succeeded(),ne(variables[''TestResults''],''''))
    inputs:
      testResultsFormat: JUnit
      testResultsFiles: ''$(testResults)''
      failTaskOnFailedTests: true

  - task: PublishBuildArtifacts@1
    displayName: ''Publish Artifacts''
    inputs:
      PathtoPublish: ''$(Build.ArtifactStagingDirectory)''
      ArtifactName: output

  - task: PowerShell@2
    displayName: ''Cleanup''
    condition: always()
    inputs:
      targetType: filePath
      filePath: ''scripts\Cleanup.ps1''
      arguments: ''-environment "AzureDevOps"''
      failOnStderr: false
'
    return $content
  }

  function GetCloudYml {
    $content = 
    'trigger: 
- none

schedules:
- cron: ''0 0 * * *''
  displayName: ' + $AppName + ' - Daily Cloud
  branches:
    include:
    - main
  always: true

pool:
  name: SOCITAS

variables:
- group: KeyVault

jobs:
- job: Build
  timeoutInMinutes: 300
  variables:
    build.clean: all
    platform: x64
    version: ''cloud''
    appVersion: ''21.0''
    appBuild: 2147483647
    appRevision: 0
    skipComponentGovernanceDetection: True
    environmentName: devopsHelloWorld

  steps:
  - task: PowerShell@2
    displayName: ''Run Pipeline''
    env:
      InsiderSasToken: ''$(InsiderSasToken)''
      LicenseFile: ''$(BcLicenseFile)''
      CodeSignCertPfxFile: ''$(CodeSignCertPfxFile)''
      CodeSignCertPfxPassword: ''$(CodeSignCertPfxPassword)''
      BcSaasRefreshToken: ''$(BcSaasRefreshToken)''
      EnvironmentName: ''$(environmentName)''
    inputs:
      targetType: filePath
      filePath: ''scripts\DevOps-Pipeline.ps1''
      arguments: ''-environment "AzureDevOps" -version "$(version)" -appBuild $(appBuild) -appRevision $(appRevision)''
      failOnStderr: true

  - task: PublishTestResults@2
    displayName: ''Publish Test Results''
    condition: and(succeeded(),ne(variables[''TestResults''],''''))
    inputs:
      testResultsFormat: JUnit
      testResultsFiles: ''$(testResults)''
      failTaskOnFailedTests: true

  - task: PowerShell@2
    displayName: ''Cleanup''
    condition: always()
    env:
      BcSaasRefreshToken: ''$(BcSaasRefreshToken)''
      EnvironmentName: ''$(environmentName)''
    inputs:
      targetType: filePath
      filePath: ''scripts\Cleanup.ps1''
      arguments: ''-environment "AzureDevOps"''
      failOnStderr: false
'
    return $content
  } 
  
  function GetCurrentYml {
    $content = 
    'trigger: 
- none

schedules:
- cron: ''0 0 * * *''
  displayName: ' + $AppName + ' - Daily Current
  branches:
    include:
    - main
  always: true

pool:
  name: SOCITAS

variables:
- group: KeyVault

jobs:
- job: Build
  timeoutInMinutes: 300
  variables:
    build.clean: all
    platform: x64
    version: ''current''
    appBuild: 2147483647
    appRevision: 0
    skipComponentGovernanceDetection: True

  steps:
  - task: PowerShell@2
    displayName: ''Run Pipeline''
    env:
      InsiderSasToken: ''$(InsiderSasToken)''
      LicenseFile: ''$(BcLicenseFile)''
      CodeSignCertPfxFile: ''$(CodeSignCertPfxFile)''
      CodeSignCertPfxPassword: ''$(CodeSignCertPfxPassword)''
    inputs:
      targetType: filePath
      filePath: ''scripts\DevOps-Pipeline.ps1''
      arguments: ''-environment "AzureDevOps" -version "$(version)" -appBuild $(appBuild) -appRevision $(appRevision)''
      failOnStderr: true

  - task: PublishTestResults@2
    displayName: ''Publish Test Results''
    condition: and(succeeded(),ne(variables[''TestResults''],''''))
    inputs:
      testResultsFormat: JUnit
      testResultsFiles: ''$(testResults)''
      failTaskOnFailedTests: true
  
  - task: PowerShell@2
    displayName: ''Cleanup''
    condition: always()
    inputs:
      targetType: filePath
      filePath: ''scripts\Cleanup.ps1''
      arguments: ''-environment "AzureDevOps"''
      failOnStderr: false
'
    return $content
  }  

  function GetNextMajorYml {
    $content = 
    'trigger: 
- none

schedules:
- cron: ''0 0 * * *''
  displayName: ' + $AppName + ' - Daily Next Major
  branches:
    include:
    - main
  always: true

pool:
  name: SOCITAS

variables:
- group: KeyVault

jobs:
- job: Build
  timeoutInMinutes: 300
  variables:
    build.clean: all
    platform: x64
    version: "nextmajor"
    appBuild: 2147483647
    appRevision: 0
    skipComponentGovernanceDetection: True

  steps:
  - task: PowerShell@2
    displayName: ''Run Pipeline''
    env:
      InsiderSasToken: ''$(InsiderSasToken)''
      LicenseFile: ''$(BcLicenseFile)''
      CodeSignCertPfxFile: ''$(CodeSignCertPfxFile)''
      CodeSignCertPfxPassword: ''$(CodeSignCertPfxPassword)''
    inputs:
      targetType: filePath
      filePath: ''scripts\DevOps-Pipeline.ps1''
      arguments: ''-environment "AzureDevOps" -version "$(version)" -appBuild $(appBuild) -appRevision $(appRevision)''
      failOnStderr: true

  - task: PublishTestResults@2
    displayName: ''Publish Test Results''
    condition: and(succeeded(),ne(variables[''TestResults''],''''))
    inputs:
      testResultsFormat: JUnit
      testResultsFiles: ''$(testResults)''
      failTaskOnFailedTests: true
  
  - task: PowerShell@2
    displayName: ''Cleanup''
    condition: always()
    inputs:
      targetType: filePath
      filePath: ''scripts\Cleanup.ps1''
      arguments: ''-environment "AzureDevOps"''
      failOnStderr: false
'
    return $content
  }

  function GetNextMinorYml {
    $content =
    'trigger: 
- none

schedules:
- cron: ''0 0 * * *''
  displayName: ' + $AppName + ' - Daily Next Minor
  branches:
    include:
    - main
  always: true

pool:
  name: SOCITAS

variables:
- group: KeyVault

jobs:
- job: Build
  timeoutInMinutes: 300
  variables:
    build.clean: all
    platform: x64
    version: "nextminor"
    appBuild: 2147483647
    appRevision: 0
    skipComponentGovernanceDetection: True

  steps:
  - task: PowerShell@2
    displayName: ''Run Pipeline''
    env:
      InsiderSasToken: ''$(InsiderSasToken)''
      LicenseFile: ''$(BcLicenseFile)''
      CodeSignCertPfxFile: ''$(CodeSignCertPfxFile)''
      CodeSignCertPfxPassword: ''$(CodeSignCertPfxPassword)''
    inputs:
      targetType: filePath
      filePath: ''scripts\DevOps-Pipeline.ps1''
      arguments: ''-environment "AzureDevOps" -version "$(version)" -appBuild $(appBuild) -appRevision $(appRevision)''
      failOnStderr: true

  - task: PublishTestResults@2
    displayName: ''Publish Test Results''
    condition: and(succeeded(),ne(variables[''TestResults''],''''))
    inputs:
      testResultsFormat: JUnit
      testResultsFiles: ''$(testResults)''
      failTaskOnFailedTests: true
  
  - task: PowerShell@2
    displayName: ''Cleanup''
    condition: always()
    inputs:
      targetType: filePath
      filePath: ''scripts\Cleanup.ps1''
      arguments: ''-environment "AzureDevOps"''
      failOnStderr: false
'
    return $content
  }  
  
  if (Test-Path -Path (Join-Path -Path $Path -ChildPath $AppName)) {
    Remove-Item -Path (Join-Path -Path $Path -ChildPath $AppName) -Recurse
  }

  $appFolders = @('app', 'test')
  foreach ($appFolder in $appFolders) {
    Write-Host -Object "Creating $appFolder directory ..."
    $appDirectory = (Join-Path -Path (Join-Path -Path $Path -ChildPath $AppName) -ChildPath $appFolder)

    if (Test-Path -Path $appDirectory) {
      Write-Error -Message $('App Directory ' + $appDirectory + ' already exists.')
      return
    }
    Write-Host -Object '  Create directory structure ...'
    $null = New-Item -ItemType Directory -Path $appDirectory

    # Create folder structure
    $null = New-Item -ItemType Directory -Path (Join-Path -Path $appDirectory -ChildPath 'res')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path $appDirectory -ChildPath 'doc')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path $appDirectory -ChildPath 'temp')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path $appDirectory -ChildPath '.vscode')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path $appDirectory -ChildPath '.alpackages')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path $appDirectory -ChildPath '.codeanalyzer')    
    $null = New-Item -ItemType Directory -Path (Join-Path -Path $appDirectory -ChildPath 'translations')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path $appDirectory -ChildPath 'dependencies')    

    # Create Object directories
    $null = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'src') -ChildPath 'codeunit')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'src') -ChildPath 'table')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'src') -ChildPath 'page')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'src') -ChildPath 'enum')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'src') -ChildPath 'tableextension')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'src') -ChildPath 'pageextension')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'src') -ChildPath 'report')
    $null = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'src') -ChildPath 'profile')

    Write-Host -Object '  Create app manifest ...'
    # Create app manifest
    switch ($appFolder) {
      'app' {
        Set-Content -Path (Join-Path -Path $appDirectory -ChildPath 'app.json') -Value (GetAppJson `
            -publisher $Publisher `
            -appName $AppName `
            -version $Version `
            -fromId $FromIdRange `
            -toId $ToIdRange)
      }
      'test' {
        Set-Content -Path (Join-Path -Path $appDirectory -ChildPath 'app.json') -Value (GetTestAppJson `
            -publisher $Publisher `
            -appName $AppName `
            -version $Version `
            -fromId $TestAppFromIdRange `
            -toId $TestAppToIdRange)
      }
    }
        
    Write-Host -Object '  Create AppSourceCop ...'
    # Create AppSourceCop
    Set-Content -Path (Join-Path -Path $appDirectory -ChildPath 'AppSourceCop.json') -Value (GetAppSourceCopJson `
        -supportedCountries $SupportedCountries `
        -mandatoryAffixes $MandatoryAffixes)
        
    Write-Host -Object '  Create Settings ...'
    # Create settings
    Set-Content -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath '.vscode') -ChildPath 'settings.json') -Value (GetSettingsJson)

    Write-Host -Object '  Create Extension recommendations ...'
    # Create Extension recommendations
    Set-Content -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath '.vscode') -ChildPath 'extensions.json') -Value (GetExtensionRecommendations)
    
    Write-Host -Object '  Create App Logo ...'
    # Create standard logo
    $bytes = [Convert]::FromBase64String((GetStandardLogo))
    [IO.File]::WriteAllBytes((Join-Path -Path (Join-Path -Path $appDirectory -ChildPath 'res') -ChildPath 'logo.png'), $bytes)

    Write-Host -Object '  Create ruleset ...'
    # Create ruleset
    Set-Content -Path (Join-Path -Path (Join-Path -Path $appDirectory -ChildPath '.codeanalyzer') -ChildPath "$Publisher.ruleset.json") -Value (GetRuleset)
  }

  Write-Host -Object 'Create .gitignore ...'
  # Create gitignore
  Set-Content -Path (Join-Path -Path (Join-Path -Path $Path -ChildPath $AppName) -ChildPath '.gitignore') -Value (GetGitIgnore)

  Write-Host -Object 'Create workspace ...'
  # Create workspace
  Set-Content -Path (Join-Path -Path (Join-Path -Path $Path -ChildPath $AppName) -ChildPath "$AppName.code-workspace") -Value (GetWorkspace)

  #Create yml scripts
  Write-Host -Object 'Create .azureDevOps'
  $azureDevOps = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $Path -ChildPath $AppName) -ChildPath ".azureDevOps")
  Set-Content -Path (Join-Path -Path $azureDevOps -ChildPath "CI.yml") -Value (GetCiYml)
  Set-Content -Path (Join-Path -Path $azureDevOps -ChildPath "Cloud.yml") -Value (GetCloudYml)
  Set-Content -Path (Join-Path -Path $azureDevOps -ChildPath "Current.yml") -Value (GetCurrentYml)
  Set-Content -Path (Join-Path -Path $azureDevOps -ChildPath "NextMajor.yml") -Value (GetNextMajorYml)
  Set-Content -Path (Join-Path -Path $azureDevOps -ChildPath "NextMinor.yml") -Value (GetNextMinorYml)
  
  #Create pipeline settings
  Write-Host -Object 'Create scripts'
  $scripts = New-Item -ItemType Directory -Path (Join-Path -Path (Join-Path -Path $Path -ChildPath $AppName) -ChildPath "scripts")
  Set-Content -Path (Join-Path -Path $scripts -ChildPath "Cleanup.ps1") -Value (GetCleanup)
  Set-Content -Path (Join-Path -Path $scripts -ChildPath "DevOps-Pipeline.ps1") -Value (GetDevOpsPipeline)
  Set-Content -Path (Join-Path -Path $scripts -ChildPath "Install-BcContainerHelper.ps1") -Value (GetBcContainerHelper)
  Set-Content -Path (Join-Path -Path $scripts -ChildPath "Read-Settings.ps1") -Value (GetReadSettings)
  Set-Content -Path (Join-Path -Path $scripts -ChildPath "settings.json") -Value (GetPipelineSettings)
}