Write-Host "Cleaning old artifacts... "
rd .\bin -Recurse
rd .\obj -Recurse
Write-Host

Write-Host "CLI version: "
dotnet --version
Write-Host

Write-Host "Restoring packages... "
dotnet restore
Write-Host

Write-Host "Creating store... "
dotnet store --manifest app.csproj -c release -r win7-x64
Write-Host

Write-Host "Publishing packages... "
dotnet publish -c release --manifest $env:USERPROFILE\.dotnet\x64\store\netcoreapp2.0\artifact.xml
Write-Host

Write-Host "Running app... "
dotnet bin\release\netcoreapp2.0\app.dll
Write-Host

