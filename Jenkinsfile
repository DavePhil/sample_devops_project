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
//         stage('Build Project') {
//             steps {
//                 checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/DavePhil/sample_devops_project']])
//                 bat 'mvn -B -DskipTests clean install'
//             }
//         }
//         stage('Test') {
//             steps {
//                 bat 'mvn test'
//             }
//             post {
//                 always {
//                     junit 'target/surefire-reports/*.xml'
//                 }
//             }
//         }
//         stage('Build Docker') {
//             steps {
//                 bat "docker build -t ${IMAGE_NAME} ."
//             }
//         }
//         stage('Deploy to Docker Hub') {
//             steps {
//                 script {
//                     withCredentials([string(credentialsId: 'DockerhubPwd', variable: 'DockerhubPwd')]) {
//                         bat "docker login -u ${DOCKER_USER_NAME} -p ${DockerhubPwd}"
//                     }
//                     bat "docker push ${IMAGE_NAME}"
//                 }
//             }
//         }
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
                        terraform init
                        terraform apply -auto-approve -var="aws_access_key_id=%AWS_ACCESS_KEY_ID%" -var="aws_secret_access_key=%AWS_SECRET_ACCESS_KEY%"
                        terraform output -raw instance_ip > server_ip.txt
                    """
                }
            }
        }
        stage('Run the image') {
            steps {
                script {
                    bat '''
                        cd terraform
                    '''
                    def address = bat(script: 'type "terraform\\server_ip.txt"', returnStdout: true).trim()
                    def ip_address = address.split('\r?\n')[-1]
                    echo "L'adresse IP lue est : ${ip_address}"
                    withCredentials([
                        string(credentialsId: 'DockerhubPwd', variable: 'DOCKERHUB_PWD'),
                        file(credentialsId: 'ssh_key_file', variable: 'SSH_KEY_FILE')
                    ]) {
                        bat """
                            icacls %SSH_KEY_FILE% /inheritance:r /remove:g /grant:r ${USER_NAME}:(R)
                            ssh -i %SSH_KEY_FILE% -o StrictHostKeyChecking=no ${SERVER_USER}@${ip_address} "sudo docker login -u ${DOCKER_USER_NAME} -p ${DOCKERHUB_PWD}"
                            ssh -i %SSH_KEY_FILE% -o StrictHostKeyChecking=no ${SERVER_USER}@${ip_address} "sudo docker pull ${IMAGE_NAME}"
                            ssh -i %SSH_KEY_FILE% -o StrictHostKeyChecking=no ${SERVER_USER}@${ip_address} "sudo docker container rm -f test_pipeline || true"
                            ssh -i %SSH_KEY_FILE% -o StrictHostKeyChecking=no ${SERVER_USER}@${ip_address} "sudo docker run -d -p 8080:8080 --name test_pipeline ${IMAGE_NAME}"
                        """
                    }
                }
            }
        }
    }
}
