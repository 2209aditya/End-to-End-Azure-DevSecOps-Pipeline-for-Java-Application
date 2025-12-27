# End-to-End Azure DevSecOps Pipeline for Java Application

Complete production-grade CI/CD pipeline with **SonarQube**, **Trivy**, **OWASP**, **ACR**, **AKS**, **Helm**, **Argo CD**, and **Blue-Green Deployment**.

---

## 🎯 Pipeline Features

✅ **CI/CD**: Azure DevOps Pipelines  
✅ **Code Quality**: SonarQube  
✅ **Security Scanning**: Trivy, OWASP Dependency Check, Snyk  
✅ **Container Registry**: Azure Container Registry (ACR)  
✅ **Orchestration**: Azure Kubernetes Service (AKS)  
✅ **Package Manager**: Helm Charts  
✅ **GitOps**: Argo CD  
✅ **Deployment Strategy**: Blue-Green with zero downtime  
✅ **Monitoring**: Azure Monitor, Application Insights  

---

## 📐 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         DEVELOPER                                │
│                    (Push Code to Git)                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AZURE DEVOPS CI PIPELINE                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Build & Test │→ │  SonarQube   │→ │ OWASP Check  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Docker Build │→ │ Trivy Scan   │→ │  Push to ACR │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│  ┌──────────────┐  ┌──────────────┐                            │
│  │  Helm Chart  │→ │ Update GitOps│                            │
│  └──────────────┘  └──────────────┘                            │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                         ARGO CD                                  │
│              (Monitors GitOps Repo)                             │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AKS CLUSTER                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              BLUE-GREEN DEPLOYMENT                       │   │
│  │  ┌────────────────┐        ┌────────────────┐          │   │
│  │  │  Blue (v1.0)   │        │  Green (v2.0)  │          │   │
│  │  │   Active       │   →    │   Standby      │          │   │
│  │  └────────────────┘        └────────────────┘          │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
java-devsecops-app/
├── src/
│   └── main/
│       ├── java/
│       └── resources/
├── pom.xml
├── Dockerfile
├── .trivyignore
├── sonar-project.properties
├── azure-pipelines.yml
├── helm/
│   └── java-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-blue.yaml
│       ├── values-green.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           ├── configmap.yaml
│           ├── secret.yaml
│           ├── hpa.yaml
│           └── networkpolicy.yaml
├── k8s-gitops/
│   ├── prod/
│   │   ├── blue/
│   │   │   └── values.yaml
│   │   └── green/
│   │       └── values.yaml
│   └── argocd/
│       ├── application-blue.yaml
│       └── application-green.yaml
└── README.md
```

---

## 🔧 Prerequisites Setup

### 1. Azure Resources

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Create Resource Group
az group create --name rg-devsecops-prod --location centralindia

# Create ACR
az acr create --resource-group rg-devsecops-prod \
  --name acrdevsecops --sku Premium

# Create AKS
az aks create \
  --resource-group rg-devsecops-prod \
  --name aks-devsecops-prod \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys \
  --attach-acr acrdevsecops

# Get AKS credentials
az aks get-credentials --resource-group rg-devsecops-prod --name aks-devsecops-prod
```

### 2. Install Tools on AKS

```bash
# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get Argo CD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward Argo CD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Install Metrics Server (for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 3. Azure DevOps Setup

1. Create Azure DevOps Organization
2. Create New Project: `java-devsecops`
3. Install Extensions:
   - SonarQube
   - OWASP Dependency Check
   - Trivy

---

## 🔐 Security Configuration

### SonarQube Setup

**`sonar-project.properties`**
```properties
sonar.projectKey=java-devsecops-app
sonar.projectName=Java DevSecOps Application
sonar.projectVersion=1.0
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.java.test.binaries=target/test-classes
sonar.junit.reportPaths=target/surefire-reports
sonar.jacoco.reportPaths=target/jacoco.exec
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
sonar.language=java
sonar.sourceEncoding=UTF-8

