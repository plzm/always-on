#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["ao.fe/ao.fe.csproj", "ao.fe/"]
RUN dotnet restore "ao.fe/ao.fe.csproj"
COPY . .
WORKDIR "/src/ao.fe"
RUN dotnet build "ao.fe.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ao.fe.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ao.fe.dll"]