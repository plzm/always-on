#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:5.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["/src/workload/alwayson/ao.be/ao.be.csproj", "ao.be/"]
COPY ["/src/workload/alwayson/ao.common/ao.common.csproj", "ao.common/"]
RUN dotnet restore "ao.be/ao.be.csproj"
COPY . .
WORKDIR "/src/ao.be"
RUN dotnet build "ao.be.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ao.be.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ao.be.dll"]