# Quality Gate
sonar.qualitygate.wait=true
sonar.qualitygate.timeout=300
```

### Trivy Configuration

**`.trivyignore`**
```
# Ignore specific vulnerabilities with justification
CVE-2023-12345  # False positive - not applicable to our use case
CVE-2023-67890  # Will be fixed in next dependency update
```

---

## 🏗 Application Files

### Java Application (Sample)

**`pom.xml`**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>
    
    <groupId>com.devsecops</groupId>
    <artifactId>java-app</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    
    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>
    
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.11</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.owasp</groupId>
                <artifactId>dependency-check-maven</artifactId>
                <version>9.0.7</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>check</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

### Dockerfile (Multi-stage with Security)

**`Dockerfile`**
```dockerfile
# Stage 1: Build
FROM maven:3.9.5-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime (Distroless for security)
FROM gcr.io/distroless/java17-debian12:nonroot
WORKDIR /app

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Run as non-root user (distroless already sets this)
USER nonroot:nonroot

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## 🚀 Azure DevOps CI/CD Pipeline

**`azure-pipelines.yml`**
```yaml
trigger:
  branches:
    include:
    - main
    - develop
  paths:
    exclude:
    - README.md
    - docs/*

variables:
  azureSubscription: 'Azure-ServiceConnection'
  acrName: 'acrdevsecops'
  acrLoginServer: 'acrdevsecops.azurecr.io'
  imageRepository: 'java-app'
  dockerfilePath: 'Dockerfile'
  tag: '$(Build.BuildId)'
  k8sNamespace: 'prod'
  helmChartPath: 'helm/java-app'
  gitopsRepo: 'https://github.com/YOUR_USERNAME/k8s-gitops.git'
  
  # SonarQube
  sonarQubeServiceConnection: 'SonarQube-Connection'
  
  # Deployment Strategy
  deploymentColor: 'blue'  # Change to 'green' for next deployment

pool:
  vmImage: 'ubuntu-latest'

stages:
#############################################
# STAGE 1: BUILD & UNIT TEST
#############################################
- stage: Build
  displayName: 'Build & Unit Test'
  jobs:
  - job: BuildJob
    displayName: 'Maven Build and Test'
    steps:
    - task: Maven@3
      displayName: 'Maven Build'
      inputs:
        mavenPomFile: 'pom.xml'
        goals: 'clean package'
        options: '-DskipTests=false'
        publishJUnitResults: true
        testResultsFiles: '**/surefire-reports/TEST-*.xml'
        javaHomeOption: 'JDKVersion'
        jdkVersionOption: '1.17'
        mavenVersionOption: 'Default'
        codeCoverageToolOption: 'JaCoCo'
    
    - task: PublishCodeCoverageResults@1
      displayName: 'Publish Code Coverage'
      inputs:
        codeCoverageTool: 'JaCoCo'
        summaryFileLocation: '$(System.DefaultWorkingDirectory)/**/site/jacoco/jacoco.xml'
        reportDirectory: '$(System.DefaultWorkingDirectory)/**/site/jacoco'
    
    - task: CopyFiles@2
      displayName: 'Copy JAR to Staging'
      inputs:
        sourceFolder: '$(System.DefaultWorkingDirectory)/target'
        contents: '*.jar'
        targetFolder: '$(Build.ArtifactStagingDirectory)'
    
    - task: PublishBuildArtifacts@1
      displayName: 'Publish Build Artifacts'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)'
        artifactName: 'drop'

#############################################
# STAGE 2: CODE QUALITY - SONARQUBE
#############################################
- stage: CodeQuality
  displayName: 'Code Quality Analysis'
  dependsOn: Build
  jobs:
  - job: SonarQubeJob
    displayName: 'SonarQube Analysis'
    steps:
    - task: Maven@3
      displayName: 'Maven Build for SonarQube'
      inputs:
        mavenPomFile: 'pom.xml'
        goals: 'clean verify'
        options: '-DskipTests=false'
    
    - task: SonarQubePrepare@5
      displayName: 'Prepare SonarQube Analysis'
      inputs:
        SonarQube: '$(sonarQubeServiceConnection)'
        scannerMode: 'Other'
        extraProperties: |
          sonar.projectKey=java-devsecops-app
          sonar.projectName=Java DevSecOps Application
          sonar.sources=src/main/java
          sonar.tests=src/test/java
          sonar.java.binaries=target/classes
          sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
    
    - task: SonarQubeAnalyze@5
      displayName: 'Run SonarQube Analysis'
    
    - task: SonarQubePublish@5
      displayName: 'Publish SonarQube Results'
      inputs:
        pollingTimeoutSec: '300'
    
    - task: sonarcloud-buildbreaker@2
      displayName: 'Break Build on Quality Gate Failure'
      inputs:
        SonarCloud: '$(sonarQubeServiceConnection)'

#############################################
# STAGE 3: SECURITY SCANNING
#############################################
- stage: SecurityScanning
  displayName: 'Security Scanning'
  dependsOn: CodeQuality
  jobs:
  
  # OWASP Dependency Check
  - job: OWASPDependencyCheck
    displayName: 'OWASP Dependency Check'
    steps:
    - task: Maven@3
      displayName: 'OWASP Dependency Check'
      inputs:
        mavenPomFile: 'pom.xml'
        goals: 'dependency-check:check'
        options: '-DfailBuildOnCVSS=7'
    
    - task: PublishBuildArtifacts@1
      displayName: 'Publish OWASP Report'
      condition: always()
      inputs:
        pathToPublish: '$(System.DefaultWorkingDirectory)/target/dependency-check-report.html'
        artifactName: 'owasp-report'
  
  # Snyk Security Scan
  - job: SnykScan
    displayName: 'Snyk Security Scan'
    steps:
    - task: SnykSecurityScan@1
      displayName: 'Snyk Code & Dependencies'
      inputs:
        serviceConnectionEndpoint: 'Snyk-Connection'
        testType: 'app'
        monitorWhen: 'always'
        failOnIssues: true
        projectName: 'java-devsecops-app'
        organization: 'your-org'

#############################################
# STAGE 4: DOCKER BUILD & SCAN
#############################################
- stage: DockerBuildAndScan
  displayName: 'Docker Build & Security Scan'
  dependsOn: SecurityScanning
  jobs:
  - job: DockerJob
    displayName: 'Build, Scan & Push Docker Image'
    steps:
    - task: Docker@2
      displayName: 'Build Docker Image'
      inputs:
        command: 'build'
        repository: '$(imageRepository)'
        dockerfile: '$(dockerfilePath)'
        tags: |
          $(tag)
          latest
        arguments: '--no-cache'
    
    # Trivy Filesystem Scan
    - task: Bash@3
      displayName: 'Install Trivy'
      inputs:
        targetType: 'inline'
        script: |
          wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
          echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
          sudo apt-get update
          sudo apt-get install trivy -y
    
    - task: Bash@3
      displayName: 'Trivy Image Scan'
      inputs:
        targetType: 'inline'
        script: |
          trivy image --exit-code 0 --severity LOW,MEDIUM --format table $(imageRepository):$(tag)
          trivy image --exit-code 1 --severity HIGH,CRITICAL --format table $(imageRepository):$(tag)
          trivy image --format json --output trivy-report.json $(imageRepository):$(tag)
    
    - task: PublishBuildArtifacts@1
      displayName: 'Publish Trivy Report'
      condition: always()
      inputs:
        pathToPublish: 'trivy-report.json'
        artifactName: 'trivy-report'
    
    # Azure Container Registry Login
    - task: Docker@2
      displayName: 'Login to ACR'
      inputs:
        command: 'login'
        containerRegistry: '$(azureSubscription)'
    
    # Tag and Push to ACR
    - task: Docker@2
      displayName: 'Tag Image for ACR'
      inputs:
        command: 'tag'
        arguments: '$(imageRepository):$(tag) $(acrLoginServer)/$(imageRepository):$(tag)'
    
    - task: Docker@2
      displayName: 'Push to ACR'
      inputs:
        command: 'push'
        repository: '$(acrLoginServer)/$(imageRepository)'
        tags: |
          $(tag)
          latest
    
    # Scan image in ACR with Trivy
    - task: Bash@3
      displayName: 'Trivy ACR Image Scan'
      inputs:
        targetType: 'inline'
        script: |
          trivy image --severity HIGH,CRITICAL \
            $(acrLoginServer)/$(imageRepository):$(tag)

#############################################
# STAGE 5: HELM PACKAGE & UPDATE GITOPS
#############################################
- stage: HelmAndGitOps
  displayName: 'Helm Package & GitOps Update'
  dependsOn: DockerBuildAndScan
  jobs:
  - job: HelmJob
    displayName: 'Package Helm & Update GitOps Repo'
    steps:
    - task: HelmInstaller@1
      displayName: 'Install Helm'
      inputs:
        helmVersionToInstall: 'latest'
    
    - task: Bash@3
      displayName: 'Update Helm Values with New Image'
      inputs:
        targetType: 'inline'
        script: |
          # Update image tag in values file
          sed -i "s|tag: .*|tag: $(tag)|g" $(helmChartPath)/values-$(deploymentColor).yaml
          sed -i "s|repository: .*|repository: $(acrLoginServer)/$(imageRepository)|g" $(helmChartPath)/values-$(deploymentColor).yaml
    
    - task: HelmDeploy@0
      displayName: 'Helm Lint'
      inputs:
        command: 'lint'
        arguments: '$(helmChartPath)'
    
    - task: HelmDeploy@0
      displayName: 'Helm Package'
      inputs:
        command: 'package'
        chartPath: '$(helmChartPath)'
        destination: '$(Build.ArtifactStagingDirectory)/helm'
    
    - task: PublishBuildArtifacts@1
      displayName: 'Publish Helm Chart'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/helm'
        artifactName: 'helm-chart'
    
    # Update GitOps Repository
    - task: Bash@3
      displayName: 'Update GitOps Repository'
      inputs:
        targetType: 'inline'
        script: |
          git config --global user.email "pipeline@azure.com"
          git config --global user.name "Azure Pipeline"
          
          # Clone GitOps repo
          git clone $(gitopsRepo) gitops-repo
          cd gitops-repo
          
          # Update values file for deployment color
          cp ../$(helmChartPath)/values-$(deploymentColor).yaml k8s-gitops/prod/$(deploymentColor)/values.yaml
          
          # Commit and push
          git add .
          git commit -m "Update $(deploymentColor) deployment to version $(tag)"
          git push origin main
      env:
        GIT_TOKEN: $(System.AccessToken)

#############################################
# STAGE 6: DEPLOY TO AKS (via Argo CD Sync)
#############################################
- stage: Deploy
  displayName: 'Deploy to AKS'
  dependsOn: HelmAndGitOps
  jobs:
  - deployment: DeployToAKS
    displayName: 'Trigger Argo CD Sync'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: KubectlInstaller@0
            displayName: 'Install kubectl'
          
          - task: Kubernetes@1
            displayName: 'kubectl login'
            inputs:
              connectionType: 'Azure Resource Manager'
              azureSubscriptionEndpoint: '$(azureSubscription)'
              azureResourceGroup: 'rg-devsecops-prod'
              kubernetesCluster: 'aks-devsecops-prod'
              command: 'login'
          
          - task: Bash@3
            displayName: 'Install Argo CD CLI'
            inputs:
              targetType: 'inline'
              script: |
                curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
                chmod +x /usr/local/bin/argocd
          
          - task: Bash@3
            displayName: 'Argo CD Sync Application'
            inputs:
              targetType: 'inline'
              script: |
                # Get Argo CD admin password
                ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
                
                # Login to Argo CD
                argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure
                
                # Sync application
                argocd app sync java-app-$(deploymentColor) --prune
                
                # Wait for sync to complete
                argocd app wait java-app-$(deploymentColor) --health

#############################################
# STAGE 7: SMOKE TESTS & VALIDATION
#############################################
- stage: SmokeTests
  displayName: 'Smoke Tests & Validation'
  dependsOn: Deploy
  jobs:
  - job: SmokeTestJob
    displayName: 'Run Smoke Tests'
    steps:
    - task: Bash@3
      displayName: 'Health Check'
      inputs:
        targetType: 'inline'
        script: |
          # Get service endpoint
          SERVICE_IP=$(kubectl get svc java-app-$(deploymentColor) -n prod -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
          
          # Health check
          curl -f http://$SERVICE_IP/actuator/health || exit 1
          
          # Basic functionality test
          curl -f http://$SERVICE_IP/api/test || exit 1
    
    - task: Bash@3
      displayName: 'Performance Test'
      inputs:
        targetType: 'inline'
        script: |
          # Install Apache Bench
          sudo apt-get install apache2-utils -y
          
          SERVICE_IP=$(kubectl get svc java-app-$(deploymentColor) -n prod -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
          
          # Run performance test (100 requests, 10 concurrent)
          ab -n 100 -c 10 http://$SERVICE_IP/api/test

#############################################
# STAGE 8: SWITCH TRAFFIC (Blue-Green)
#############################################
- stage: SwitchTraffic
  displayName: 'Switch Traffic to New Version'
  dependsOn: SmokeTests
  condition: succeeded()
  jobs:
  - deployment: SwitchTrafficJob
    displayName: 'Update Service Selector'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: Bash@3
            displayName: 'Switch Traffic'
            inputs:
              targetType: 'inline'
              script: |
                # Update service selector to point to new color
                kubectl patch service java-app-service -n prod -p '{"spec":{"selector":{"version":"$(deploymentColor)"}}}'
                
                echo "Traffic switched to $(deploymentColor) deployment"
          
          - task: Bash@3
            displayName: 'Verify Traffic Switch'
            inputs:
              targetType: 'inline'
              script: |
                sleep 10
                SERVICE_IP=$(kubectl get svc java-app-service -n prod -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                curl -f http://$SERVICE_IP/actuator/info | grep $(tag)

#############################################
# STAGE 9: CLEANUP OLD DEPLOYMENT
#############################################
- stage: Cleanup
  displayName: 'Cleanup Old Deployment'
  dependsOn: SwitchTraffic
  condition: succeeded()
  jobs:
  - job: CleanupJob
    displayName: 'Scale Down Old Deployment'
    steps:
    - task: Bash@3
      displayName: 'Scale Down Old Color'
      inputs:
        targetType: 'inline'
        script: |
          # Determine old color
          if [ "$(deploymentColor)" == "blue" ]; then
            OLD_COLOR="green"
          else
            OLD_COLOR="blue"
          fi
          
          # Scale down old deployment
          kubectl scale deployment java-app-$OLD_COLOR -n prod --replicas=0
          
          echo "Scaled down $OLD_COLOR deployment"
```

