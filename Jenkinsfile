pipeline {
    agent any

    environment {
        IMAGE = "anirudhdwivedi/spring-boot-hello"     // your DockerHub repo
        TAG   = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven (inside Docker)') {
            steps {
                sh '''
                    docker run --rm \
                    -v "$PWD":/app \
                    -w /app \
                    maven:3.9.6-eclipse-temurin-17 \
                    mvn -B -DskipTests=false clean package
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${IMAGE}:${TAG} ."
                sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                }
                sh "docker push ${IMAGE}:${TAG}"
                sh "docker push ${IMAGE}:latest"
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker rm -f spring-boot-hello || true
                    docker run -d --name spring-boot-hello -p 8081:8080 ${IMAGE}:${TAG}
                '''
            }
        }
    }

    post {
        success {
            echo "Build SUCCESS: ${IMAGE}:${TAG}"
        }
        failure {
            echo "Build FAILED"
        }
    }
}
