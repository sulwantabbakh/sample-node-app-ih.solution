name: Trigger auto deployment for frontendapp

# When this action will be executed
on:
  # Allow manual trigger 
  workflow_dispatch:
      
jobs:
  build-test-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22.x
          cache: 'npm'
          cache-dependency-path: 'package-lock.json'

      - name: Install dependencies
        run: npm ci

      - name: Build the application (optional)
        run: |
          npm run build 2>/dev/null || echo "No build script found, skipping build step"

      - name: Run unit tests with coverage and JUnit reports
        env:
          JEST_JUNIT_OUTPUT: coverage/junit.xml
        run: npm run test:ci

      - name: Publish test results to Checks
        uses: dorny/test-reporter@v1
        if: always()
        with:
          name: Jest Test Results
          path: coverage/junit.xml
          reporter: jest-junit
          fail-on-error: true

      - name: Upload test results to GitHub
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results-node
          path: coverage/
          retention-days: 30

      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          client-secret: ${{ secrets.AZURE_CLIENT_SECRET }}

      - name: Build and push container image to registry
        uses: azure/container-apps-deploy-action@v2
        with:
          appSourcePath: ${{ github.workspace }}
          _dockerfilePathKey_: _dockerfilePath_
          _targetLabelKey_: _targetLabel_
          registryUrl: docker.io
          registryUsername: ${{ secrets.DOCKERHUB_USERNAME }}
          registryPassword: ${{ secrets.DOCKERHUB_TOKEN }}
          containerAppName: frontendapp
          resourceGroup: container-labs-rg
          imageToBuild: saurabhd2106/frontendapp-node:${{ github.sha }}