---

## 📦 Helm Chart

### Chart.yaml

**`helm/java-app/Chart.yaml`**
```yaml
apiVersion: v2
name: java-app
description: Java Spring Boot Application Helm Chart
type: application
version: 1.0.0
appVersion: "1.0.0"
keywords:
  - java
  - spring-boot
  - microservices
maintainers:
  - name: DevSecOps Team
    email: devsecops@company.com
```

### values.yaml (Base)

**`helm/java-app/values.yaml`**
```yaml
replicaCount: 2

image:
  repository: acrdevsecops.azurecr.io/java-app
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: azure/application-gateway
  annotations:
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
    appgw.ingress.kubernetes.io/backend-protocol: "http"
  hosts:
    - host: java-app.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 1000m
    memory: 2Gi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3

env:
  - name: SPRING_PROFILES_ACTIVE
    value: "prod"
  - name: JAVA_OPTS
    value: "-Xms512m -Xmx1024m -XX:+UseG1GC"

configMap:
  data:
    application.properties: |
      server.port=8080
      management.endpoints.web.exposure.include=health,info,metrics,prometheus
      management.endpoint.health.probes.enabled=true
      management.health.livenessState.enabled=true
      management.health.readinessState.enabled=true

secrets:
  DATABASE_URL: "jdbc:postgresql://db-server:5432/appdb"
  DATABASE_USERNAME: "dbuser"
  DATABASE_PASSWORD: "changeme"
  JWT_SECRET: "changeme"

networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
  ingress:
    - from:
      - namespaceSelector: {}

podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL

serviceAccount:
  create: true
  name: java-app-sa
```

