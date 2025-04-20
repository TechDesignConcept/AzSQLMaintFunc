<#
IndexOptimize is the SQL Server Maintenance Solution’s stored procedure for rebuilding and reorganising indexes and updating statistics. 
IndexOptimize is supported on SQL Server 2008, SQL Server 2008 R2, SQL Server 2012, SQL Server 2014, SQL Server 2016, SQL Server 2017, 
SQL Server 2019, SQL Server 2022, Azure SQL Database, and Azure SQL Managed Instance.

REF: https://github.com/yochananrachamim/AzureSQL 

This function app assumes the managed identity of the function app and has 'db_owner' permissions over the databases.
Permissions: VIEW SERVER STATE, db_owner on all target databases
#>

# Input bindings are passed in via param block.
param($Timer)

# Variables to populate
$SQL_Name = ""
$SQL_RG = ""
$TENANT_ID = ""
$SUB_ID = ""

# Write an information log with the current time.
$GetDate = Get-Date
$CurrentTime = "Time: $GetDate"
Write-Information "$CurrentTime"

# Initialise Database Queries
$Maintenance_Query = Get-Content AzureSQLMaintenance.sql

# SQL Properties
$SQL_LongName = "tcp:$SQL_Name.database.windows.net,1433"

# Ensures you do not inherit an AzContext in your runbook
$AzureContext = Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# Set and store context
$AzureContext = Set-AzContext -Subscription $SUB_ID -Tenant $TENANT_ID
$UserId = $AzureContext.Account.Id
Write-Information $AzureContext
Write-Information "Identity: $UserId"

# Get database names
# Development
# $DatabaseAll = (Get-AzSqlDatabase -ResourceGroupName $SQL_RG -ServerName $SQL_Name | Where-Object{$_.DatabaseName -like "*uniqueDB*"}).DatabaseName
# Production
$DatabaseAll = (Get-AzSqlDatabase -ResourceGroupName $SQL_RG -ServerName $SQL_Name | Where-Object{$_.DatabaseName -ne "master"}).DatabaseName
Write-Information "Databases: `n`
$DatabaseAll"

# Iterate through databases for maintenance 
foreach($Database in $DatabaseAll){
    $global:message = ""

    # Create SQL connection
    $connectionString = "Server=$SQL_LongName;Initial Catalog=$Database;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;" 
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString) 
    $connection.AccessToken = (Get-AzAccessToken -AsSecureString -ResourceUrl https://database.windows.net).Token
    $handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {param($sender, $event) $global:message += "`n" + $event.Message }
    $connection.add_InfoMessage($handler)
    $connection.FireInfoMessageEventOnUserErrors = $true
    $connection.Open()

    # Excute command (database maintenance stored proc)
    Write-Information $Database
    $command = New-Object -Type System.Data.SqlClient.SqlCommand($Maintenance_Query, $connection)
    $command.CommandTimeout = 7200
    $command.ExecuteNonQuery()
    
    # Output information
    Write-Information $global:message

    # Close SQL connection
    $connection.Close()
}

