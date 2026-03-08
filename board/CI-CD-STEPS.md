# Jenkins + ECR + EKS + SonarQube + Trivy Setup

## 1) Update Jenkinsfile placeholders

Edit [Jenkinsfile](./Jenkinsfile) and set:

- `ECR_ACCOUNT_ID`
- `EKS_CLUSTER_NAME`

Keep `AWS_REGION` as your region (`ap-south-1` now).

## 2) Jenkins tools required

On Jenkins controller/agent, install:

- JDK 17 (tool name: `jdk17`)
- Maven 3 (tool name: `maven3`)
- Docker
- AWS CLI v2
- kubectl
- Trivy

## 3) Jenkins plugins required

- Pipeline
- Git
- Credentials Binding
- SonarQube Scanner for Jenkins
- Pipeline: AWS Steps (optional, not mandatory for this Jenkinsfile)

## 4) Jenkins credentials required

Create these credentials in Jenkins:

1. `aws-jenkins-creds`
   - Type: `Username with password`
   - Username: AWS access key id
   - Password: AWS secret access key
2. `sonar-token`
   - Type: `Secret text`
   - Value: SonarQube token

## 5) SonarQube server in Jenkins

In `Manage Jenkins` -> `System` -> `SonarQube servers`:

- Name: `sonarqube-server`
- Server URL: your SonarQube URL
- Token: `sonar-token`

Configure SonarQube webhook:

- URL: `http://<jenkins-url>/sonarqube-webhook/`

## 6) EKS auth and permissions

AWS user used by Jenkins must have permissions for:

- ECR push/pull and repository create
- `eks:DescribeCluster`
- `sts:GetCallerIdentity`

Also ensure this IAM identity is mapped in EKS access so `kubectl apply` is allowed.

## 7) Configure Jenkins job

- Job type: Pipeline (or Multibranch Pipeline)
- Repository: this repo
- Script path: `board/Jenkinsfile`

## 8) Run and verify

Pipeline stages:

1. Build + test (`mvn verify`)
2. SonarQube scan + quality gate
3. Docker build
4. Trivy scan
5. Push image to ECR
6. Deploy manifest to EKS

Verify deployment:

```bash
kubectl get deploy,svc,pods -n default
```
