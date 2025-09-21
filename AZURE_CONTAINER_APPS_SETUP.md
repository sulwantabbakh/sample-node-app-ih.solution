# Azure Container Apps Deployment Setup

This document provides instructions for setting up the Azure Container Apps deployment workflow for the Node.js application.

## Overview

The workflow `azure-container-apps-deploy.yml` deploys the Node.js application to Azure Container Apps using Docker Hub as the container registry. It includes:

- **Build and Test**: Runs tests and SonarQube analysis
- **Docker Build**: Builds and pushes Docker images to Docker Hub
- **Deploy**: Deploys the containerized app to Azure Container Apps
- **Health Check**: Verifies the deployment is successful

## Required GitHub Secrets

### Docker Hub Secrets
Configure these secrets in your GitHub repository settings:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username | `yourusername` |
| `DOCKERHUB_TOKEN` | Docker Hub access token | `dckr_pat_xxxxxxxxxxxx` |

### Azure Secrets
Configure these secrets in your GitHub repository settings:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_CLIENT_ID` | Azure Service Principal Client ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_TENANT_ID` | Azure Tenant ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_CLIENT_SECRET` | Azure Service Principal Secret | `your-secret-value` |
| `AZURE_RESOURCE_GROUP` | Target Azure Resource Group | `my-resource-group` |
| `AZURE_LOCATION` | Azure region (optional, defaults to eastus) | `eastus` |

### Log Analytics Secrets (Optional)
For Container Apps Environment logging:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AZURE_LOG_ANALYTICS_WORKSPACE_ID` | Log Analytics Workspace ID | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| `AZURE_LOG_ANALYTICS_WORKSPACE_KEY` | Log Analytics Workspace Key | `your-workspace-key` |

### SonarQube Secrets (Optional)
For code quality analysis:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `SONAR_HOST_URL` | SonarQube server URL | `https://sonarcloud.io` |
| `SONAR_TOKEN` | SonarQube authentication token | `your-sonar-token` |

## Prerequisites

### 1. Docker Hub Setup
1. Create a Docker Hub account at [hub.docker.com](https://hub.docker.com)
2. Create a repository named `sample-node-app-ih` (or update the workflow to use your preferred name)
3. Generate an access token:
   - Go to Account Settings → Security
   - Click "New Access Token"
   - Give it a name and select "Read, Write, Delete" permissions
   - Copy the token and add it as `DOCKERHUB_TOKEN` secret

### 2. Azure Setup
1. **Create a Resource Group**:
   ```bash
   az group create --name my-resource-group --location eastus
   ```

2. **Create a Service Principal**:
   ```bash
   az ad sp create-for-rbac --name "github-actions-sp" \
     --role contributor \
     --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group-name} \
     --sdk-auth
   ```

3. **Create Log Analytics Workspace** (optional):
   ```bash
   az monitor log-analytics workspace create \
     --resource-group my-resource-group \
     --workspace-name my-log-analytics-workspace \
     --location eastus
   ```

### 3. GitHub Environment Setup
1. Go to your repository → Settings → Environments
2. Create environments: `dev`, `staging`, `prod`
3. Add the required secrets to each environment
4. Configure protection rules as needed (e.g., require reviewers for prod)

## Workflow Features

### Environment Support
The workflow supports multiple environments:
- **dev**: Development environment
- **staging**: Staging environment  
- **prod**: Production environment

### Docker Image Tagging
Images are tagged with:
- `latest`: For main branch deployments
- `{branch-name}`: For branch-specific deployments
- `{branch-name}-{commit-sha}`: For specific commits
- `{environment}-{timestamp}`: For environment-specific deployments

### Container App Configuration
- **CPU**: 0.5 cores
- **Memory**: 1.0 GiB
- **Min Replicas**: 1
- **Max Replicas**: 3
- **Ingress**: External (publicly accessible)
- **Port**: 3000

### Environment Variables
The following environment variables are automatically set:
- `NODE_ENV`: Set to the deployment environment
- `PORT`: Set to 3000
- `APP_VERSION`: Set to the Git commit SHA
- `DEPLOYMENT_DATE`: Set to the deployment timestamp

## Usage

### Manual Deployment
1. Go to Actions tab in your GitHub repository
2. Select "Deploy Node App to Azure Container Apps"
3. Click "Run workflow"
4. Choose the target environment (dev/staging/prod)
5. Click "Run workflow"

### Automatic Deployment
The workflow can be triggered by:
- Manual workflow dispatch
- Push to specific branches (modify the `on` section as needed)
- Pull request events (modify the `on` section as needed)

## Monitoring and Troubleshooting

### View Logs
1. **GitHub Actions**: Check the Actions tab for workflow execution logs
2. **Azure Container Apps**: Use Azure Portal or CLI to view application logs
3. **Container Logs**: 
   ```bash
   az containerapp logs show --name sample-node-app-ih-dev --resource-group my-resource-group
   ```

### Common Issues

1. **Docker Hub Authentication Failed**:
   - Verify `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets
   - Ensure the token has proper permissions

2. **Azure Authentication Failed**:
   - Verify all Azure secrets are correctly set
   - Check Service Principal permissions

3. **Container App Creation Failed**:
   - Ensure the resource group exists
   - Check Azure subscription limits
   - Verify the location is supported

4. **Health Check Failed**:
   - Check if the application is listening on port 3000
   - Verify the Dockerfile exposes the correct port
   - Check application logs for startup errors

## Customization

### Modify Container Resources
Update the deployment step in the workflow:
```yaml
--cpu 1.0 \
--memory 2.0Gi \
--min-replicas 2 \
--max-replicas 5
```

### Add Custom Environment Variables
Add to the `--set-env-vars` section:
```yaml
--set-env-vars \
  NODE_ENV="${{ env.ENVIRONMENT_SUFFIX }}" \
  PORT=3000 \
  CUSTOM_VAR=value
```

### Change Docker Registry
Update the environment variables at the top of the workflow:
```yaml
env:
  DOCKER_REGISTRY: your-registry.com
  DOCKER_IMAGE_NAME: your-registry.com/your-username/your-app
```

## Security Considerations

1. **Secrets Management**: Never commit secrets to the repository
2. **Service Principal**: Use least privilege principle for Azure permissions
3. **Docker Images**: Regularly update base images for security patches
4. **Network Security**: Consider using private endpoints for production
5. **Environment Protection**: Use GitHub environment protection rules for production

## Cost Optimization

1. **Resource Sizing**: Start with minimal resources and scale as needed
2. **Auto-scaling**: Configure appropriate min/max replicas
3. **Environment Cleanup**: Regularly clean up unused environments
4. **Monitoring**: Set up cost alerts in Azure

## Support

For issues or questions:
1. Check the GitHub Actions logs
2. Review Azure Container Apps logs
3. Consult Azure Container Apps documentation
4. Check the workflow file for configuration issues