### values-blue.yaml

**`helm/java-app/values-blue.yaml`**
```yaml
version: blue

labels:
  version: blue
  deployment: blue

image:
  tag: "1.0.0"

service:
  name: java-app-blue
```

### values-green.yaml

**`helm/java-app/values-green.yaml`**
```yaml
version: green

labels:
  version: green
  deployment: green

image:
  tag: "2.0.0"

service:
  name: java-app-green
```

### Deployment Template

**`helm/java-app/templates/deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "java-app.fullname" . }}-{{ .Values.version | default "blue" }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "java-app.labels" . | nindent 4 }}
    version: {{ .Values.version | default "blue" }}
spec:
  replicas: {{ .Values.replicaCount }}
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      {{- include "java-app.selectorLabels" . | nindent 6 }}
      version: {{ .Values.version | default "blue" }}
  template:
    metadata:
      labels:
        {{- include "java-app.selectorLabels" . | nindent 8 }}
        version: {{ .Values.version | default "blue" }}
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/actuator/prometheus"
    spec:
      serviceAccountName: {{ include "java-app.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        env:
        {{- range .Values.env }}
        - name: {{ .name }}
          value: {{ .value | quote }}
        {{- end }}
        envFrom:
        - configMapRef:
            name: {{ include "java-app.fullname" . }}-config
        - secretRef:
            name: {{ include "java-app.fullname" . }}-secret
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
        livenessProbe:
          {{- toYaml .Values.livenessProbe | nindent 10 }}
        readinessProbe:
          {{- toYaml .Values.readinessProbe | nindent 10 }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 10 }}
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /app/cache
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
```

