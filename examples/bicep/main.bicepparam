// Example Bicep parameters file
// Use this to set parameter values for your Bicep deployment

using './main.bicep'

param projectName = 'myproject'
param environment = 'dev'
param location = 'East US'
param commonTags = {
  Environment: 'dev'
  Project: 'myproject'
  Owner: 'team@company.com'
  CostCenter: 'engineering'
  ManagedBy: 'bicep'
}
