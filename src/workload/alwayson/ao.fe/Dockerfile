# Context is sln directory, NOT proj directory, due to local (project) references
# docker build -f ao.fe/Dockerfile -t ao.fe:latest -t ao.fe:1.0 .

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app

COPY . ./
RUN dotnet publish "ao.fe/ao.fe.csproj" -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS run
WORKDIR /app
EXPOSE 80

COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "ao.fe.dll"]
