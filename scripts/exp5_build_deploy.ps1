Param(
  [string]$TomcatHome
)

$ErrorActionPreference = 'Stop'

# Resolve repo root and module paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Resolve-Path (Join-Path $ScriptDir '..')
$Exp5 = Join-Path $Root 'EXPERIMENT 5'
$Webapp = Join-Path $Exp5 'src/main/webapp'
$Classes = Join-Path $Webapp 'WEB-INF/classes'

Write-Host "[exp5] Root: $Root"
Write-Host "[exp5] Module: $Exp5"

# Resolve Tomcat home
if (-not $TomcatHome) {
  if ($env:TOMCAT_HOME -and (Test-Path $env:TOMCAT_HOME)) { $TomcatHome = $env:TOMCAT_HOME }
  elseif ($env:CATALINA_HOME -and (Test-Path $env:CATALINA_HOME)) { $TomcatHome = $env:CATALINA_HOME }
  else { throw "Set -TomcatHome or CATALINA_HOME/TOMCAT_HOME environment variable." }
}

Write-Host "[exp5] Tomcat: $TomcatHome"

# Locate servlet API jar
$servletJar = Join-Path $TomcatHome 'lib/servlet-api.jar'
if (-not (Test-Path $servletJar)) {
  $servletJar = Join-Path $TomcatHome 'lib/jakarta.servlet-api.jar'
}
if (-not (Test-Path $servletJar)) { throw "Could not find servlet-api jar in $TomcatHome/lib" }
Write-Host "[exp5] Using servlet API: $servletJar"

# Ensure classes dir exists
New-Item -ItemType Directory -Force -Path $Classes | Out-Null

$mysqlJar = Join-Path $Webapp 'WEB-INF/lib/mysql-connector-j-8.3.0.jar'
if (-not (Test-Path $mysqlJar)) { throw "Missing MySQL driver: $mysqlJar" }

Write-Host "[exp5] Compiling sources..."

# Collect sources
$sources = Get-ChildItem -Path (Join-Path $Exp5 'src/main/java') -Recurse -Filter *.java | ForEach-Object { $_.FullName }
if (-not $sources) { throw "No Java sources found." }

# Run javac (Windows uses ';' separator for classpath)
$cp = "$servletJar;$mysqlJar"
& javac -cp $cp -d $Classes @sources

Write-Host "[exp5] Compile OK"

# Deploy
$target = Join-Path $TomcatHome 'webapps/exp5'
Write-Host "[exp5] Deploying to $target ..."
if (Test-Path $target) { Remove-Item -Recurse -Force $target }
New-Item -ItemType Directory -Force -Path $target | Out-Null

Copy-Item -Recurse -Force (Join-Path $Webapp '*') $target

Write-Host "[exp5] Deployed. Visit: http://localhost:8080/exp5/Insert.jsp and /Search.jsp"
