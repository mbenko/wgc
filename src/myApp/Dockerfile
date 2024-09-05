## Basic Dockerfile
## 
## docker build -f ./src/myApp/Dockerfile -t myapp:v0.1 ./src/myApp --build-arg tag=v0.1
## docker run -d -p 8100:5100 --name myweb myapp:v0.1
## browse to http://localhost:8100

FROM mcr.microsoft.com/dotnet/sdk:8.0 as build
WORKDIR /src
COPY myApp.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0 as publish
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:5100
ENV EnvName=Docker
COPY --from=build /app .
ENTRYPOINT ["dotnet","myApp.dll"]