### Service Template

**`helm/java-app/templates/service.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "java-app.fullname" . }}-{{ .Values.version | default "blue" }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "java-app.labels" . | nindent 4 }}
    version: {{ .Values.version | default "blue" }}
spec:
  type: {{ .Values.service.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: http
  selector:
    {{- include "java-app.selectorLabels" . | nindent 4 }}
    version: {{ .Values.version | default "blue" }}
---
# Main service for traffic switching
apiVersion: v1
kind: Service
metadata:
  name: {{ include "java-app.fullname" . }}-service
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "java-app.labels" . | nindent 4 }}
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  selector:
    {{- include "java-app.selectorLabels" . | nindent 4 }}
    version: blue  # Change this to switch traffic
```

### Ingress Template

**`helm/java-app/templates/ingress.yaml`**
```yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "java-app.fullname" . }}-ingress
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "java-app.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ include "java-app.fullname" $ }}-service
                port:
                  number: 80
          {{- end }}
    {{- end }}
{{- end }}
```

### ConfigMap Template

**`helm/java-app/templates/configmap.yaml`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "java-app.fullname" . }}-config
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "java-app.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.configMap.data }}
  {{ $key }}: |
    {{ $value | nindent 4 }}
  {{- end }}
```

### Secret Template

**`helm/java-app/templates/secret.yaml`**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "java-app.fullname" . }}-secret
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "java-app.labels" . | nindent 4 }}
type: Opaque
stringData:
  {{- range $key, $value := .Values.secrets }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
```

