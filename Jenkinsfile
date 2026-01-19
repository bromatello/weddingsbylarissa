pipeline {
    agent any 

    environment {
        DOCKER_IMAGE = "chrisbromatello/weddingsbylarissa"
    }

    stages {
        stage('Build and Push') {
            steps {
                // 'checkout scm' happens automatically in Declarative, 
                // but we'll include it to be safe.
                checkout scm

                // Use 'withCredentials' to bind your Docker Hub secret
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', 
                                 passwordVariable: 'DOCKER_HUB_CREDS_PSW', 
                                 usernameVariable: 'DOCKER_HUB_CREDS_USR')]) {
                    
                    bat """
                        docker build -t %DOCKER_IMAGE%:%BUILD_NUMBER% .
                        docker tag %DOCKER_IMAGE%:%BUILD_NUMBER% %DOCKER_IMAGE%:latest
                        
                        echo %DOCKER_HUB_CREDS_PSW% | docker login -u %DOCKER_HUB_CREDS_USR% --password-stdin
                        
                        docker push %DOCKER_IMAGE%:%BUILD_NUMBER%
                        docker push %DOCKER_IMAGE%:latest
                        
                        docker logout
                    """
                }
            }
        }

        stage('Deploy to GCP') {
            steps {
                // Only runs if the previous stage succeeded
                bat "gcloud run deploy weddingsbylarissa --image %DOCKER_IMAGE%:%BUILD_NUMBER% --platform managed --region us-central1"
            }
        }
    }
}