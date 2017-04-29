param(
	[bool]$privateStore = $false 
)
Write-Host $PSScriptRoot

Write-Host "`nCleaning old artifacts..."
Remove-Item .\bin, .\obj, .\store-workingdir, .\mystore -Recurse -ErrorAction Ignore
Write-Host

Write-Host "CLI version: "
dotnet --version
Write-Host

Write-Host "Restoring packages...`n"
dotnet restore
Write-Host

Write-Host "Creating store...`n"
$createStoreCmd="dotnet store --manifest appusingstore.csproj -c release -r win7-x64 -w .\store-workingdir --preserve-working-dir"
if ($privateStore) {
    Invoke-Expression "$createStoreCmd -o .\mystore"
    $env:DOTNET_SHARED_STORE="$PSScriptRoot\mystore"
}
else {
    Invoke-Expression $createStoreCmd
}
Write-Host

Write-Host "Publishing packages...`n"
if ($privateStore) {
    $manifestXml=".\mystore\x64\netcoreapp2.0\artifact.xml"
}
else {
    $manifestXml="$env:USERPROFILE\.dotnet\x64\store\netcoreapp2.0\artifact.xml"
}
dotnet publish -c release --manifest $manifestXml
Write-Host

$publishFolder="bin\release\netcoreapp2.0\publish\"
Write-Host "Verifying ASP.NET Core dlls are NOT in published folder... "
if([System.IO.File]::Exists("$publishFolder\Microsoft.AspNetCore.Mvc.Core.dll")){
   throw "ASP.NET Core dlls are present in the published folder. This is not expected." 
}
Write-Host

Write-Host "Running app...`n"
dotnet "$publishFolder\appusingstore.dll"
Write-Host

