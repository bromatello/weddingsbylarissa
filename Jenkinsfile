pipeline {
    agent any 

    environment {
        DOCKER_IMAGE = "chrisbromatello/weddingsbylarissa"
        // 1. Paste your Harness Webhook URL here
        HARNESS_WEBHOOK = "https://app.harness.io/gateway/pipeline/api/webhook/custom/GC7ejTXlQa26K9GBecb4Zg/v3?accountIdentifier=6gvkA-e0SF6kkyO0tu7Qag&orgIdentifier=default&projectIdentifier=default_project&pipelineIdentifier=WeddingAppDeploy&triggerIdentifier=jenkinstrigger"
        // 2. Paste your Harness API Key here
        HARNESS_KEY = "pat.abc123yourkeyhere"
    }

    stages {
        stage('Build and Push') {
            steps {
                checkout scm
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

        stage('Trigger Harness CD') {
            steps {
                // This 'rings the bell' to tell Harness to start the deployment
                // We escape the quotes for the JSON payload: \"tag\": \"%BUILD_NUMBER%\"
                bat """
                    curl -X POST -H "Content-Type: application/json" ^
                         -H "x-api-key: %HARNESS_KEY%" ^
                         --url "%HARNESS_WEBHOOK%" ^
                         -d "{\\"tag\\": \\"%BUILD_NUMBER%\\"}"
                """
            }
        }
    }
}