pipeline {
    agent any
    tools {
        maven 'Maven3'
        terraform 'Terraform'
    }
    environment {
        APP_NAME = "devops-test"
        DOCKER_USER_NAME = "davechedjoun"
        IMAGE_NAME = "${DOCKER_USER_NAME}/${APP_NAME}"
        CONTAINER_NAME = "${BUILD_NUMBER}"
        AWS_DEFAULT_REGION = 'us-east-1'
        SERVER_IP = ''
        USER_NAME = 'AZIMUT'
    }
    stages {
        stage('Deploy Infrastructure') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'ssh_key_file', variable: 'SSH_KEY_FILE')]) {
                        bat """
                            copy %SSH_KEY_FILE% my-ssh-key.pem
                        """
                    }
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/DavePhil/sample_devops_project_infra.git']])
                    bat """
                        cd terraform
                        terraform destroy -var="aws_access_key_id=%AWS_ACCESS_KEY_ID%" -var="aws_secret_access_key=%AWS_SECRET_ACCESS_KEY%"
                    """
                }
            }
        }
    }
}
