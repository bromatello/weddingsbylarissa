pipeline {
    agent any 

    environment {
        DOCKER_IMAGE = "chrisbromatello/weddingsbylarissa"
        DOCKER_HUB_CREDS = credentials('docker-hub-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Log in using the environment variables automatically created by 'credentials'
                sh "echo ${DOCKER_HUB_CREDS_PSW} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin"
                sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                sh "docker push ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Deploy to GCP (Example)') {
            steps {
                // Using the gcloud CLI (assumes it is installed on the Jenkins server)
                sh "gcloud run deploy my-service --image ${DOCKER_IMAGE}:${BUILD_NUMBER} --platform managed"
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
    }
}