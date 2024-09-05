## Basic Dockerfile
## 
## docker build -f ./src/myApi/Dockerfile -t myapi:v0.1 ./src/myApi --build-arg tag=v0.1
## docker run -d -p 8100:5200 --name myapi myapi:v0.1
## browse to http://localhost:8100

FROM mcr.microsoft.com/dotnet/sdk:8.0 as build
WORKDIR /src
COPY myApi.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0 as publish
WORKDIR /app
# ENV ASPNETCORE_URLS=http://+:5200
# ENV EnvName=Docker
COPY --from=build /app .
ENTRYPOINT ["dotnet","myApi.dll"]