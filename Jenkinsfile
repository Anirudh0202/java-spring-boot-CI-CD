pipeline {
    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        IMAGE = "anirudhdwivedi/spring-boot-hello"
        DOCKER_CREDENTIALS = "dockerhub-creds"
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

        stage('Deploy') {
            steps {
                sh '''
                    docker rm -f spring-boot-hello || true
                    docker run -d --name spring-boot-hello -p 8081:8080 ${IMAGE}:${env.BUILD_NUMBER}
                '''
            }
        }
    }
}
