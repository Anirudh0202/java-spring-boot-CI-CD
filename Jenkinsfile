pipeline {
  agent any

  environment {
    IMAGE = "anirudhdwivedi/spring-boot-hello"
    DOCKER_CREDENTIALS = 'dockerhub-creds'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Test') {
      steps {
        sh 'mvn -B -DskipTests=false clean package'
      }
      post {
        always {
          junit '**/target/surefire-reports/*.xml'
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh "docker build -t ${IMAGE}:${env.BUILD_NUMBER} ."
        sh "docker tag ${IMAGE}:${env.BUILD_NUMBER} ${IMAGE}:latest"
      }
    }

    stage('Push to DockerHub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS) {
            sh "docker push ${IMAGE}:${env.BUILD_NUMBER}"
            sh "docker push ${IMAGE}:latest"
          }
        }
      }
    }

    stage('Deploy (local)') {
      steps {
        script {
          sh '''
            if [ "$(docker ps -q -f name=spring-boot-hello)" != "" ]; then
              docker rm -f spring-boot-hello || true
            fi
            docker run -d --name spring-boot-hello -p 8081:8080 ${IMAGE}:${env.BUILD_NUMBER}
          '''
        }
      }
    }
  }

  post {
    success {
      echo "🎉 Build & deploy successful: ${IMAGE}:${env.BUILD_NUMBER}"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}