### HPA Template

**`helm/java-app/templates/hpa.yaml`**
```yaml
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "java-app.fullname" . }}-{{ .Values.version | default "blue" }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "java-app.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "java-app.fullname" . }}-{{ .Values.version | default "blue" }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
  {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
  {{- end }}
  {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
  {{- end }}
{{- end }}
```

### Network Policy Template

**`helm/java-app/templates/networkpolicy.yaml`**
```yaml
{{- if .Values.networkPolicy.enabled }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "java-app.fullname" . }}-netpol
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "java-app.labels" . | nindent 4 }}
spec:
  podSelector:
    matchLabels:
      {{- include "java-app.selectorLabels" . | nindent 6 }}
  policyTypes:
    {{- toYaml .Values.networkPolicy.policyTypes | nindent 4 }}
  ingress:
    {{- toYaml .Values.networkPolicy.ingress | nindent 4 }}
{{- end }}
```

### Helpers Template

**`helm/java-app/templates/_helpers.tpl`**
```yaml
{{/*
Expand the name of the chart.
*/}}
{{- define "java-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "java-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "java-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "java-app.labels" -}}
helm.sh/chart: {{ include "java-app.chart" . }}
{{ include "java-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "java-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "java-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "java-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "java-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
```

---

## 🔄 Argo CD Applications

