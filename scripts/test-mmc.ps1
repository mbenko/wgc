# Test CCO

az account clear
az config set core.enable_broker_on_windows=false
az login

## Demos
#    1. Run the app with Tye (no dockerfile)
#    2. Add a Dockerfile to the app and run it locally
#    3. Docker compose the app and run it locally
#    4. Push to ACR manually
#    5. Build with ACR & Tag
#    6. Run from ACR in App Services for Containers
#    7. Run from ACR in Azure Container Apps
#    8. Run from ACR in AKS

## Demos vNext
#   1. Add API and call it, run from VSCode
#   2. Run via Tye
#   3. az webapp up
#   4. Docker
#   5. azd init and up
#   6. Aspire sample
#   7. Aspirate Me


## Event Specific things
$evtName = "tcdnug"
$appName = "$evtName-Web"
$apiName = "$evtName-Api"
$rg = "rg-$evtName-demos"
$env = "poc"

## CD to webapp folder
cd src/myApp
az webapp up -g $rg --name $appName --sku F1 --launch-browser -p $evtName-plan
cd ../..

# pull starter code into event folder

# Add API
dotnet new webapi -o .code\myApi
dotnet sln add .code\myApi

## Add Code to connect the two
cd src/myApi
az webapp up -g $rg --name $apiName --sku F1 --launch-browser -p $evtName-plan
az webapp config appsettings set --name $appName --resource-group $rg --settings apiUrl=https://$apiName.azurewebsites.net/weatherforecast EnvName=
cd ../..

azd

# Project Tye : https://github.com/dotnet/tye/blob/main/docs/README.md

dotnet tool update -g Microsoft.Tye --version "0.11.0-alpha.22111.1"

tye run
tye build
tye push -i
tye deploy -i

# Basic Dockerfile
cd .\code\$apiName
dotnet build --configuration release
dotnet publish -c release -o dist
cd .\dist
dotnet myApp.dll


# add docker file to ./myApp folder
## docker build -f ./src/myApp/Dockerfile -t myapp:v0.1 ./src/myApp --build-arg tag=v0.1
## docker run -d -p 8100:5200 --name myweb myapp:v0.1
## browse to http://localhost:8100

cd .\code\$appName\ # so we're in .\myApp
$imgName = "$evtName"+"web:simple"
docker build -t "$appName:simple" -f ./code/$appName/Dockerfile.simple ./code/$appName
docker image list $appName:simple
docker run -p 5001:80 -d $appName:simple
# http://localhost:5001
docker container list
docker container stop 6eee
docker container rm 6eee


# Dockerbuild
docker build -f ./src/myApp/Dockerfile -t $appName.ToLower() ./src/myApp --build-arg EnvName=dockerbuild
docker build -f ./src/myApi/Dockerfile -t $apiName.ToLower() ./src/myApi --build-arg tag=v1
docker image list $appName.tolower()
docker run -p 5003:80 -d  $appName.tolower()
# http://localhost:5003


# add docker-compose to ./ folder
docker-compose build
docker-compose up -d
docker-compose down 
# http://localhost:5100

## Shared Infrastructure - KeyVault, ACR, AKS, etc
$rgShared = "rg-shared-cus"
$loc = "cus"
$aksName = "bnk-aks-$loc"
$acrName = "bnkacrcus"

az acr create -n $acrName -g $rgShared --sku Standard

az acr login -n $acrName

# Docker build on ACR & push image
$appName = "myapp"
$apiName = "myapi"
$label = "v905"
$appImg = "$acrName.azurecr.io/"+"$appName"+":$label"
$apiImg = "$acrName.azurecr.io/"+"$apiName"+":$label"

az acr build --image $appImg --registry $acrName -f ./src/$appName/Dockerfile ./src/$appName --build-arg tag=$label
az acr build --image $apiImg --registry $acrName -f ./src/$apiName/Dockerfile ./src/$apiName --build-arg tag=$label
az acr image list -o table


# Create an AKS cluster with ACR integration
az aks create -n $aksName -g $rgShared --node-resource-group "rg-$aksName-nodes" `
    --generate-ssh-keys --attach-acr $acrName --node-vm-size "standard_d2as_v5" `
    --enable-aad --enable-azure-rbac --enable-keda

