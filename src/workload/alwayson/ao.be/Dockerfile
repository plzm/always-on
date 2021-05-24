FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app

COPY ["/src/workload/alwayson/ao.be/*.*", "ao.be/"]
COPY ["/src/workload/alwayson/ao.common/*.*", "ao.common/"]

RUN dotnet restore "ao.be/ao.be.csproj"

RUN dotnet build "ao.be.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ao.be.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/runtime:5.0 AS base
WORKDIR /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ao.be.dll"]