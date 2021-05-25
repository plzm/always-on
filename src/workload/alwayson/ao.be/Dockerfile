# Context is sln directory, NOT proj directory, due to local (project) references
# docker build -f ao.be/Dockerfile -t ao.be:latest -t ao.be:1.0 .

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app

COPY . ./
RUN dotnet publish "ao.be/ao.be.csproj" -c Release -o out

FROM mcr.microsoft.com/dotnet/runtime:5.0 AS run
WORKDIR /app

COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "ao.be.dll"]