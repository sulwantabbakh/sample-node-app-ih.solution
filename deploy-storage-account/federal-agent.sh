name: Deploy Node App on Azure VM (OIDC + VM Managed Identity)

on:
  workflow_dispatch:

permissions:
  id-token: write
  contents: read
  actions: read
  checks: write
  pull-requests: write

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    environment: dev

    steps:
      - name: Checkout code
        uses: actions/checkout@v5
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4.4.0
        with:
          node-version: 22.x
          cache: npm
          cache-dependency-path: package-lock.json

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
        uses: dorny/test-reporter@v2.1.1
        if: always()
        with:
          name: Jest Test Results
          path: coverage/junit.xml
          reporter: jest-junit
          fail-on-error: true

      - name: Upload test results to GitHub
        uses: actions/upload-artifact@v4.6.2
        if: always()
        with:
          name: test-results-node
          path: coverage/
          retention-days: 30

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v6.0.0
        env:
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
          args: >
            -Dsonar.projectKey=sample-node-app-saurabh
            -Dsonar.organization=sda
            -Dsonar.token=${{ secrets.SONAR_TOKEN }}
            -Dsonar.host.url=${{ secrets.SONAR_HOST_URL }}
            -Dsonar.sources=.
            -Dsonar.exclusions=node_modules/**,coverage/**,tests/**,**/*.test.js,**/*.spec.js
            -Dsonar.tests=tests/
            -Dsonar.test.inclusions=**/*.test.js,**/*.spec.js
            -Dsonar.coverage.exclusions=node_modules/**,coverage/**,tests/**,**/*.test.js,**/*.spec.js

      - name: Create deployment package
        run: |
          set -euo pipefail
          STAGING="$GITHUB_WORKSPACE/deployment-package"
          rm -rf "$STAGING"
          mkdir -p "$STAGING"

          [ -d public ] && cp -r public "$STAGING/" || echo "No public/ directory found"
          [ -d node_modules ] && cp -r node_modules "$STAGING/" || echo "No node_modules/ directory found"
          [ -f server.js ] && cp server.js "$STAGING/" || echo "No server.js found"
          cp package.json "$STAGING/"
          cp package-lock.json "$STAGING/"
          [ -f README.md ] && cp README.md "$STAGING/" || true
          [ -f Dockerfile ] && cp Dockerfile "$STAGING/" || echo "No Dockerfile found"

          (cd "$STAGING" && npm pkg delete devDependencies || true)

          TS="$(date +%Y%m%d-%H%M%S)"
          SHORT_SHA="${GITHUB_SHA::7}"
          ZIP_NAME="deployment-package-${SHORT_SHA}-${TS}.zip"
          (cd "$GITHUB_WORKSPACE" && zip -r "$ZIP_NAME" "deployment-package")
          echo "ZIP_NAME=$ZIP_NAME" >> "$GITHUB_ENV"

      - name: Upload deployment package artifact
        uses: actions/upload-artifact@v4.6.2
        with:
          name: deployment-package-node-${{ github.run_number }}
          path: ${{ env.ZIP_NAME }}
          retention-days: 90

      # --- Azure login via OIDC (for Storage upload + VM run-command RBAC) ---
      - name: Azure login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      # --- Upload to Blob with AAD (no keys, no SAS) ---
      - name: Upload package to Blob (AAD, no keys)
        uses: azure/cli@v2.1.0
        env:
          ZIP_NAME: ${{ env.ZIP_NAME }}
          AZ_STORAGE_ACCOUNT: ${{ secrets.AZ_STORAGE_ACCOUNT }}
          AZ_STORAGE_CONTAINER: ${{ secrets.AZ_STORAGE_CONTAINER }}
        with:
          inlineScript: |
            set -euo pipefail
            : "${AZ_STORAGE_ACCOUNT:?AZ_STORAGE_ACCOUNT missing}"
            : "${AZ_STORAGE_CONTAINER:?AZ_STORAGE_CONTAINER missing}"

            az storage container create \
              --name "$AZ_STORAGE_CONTAINER" \
              --account-name "$AZ_STORAGE_ACCOUNT" \
              --auth-mode login --only-show-errors 1>/dev/null

            az storage blob upload \
              --account-name "$AZ_STORAGE_ACCOUNT" \
              --container-name "$AZ_STORAGE_CONTAINER" \
              --file "$ZIP_NAME" \
              --name "$ZIP_NAME" \
              --overwrite true \
              --auth-mode login --only-show-errors

      # --- VM downloads the blob using its Managed Identity + restarts service ---
      - name: Deploy on Azure VM (download with MI & restart)
        uses: azure/cli@v2.1.0
        env:
          AZURE_RESOURCE_GROUP: ${{ secrets.AZURE_RESOURCE_GROUP }}
          AZURE_VM_NAME: ${{ secrets.AZURE_VM_NAME }}
          AZ_STORAGE_ACCOUNT: ${{ secrets.AZ_STORAGE_ACCOUNT }}
          AZ_STORAGE_CONTAINER: ${{ secrets.AZ_STORAGE_CONTAINER }}
          ZIP_NAME: ${{ env.ZIP_NAME }}
        with:
          inlineScript: |
            set -euo pipefail
            az vm run-command invoke \
              --resource-group "$AZURE_RESOURCE_GROUP" \
              --name "$AZURE_VM_NAME" \
              --command-id RunShellScript \
              --scripts "
                set -euo pipefail
                DEPLOY_DIR=/opt/myapp
                TMP=/tmp
                FILE=\$TMP/${ZIP_NAME}

                # Ensure tools exist
                if ! command -v az >/dev/null 2>&1; then
                  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
                fi
                if ! command -v unzip >/dev/null 2>&1; then
                  sudo apt-get update -y && sudo apt-get install -y unzip
                fi

                # Login with the VM's Managed Identity
                az login --identity --allow-no-subscriptions 1>/dev/null

                # Download from Storage using MI (no SAS required)
                az storage blob download \
                  --account-name '${AZ_STORAGE_ACCOUNT}' \
                  --container-name '${AZ_STORAGE_CONTAINER}' \
                  --name '${ZIP_NAME}' \
                  --file \"\$FILE\" \
                  --auth-mode login \
                  --only-show-errors

                sudo mkdir -p \$DEPLOY_DIR
                sudo unzip -o \"\$FILE\" -d \$DEPLOY_DIR

                if sudo systemctl --quiet is-enabled myapp.service 2>/dev/null; then
                  sudo systemctl restart myapp.service
                  echo 'Restarted myapp.service'
                else
                  echo 'myapp.service not found — start your app as appropriate.'
                fi
              "