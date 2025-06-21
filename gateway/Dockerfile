FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 7000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore "./gateway.csproj"
RUN dotnet publish "./gateway.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
COPY ocelot.json .
COPY appsettings.json .
COPY NLog.config .
ENTRYPOINT ["dotnet", "gateway.dll"]