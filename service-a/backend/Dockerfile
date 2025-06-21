# Stage 1: Build Angular frontend
FROM node:18-alpine AS frontend-build
WORKDIR /app/frontend
COPY ../frontend/package*.json ./
RUN npm install
COPY ../frontend/ ./
RUN npm run build -- --configuration production

# Stage 2: Build .NET backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS backend-build
WORKDIR /app
COPY ./*.csproj ./backend/
RUN dotnet restore ./backend/
COPY ./. ./backend/
WORKDIR /app/backend
RUN dotnet publish -c Release -o /app/publish

# Stage 3: Combine frontend and backend
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=backend-build /app/publish ./
COPY --from=frontend-build /app/frontend/dist/ ./ClientApp/
COPY ./keys/ ./keys/
ENV ASPNETCORE_URLS=http://+:80
EXPOSE 80
ENTRYPOINT ["dotnet", "ServiceA.dll"]
