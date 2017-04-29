param(
	[bool]$privateStore = $false 
)

$storeWorkingDir=".\store-workingdir"
Write-Host "Cleaning old artifacts..."
Remove-Item .\bin -Recurse -ErrorAction Ignore
Remove-Item .\obj -Recurse -ErrorAction Ignore
Remove-Item $storeWorkingDir -Recurse -ErrorAction Ignore
Write-Host

Write-Host "CLI version: "
dotnet --version
Write-Host

Write-Host "Restoring packages...`n"
dotnet restore
Write-Host

Write-Host "Creating store...`n"
$createStoreCmd="dotnet store --manifest appusingstore.csproj -c release -r win7-x64 -w $storeWorkingDir --preserve-working-dir"
if ($privateStore) {
    Invoke-Expression "$createStoreCmd -o .\mystore"
}
else {
    Invoke-Expression $createStoreCmd
}
Write-Host

Write-Host "Publishing packages...`n"
if ($privateStore) {
    dotnet publish -c release --manifest .\mystore\netcoreapp2.0\artifact.xml
}
else {
    dotnet publish -c release --manifest $env:USERPROFILE\.dotnet\x64\store\netcoreapp2.0\artifact.xml
}
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