### Blue Deployment

**`k8s-gitops/argocd/application-blue.yaml`**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: java-app-blue
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  
  source:
    repoURL: https://github.com/YOUR_USERNAME/java-devsecops-app.git
    targetRevision: main
    path: helm/java-app
    helm:
      valueFiles:
        - values.yaml
        - values-blue.yaml
  
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
```

### Green Deployment

**`k8s-gitops/argocd/application-green.yaml`**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: java-app-green
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  
  source:
    repoURL: https://github.com/YOUR_USERNAME/java-devsecops-app.git
    targetRevision: main
    path: helm/java-app
    helm:
      valueFiles:
        - values.yaml
        - values-green.yaml
  
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
```

---

## 🔐 Azure Key Vault Integration

### Install CSI Driver

```bash
# Add Helm repo
helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts

# Install CSI driver
helm install csi csi-secrets-store-provider-azure/csi-secrets-store-provider-azure \
  --namespace kube-system
```

### Create Azure Key Vault

```bash
# Create Key Vault
az keyvault create \
  --name kv-devsecops-prod \
  --resource-group rg-devsecops-prod \
  --location centralindia

# Add secrets
az keyvault secret set --vault-name kv-devsecops-prod \
  --name database-password --value "SuperSecretPassword123!"

az keyvault secret set --vault-name kv-devsecops-prod \
  --name jwt-secret --value "MyJWTSecret456!"
```

### SecretProviderClass

**`k8s/secretproviderclass.yaml`**
```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-keyvault
  namespace: prod
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: "<MANAGED_IDENTITY_CLIENT_ID>"
    keyvaultName: "kv-devsecops-prod"
    cloudName: "AzurePublicCloud"
    objects: |
      array:
        - |
          objectName: database-password
          objectType: secret
          objectVersion: ""
        - |
          objectName: jwt-secret
          objectType: secret
          objectVersion: ""
    tenantId: "<TENANT_ID>"
  secretObjects:
  - secretName: app-secrets
    type: Opaque
    data:
    - objectName: database-password
      key: DATABASE_PASSWORD
    - objectName: jwt-secret
      key: JWT_SECRET
```

---

## 📊 Monitoring Setup

### Azure Monitor

```bash
# Enable Container Insights
az aks enable-addons \
  --resource-group rg-devsecops-prod \
  --name aks-devsecops-prod \
  --addons monitoring
```

### Prometheus & Grafana

```bash
# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

# Get Grafana password
kubectl get secret -n monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode

# Port forward Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

---

## 🧪 Testing Strategy

### Unit Tests (Maven)

```bash
mvn test
mvn jacoco:report
```

### Integration Tests

```bash
mvn verify -P integration-tests
```

### Performance Tests (JMeter)

**`jmeter-test-plan.jmx`** - Create a JMeter test plan

```bash
jmeter -n -t jmeter-test-plan.jmx -l results.jtl -e -o report
```

### Security Tests

```bash
# OWASP ZAP
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://your-app-url.com

# Trivy
trivy image acrdevsecops.azurecr.io/java-app:latest
```

---

## 🚨 Rollback Strategy

### Manual Rollback

```bash
# Switch service back to previous version
kubectl patch service java-app-service -n prod \
  -p '{"spec":{"selector":{"version":"blue"}}}'

# Or scale up old deployment
kubectl scale deployment java-app-blue -n prod --replicas=2
```

### Argo CD Rollback

```bash
# View history
argocd app history java-app-green

# Rollback to previous version
argocd app rollback java-app-green <revision-number>
```

### Helm Rollback

```bash
# List releases
helm list -n prod

