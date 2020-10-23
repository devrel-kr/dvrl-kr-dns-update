FROM mcr.microsoft.com/azure-powershell:latest

ADD entrypoint.ps1 /entrypoint.ps1
RUN chmod +x /entrypoint.ps1

ENTRYPOINT ["pwsh", "-File", "/entrypoint.ps1"]
