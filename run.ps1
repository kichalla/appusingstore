param(
	[bool]$privateStore = $false 
)
Write-Host $PSScriptRoot

$store=[io.path]::combine($env:TEMP, "appusingstore-store")
$storeWorkingDir=[io.path]::combine($env:TEMP, "appusingstore-storeworkingdir")
Write-Host "`nCleaning old artifacts..."
Remove-Item .\bin, .\obj, $store, $storeWorkingDir -Recurse -ErrorAction Ignore
Write-Host

Write-Host "CLI version: "
dotnet --version
Write-Host

Write-Host "Restoring packages...`n"
dotnet restore
Write-Host

if ($LASTEXITCODE -ne 0){
    exit $LASTEXITCODE
}

Write-Host "Creating store...`n"
$createStoreCmd="dotnet store --manifest appusingstore.csproj -c release -r win7-x64 -w $storeWorkingDir --preserve-working-dir"
if ($privateStore) {
    Invoke-Expression "$createStoreCmd -o $store"
    $env:DOTNET_SHARED_STORE=$store
}
else {
    Invoke-Expression $createStoreCmd
}
Write-Host

if ($LASTEXITCODE -ne 0){
    exit $LASTEXITCODE
}

Write-Host "Publishing packages...`n"
if ($privateStore) {
    $manifestXml="$store\x64\netcoreapp2.0\artifact.xml"
}
else {
    $manifestXml="$env:USERPROFILE\.dotnet\x64\store\netcoreapp2.0\artifact.xml"
}
dotnet publish -c release --manifest $manifestXml
Write-Host

if ($LASTEXITCODE -ne 0){
    exit $LASTEXITCODE
}

$publishFolder="bin\release\netcoreapp2.0\publish\"
Write-Host "Verifying ASP.NET Core dlls are NOT in published folder... "
if([System.IO.File]::Exists("$publishFolder\Microsoft.AspNetCore.Mvc.Core.dll")){
   throw "ASP.NET Core dlls are present in the published folder. This is not expected." 
}
Write-Host

Write-Host "Running app...`n"
dotnet "$publishFolder\appusingstore.dll"
Write-Host