# Rollback
helm rollback java-app -n prod
```

---

## 📋 Blue-Green Deployment Workflow

### Step-by-Step Process

1. **Initial State**: Blue is active, Green is idle
   ```bash
   kubectl get deployments -n prod
   # java-app-blue: 2 replicas
   # java-app-green: 0 replicas
   ```

2. **Deploy to Green**: Pipeline deploys new version
   ```bash
   # Pipeline updates Green deployment
   # Green scales to 2 replicas
   ```

3. **Run Smoke Tests**: Validate Green deployment
   ```bash
   # Tests run against Green service
   curl http://java-app-green/actuator/health
   ```

4. **Switch Traffic**: Update main service selector
   ```bash
   kubectl patch service java-app-service -n prod \
     -p '{"spec":{"selector":{"version":"green"}}}'
   ```

5. **Monitor**: Watch metrics for 15-30 minutes
   ```bash
   kubectl top pods -n prod
   kubectl logs -n prod -l version=green -f
   ```

6. **Scale Down Blue**: Remove old version
   ```bash
   kubectl scale deployment java-app-blue -n prod --replicas=0
   ```

---

## 🔒 Security Checklist

- ✅ SonarQube quality gate passed
- ✅ No HIGH/CRITICAL vulnerabilities (Trivy)
- ✅ OWASP Dependency Check passed
- ✅ Container runs as non-root
- ✅ Read-only root filesystem
- ✅ Network policies enforced
- ✅ Secrets in Azure Key Vault
- ✅ Image signed and verified
- ✅ RBAC configured
- ✅ Pod Security Standards enabled
- ✅ TLS/SSL for ingress
- ✅ Regular security scans scheduled

---

## 📚 Useful Commands

### Pipeline Debugging

```bash
# View pipeline logs
az pipelines runs show --id <run-id> --org <org-url> --project <project>

# Retry failed stage
az pipelines run --id <run-id> --org <org-url> --project <project>
```

### Kubernetes Debugging

```bash
# Check pod status
kubectl get pods -n prod -o wide

# Describe pod
kubectl describe pod <pod-name> -n prod

# View logs
kubectl logs -n prod <pod-name> -f

# Execute into pod
kubectl exec -it -n prod <pod-name> -- /bin/sh

# Check events
kubectl get events -n prod --sort-by='.lastTimestamp'
```

### Argo CD Commands

```bash
# List applications
argocd app list

# Get application details
argocd app get java-app-blue

# Sync application
argocd app sync java-app-blue

# View sync status
argocd app wait java-app-blue --health

# View logs
argocd app logs java-app-blue -f
```

---

## 🎓 Best Practices

### CI/CD
- Keep pipelines modular and reusable
- Use pipeline templates for common tasks
- Implement proper error handling
- Store sensitive data in Azure Key Vault
- Use semantic versioning for images
- Tag images with Git commit SHA

### Security
- Scan at every stage (code, dependencies, container)
- Enforce quality gates (don't deploy if scans fail)
- Use distroless or minimal base images
- Run containers as non-root
- Implement least privilege access
- Rotate secrets regularly

### Kubernetes
- Use namespaces for isolation
- Set resource requests and limits
- Implement health checks
- Use HPA for auto-scaling
- Apply network policies
- Use Pod Security Standards

### Monitoring
- Collect metrics at all layers
- Set up alerts for critical issues
- Monitor deployment health
- Track deployment frequency and lead time
- Implement distributed tracing

---

## 🧹 Cleanup

```bash
# Delete Argo CD applications
kubectl delete -f k8s-gitops/argocd/

# Delete Helm releases
helm uninstall java-app-blue -n prod
helm uninstall java-app-green -n prod

# Delete AKS cluster
az aks delete --resource-group rg-devsecops-prod --name aks-devsecops-prod --yes

# Delete resource group
az group delete --name rg-devsecops-prod --yes
```

---

## 📖 Additional Resources

- [Azure DevOps Documentation](https://docs.microsoft.com/azure/devops/)
- [SonarQube Best Practices](https://docs.sonarqube.org/latest/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)

---

## 📄 License

MIT License

---

**Happy DevSecOps! 🚀🔒**
