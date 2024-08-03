# Naming Conventions

[Home](wgc.md) | [Naming](wgc-taming.md) | [Tagging](wgc-tagging.md) 

Except Resource Groups which will have rg- prepended to the name the services provisioned in azure will follow the pattern of `<project>-<environment>-<serviceType>`.

Naming standards for Azure resources will follow kebab case including the following conventions:

- **Resource Group**: `rg-<project>-<environment>`
- **Storage Account**: `<project><environment>sa`
- **App Service Plan**: `<project>-<environment>-asp`
- **App Service**: `<project>-<environment>-web`
- **Web API**: `<project>-<environment>-api`
- **Key Vault**: `<project>-<environment>-kv`
- **Container Registry**: `<project>-<environment>-acr`
- **Azure Kubernetes Service**: `<project>-<environment>-aks`
- **Azure Container Apps**: `<project>-<environment>-aca`
- **Azure Container Apps Plan**: `<project>-<environment>-acp`

## Example

Our project called `myapp` has two environments, `poc` and `demo`. The naming conventions for the services in Azure would be as follows:

| Service | poc | demo |
|---------|-----|------|
| Resource Group | rg-myapp-poc | rg-myapp-demo |
| Storage Account | myapppocsa | myappdemosa |
| App Service Plan | myapp-poc-asp | myapp-demo-asp |
| App Service | myapp-poc-web | myapp-demo-web |
| Web API | myapp-poc-api | myapp-demo-api |
| Key Vault | myapp-poc-kv | myapp-demo-kv |
| Container Registry | myapp-poc-acr | myapp-demo-acr |
| Azure Kubernetes Service | myapp-poc-aks | myapp-demo-aks |
| Azure Container Apps | myapp-poc-aca | myapp-demo-aca |
| Azure Container Apps Plan | myapp-poc-acp | myapp-demo-acp |


## Standard Styles

The following are definitions and examples of casing styles:

- cost-of-goods-sold (kebab case): all words lowercase and separated by hyphens
- costOfGoodsSold (camel case): capitalize the first letter of all words, except for leading word
- CostOfGoodsSold (Pascal case): capitalize the first letter of all words
- decimalCostOfGoodsSold (Hungarian notation): all words uppercase and prefixed with lowercase data type
- cost_of_goods_sold (snake case): all words lowercase and separated by underscores
- COST_OF_GOODS_SOLD (SCREAMING SNAKE CASE): all words uppercase and separated by underscores
