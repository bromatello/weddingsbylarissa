pipeline {
    agent any 

    environment {
        // Use your Docker Hub username/repo
        DOCKER_IMAGE = "chrisbromatello/weddingsbylarissa"
        // This ID must match exactly what you created in Manage Jenkins > Credentials
        DOCKER_HUB_CREDS = credentials('docker-hub-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                // This pulls the code from the repo you configured in the UI
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                // Use 'bat' for Windows!
                bat "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                bat "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Windows batch syntax for environment variables uses %VAR%
                bat "echo %DOCKER_HUB_CREDS_PSW% | docker login -u %DOCKER_HUB_CREDS_USR% --password-stdin"
                bat "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                bat "docker push ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Deploy to GCP (Example)') {
            steps {
                // This will only work if the gcloud CLI is installed on your Windows machine
                bat "gcloud run deploy weddingsbylarissa --image ${DOCKER_IMAGE}:${BUILD_NUMBER} --platform managed --region us-central1"
            }
        }
    }

    post {
        always {
            // Log out so your credentials aren't left on the disk
            bat "docker logout"
        }
    }
}