# attach ACR to AKS
az aks update -n $aksName -g $rgShared --attach-acr $acrName

# using bnk.azurecr.io
$acrName = "$acrName.azurecr.io"
az acr login -n $acrName

# Docker build on ACR & push image
az acr build --image "$acrName.azurecr.io/$appName:v2" --registry $acrName -f ./code/$appName/Dockerfile ./code/$appName --build-arg tag=v2
az acr build --image "$acrName.azurecr.io/$apiName:v2" --registry $acrName -f ./code/$apiName/Dockerfile ./code/$apiName --build-arg tag=v2
az acr repository list -n $acrName -o table

# Azure Container Apps
az containerapp up -n $appName-aca -g $rg --environment $env --image bnk23acr.azurecr.io/$appName:v2 --ingress external
az containerapp up -n kcdcapi-aca -g $rg --environment $env --image bnk23acr.azurecr.io/kcdcapi:v2
az containerapp list -o table
az containerapp update -n bnk-aca-myapp -g $rg --set-env-vars "EnvName=kcdc"


$label = "v905"

# Kubernetes
az aks get-credentials -n $aksName -g $rgShared
kubectl cluster-info

# Run some pods
kubectl run myapp-pod --image  $acrName.azurecr.io/${appName} --env="EnvName=K8S"

kubectl exec -ti myapp-pod -- bash
kubectl port-forward myapp-pod 8080:80
kubectl get all
kubectl logs myapp-pod
kubectl delete pod myapp-pod

kubectl get all -A

# Deploy the VSL app
kubectl create namespace kcdc23
kubectl apply -n kcdc23 -f k8s-kcdc.yml 
kubectl apply -n kcdc23 -f k8s  # deploy folder


## Test in AKS
$env = "dev"
$appName = "bnk-web"
$apiName = "bnk-api"
$acrName = "pocncusacr01"
$aksRg = "$env-shared-aks-rg"
$label = "v4"
$aksName = "$env-ncus-shared-aks-01"
$aksName = "$env-scus-shared-aks-02"

# az acr build --image ocncusacr01.azurecr.io/bnk_web --registry pocncusacr01 -f ./code/bnkWeb/Dockerfile ./code/bnkWeb --build-arg tag=v4
# az acr build --image ${acrname}.azurecr.io/${appName} --registry $acrname -f ./code/bnkApi/Dockerfile ./code/bnkApi --build-arg tag=$label
az acr login -n $acrName
az acr build --image "$acrName.azurecr.io/${appName}:$label" --registry $acrname -f ./code/bnkApi/Dockerfile ./code/bnkApi --build-arg tag=$label
az acr build --image "$acrName.azurecr.io/${apiName}:$label" --registry $acrname -f ./code/bnkApi/Dockerfile ./code/bnkApi --build-arg tag=$label

# List all ACR Repos with tags and versions
az acr repository list -n $acrName --output table
az acr repository show-tags -n $acrName --repository $appName --output table
az acr repository show-tags -n $acrName --repository $apiName --output table

# Tokenize the k8s.yaml file and write to env specific file
(Get-Content k8s.yaml) |
ForEach-Object {
    $_ -replace '#{APP_NAME}#', $AppName -replace '#{API_NAME}#', $ApiName -replace '#{ACR_NAME}#', $AcrName -replace '#{AKS_NAME}#', $AksName -replace '#{IMAGE_LABEL}#', $label
} |
Set-Content k8s-$aksName.yaml


# IF Needed create the aks infrastructure, an AKS cluster and attach the ACR to the AKS cluster
az group create -n $aksrg --location northcentralus
az acr create -n $acrName -g $rg --sku Standard
az acr login -n $acrName
az aks create -n $aksName -g $aksrg --generate-ssh-keys --attach-acr $acrName --node-vm-size "standard_d2as_v5"

# Create a test AKS cluster with ACR integration
az aks get-credentials --resource-group $aksrg --name $aksName
az aks update -n $aksName -g $aksrg --attach-acr $acrName

$ns = "bnk-dev"
kubectl create namespace $ns
kubectl apply -n $ns -f k8s-$aksName.yaml
kubectl get all -n $ns

azd init