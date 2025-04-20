# Azure SQL Maintenance Function App

This repository contains a PowerShell-based Azure Function App designed to perform essential maintenance tasks on Azure SQL databases. Since Azure SQL lacks a built-in SQL Agent, this application acts as a substitute to automate tasks like index maintenance and statistics updates, ensuring optimal database performance.

## Features

- Automated execution of index and statistics maintenance tasks.
- Serverless architecture leveraging Azure Functions.
- Configurable triggers (e.g., Timer, HTTP) for flexible scheduling.
- Secure integration with Azure SQL using managed identities or connection strings.
- Comprehensive logging and monitoring via Azure Application Insights.

## Prerequisites

- An active Azure subscription.
- Azure SQL Database instance.
- Azure Functions Core Tools (for local development).
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed.

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/your-repo/AzSQLMaintFunc.git
cd AzSQLMaintFunc
```

### 2. Install Dependencies
Ensure you have the required tools installed:
- PowerShell Core (for local testing and development).

### 3. Configure Environment Variables
Set the following environment variables before deploying the function app:

- `SQL_CONNECTION_STRING`: Connection string for your Azure SQL Database.
- `MAINTENANCE_TASKS`: Specify tasks to execute (e.g., `IndexRebuild`, `UpdateStatistics`).

Additionally, populate the following variables for deployment:

```bash
$SQL_Name = "<YourAzureSQLName>"
$SQL_RG = "<YourResourceGroupName>"
$TENANT_ID = "<YourAzureTenantID>"
$SUB_ID = "<YourAzureSubscriptionID>"
```

### 4. Deploy to Azure
Deploy the function app using the Azure CLI:
```bash
az functionapp create --resource-group <ResourceGroupName> --consumption-plan-location <Region> --runtime powershell --name <FunctionAppName> --storage-account <StorageAccountName>
```

### 5. Monitor and Test
- Use the Azure Portal or Application Insights to monitor function execution.
- Trigger the function manually or via the configured schedule.

## Contributing

Contributions are welcome! Feel free to submit a pull request or open an issue for any bugs or feature suggestions.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- [Azure Functions Documentation](https://learn.microsoft.com/en-us/azure/azure-functions/)
- [Azure SQL Database Documentation](https://learn.microsoft.com/en-us/azure/azure-sql/)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
