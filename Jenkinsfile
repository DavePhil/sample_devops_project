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
                    withCredentials([file(credentialsId: 'my-ssh-key', variable: 'SSH_KEY_FILE')]) {
                        bat '''
                            copy %SSH_KEY_FILE% my-ssh-key.pem
                        '''
                    }
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/DavePhil/sample_devops_project_infra.git']])
                    bat '''
                        cd terraform
                        terraform init
                        terraform apply -auto-approve -var="aws_access_key_id=%AWS_ACCESS_KEY_ID%" -var="aws_secret_access_key=%AWS_SECRET_ACCESS_KEY%"
                    '''
                    def serverIp = bat(script: '''
                        cd terraform
                        terraform output -raw instance_ip
                    ''', returnStdout: true).trim()
                    echo "Server IP: ${serverIp}"
                    env.SERVER_IP = serverIp
                }
            }
        }
        stage('Run the image') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'DockerhubPwd', variable: 'DOCKERHUB_PWD'),
                        file(credentialsId: 'my-ssh-key', variable: 'SSH_KEY_FILE')
                    ]) {
                        bat """
                            echo "Server IP: ${env.SERVER_IP}"
                            copy %SSH_KEY_FILE% my-ssh-key.pem
                            ssh -i my-ssh-key.pem -o StrictHostKeyChecking=no ${SERVER_USER}@${env.SERVER_IP} "sudo docker login -u ${DOCKER_USER_NAME} -p ${DOCKERHUB_PWD}"
                            ssh -i my-ssh-key.pem -o StrictHostKeyChecking=no ${SERVER_USER}@${env.SERVER_IP} "sudo docker pull ${IMAGE_NAME}"
                            ssh -i my-ssh-key.pem -o StrictHostKeyChecking=no ${SERVER_USER}@${env.SERVER_IP} "sudo docker container rm -f test_pipeline || true"
                            ssh -i my-ssh-key.pem -o StrictHostKeyChecking=no ${SERVER_USER}@${env.SERVER_IP} "sudo docker run -d -p 8080:8080 --name test_pipeline ${IMAGE_NAME}"
                        """
                    }
                }
            }
        }
    }
}
