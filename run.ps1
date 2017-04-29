param(
	[bool]$privateStore = $false 
)

Write-Host "Cleaning old artifacts..."
rd .\bin -Recurse
rd .\obj -Recurse
Write-Host

Write-Host "CLI version: "
dotnet --version
Write-Host

Write-Host "Restoring packages...`n"
dotnet restore
Write-Host

Write-Host "Creating store...`n"
if ($privateStore) {
    dotnet store --manifest app.csproj -c release -r win7-x64 -o .\mystore
}
else {
    dotnet store --manifest app.csproj -c release -r win7-x64
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
dotnet "$publishFolder\app.dll"
Write-Host

