pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    timeout(time: 60, unit: 'MINUTES')
  }

  environment {
    AWS_REGION      = 'ap-south-1'
    AWS_ACCOUNT_ID  = '049419513053'
    ECR_REPOSITORY  = 'boardgame'
    EKS_CLUSTER     = 'hackathon-eks'
    K8S_NAMESPACE   = 'default'
    APP_DIR         = 'board'
    IMAGE_TAG       = "${BUILD_NUMBER}"
    IMAGE_URI       = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${IMAGE_TAG}"
    SONAR_HOST_URL  = 'http://13.235.241.92:9000'
    TRIVY_IMAGE     = 'aquasec/trivy:latest'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build And Test') {
      steps {
        dir("${APP_DIR}") {
          sh './mvnw -B clean verify'
        }
      }
    }

    stage('SonarQube Scan') {
      steps {
        dir("${APP_DIR}") {
          withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
            sh '''
              ./mvnw -B sonar:sonar \
                -Dsonar.projectKey=boardgame \
                -Dsonar.host.url=${SONAR_HOST_URL} \
                -Dsonar.login=${SONAR_TOKEN}
            '''
          }
        }
      }
    }

    stage('Trivy File Scan') {
      steps {
        dir("${APP_DIR}") {
          sh '''
            docker run --rm \
              -v "$PWD":/workspace \
              ${TRIVY_IMAGE} fs /workspace \
              --severity HIGH,CRITICAL
          '''
        }
      }
    }

    stage('AWS Identity Check') {
      steps {
        sh 'aws sts get-caller-identity'
      }
    }

    stage('Build Docker Image') {
      steps {
        dir("${APP_DIR}") {
          sh '''
            docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .
            docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${IMAGE_URI}
          '''
        }
      }
    }

    stage('Trivy Image Scan') {
      steps {
        sh '''
          docker run --rm \
            -v /var/run/docker.sock:/var/run/docker.sock \
            ${TRIVY_IMAGE} image ${IMAGE_URI} \
            --severity HIGH,CRITICAL
        '''
      }
    }

    stage('Push To ECR') {
      steps {
        sh '''
          aws ecr describe-repositories --region ${AWS_REGION} --repository-names ${ECR_REPOSITORY} >/dev/null 2>&1 || \
          aws ecr create-repository --region ${AWS_REGION} --repository-name ${ECR_REPOSITORY}

          aws ecr get-login-password --region ${AWS_REGION} | \
          docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

          docker push ${IMAGE_URI}
        '''
      }
    }

    stage('Deploy To EKS') {
      steps {
        dir("${APP_DIR}") {
          sh '''
            aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
            sed "s|IMAGE_PLACEHOLDER|${IMAGE_URI}|g" k8s/deployment-service.yaml > k8s/rendered-deployment.yaml
            kubectl apply -n ${K8S_NAMESPACE} -f k8s/rendered-deployment.yaml
            kubectl rollout status deployment/boardgame-deployment -n ${K8S_NAMESPACE} --timeout=600s
            kubectl get pods -n ${K8S_NAMESPACE}
            kubectl get svc -n ${K8S_NAMESPACE}
          '''
        }
      }
    }
  }

  post {
    always {
      sh '''
        docker image prune -f || true
        docker builder prune -af || true
      '''
    }
  }
}
