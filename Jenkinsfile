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
        stage('Check Infra Changes') {
            steps {
                script {
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/DavePhil/sample_devops_project_infra.git']])

                    def changesDetected = bat(script: 'git diff --exit-code', returnStatus: true)

                    if (changesDetected != 0) {
                        echo "Changes detected in infrastructure repository"
                        currentBuild.result = 'SUCCESS'
                    } else {
                        echo "No changes detected in infrastructure repository"
                        currentBuild.result = 'FAILURE'
                    }
                }
            }
        }
        stage('Deploy Infrastructure') {
            steps {
                script {
//                     if (currentBuild.result == 'SUCCESS') {
                        withCredentials([file(credentialsId: 'ssh_key_file', variable: 'SSH_KEY_FILE')]) {
                            bat """
                                copy %SSH_KEY_FILE% my-ssh-key.pem
                            """
                        }

                        bat 'powershell.exe -Command "typeperf \\"\\Processor(_Total)\\\\% Processor Time\\" \\"\\Memory\\\\Available MBytes\\" -sc 1 >> resources_before.csv"'

                        withCredentials([string(credentialsId: 'DockerhubPwd', variable: 'DockerhubPwd')]) {
                            checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/DavePhil/sample_devops_project_infra.git']])
                            bat """
                                cd terraform
                                terraform init
                                terraform apply -auto-approve \
                                    -var="aws_access_key_id=%AWS_ACCESS_KEY_ID%" \
                                    -var="aws_secret_access_key=%AWS_SECRET_ACCESS_KEY%" \
                                    -var="docker_user_name=%DOCKER_USER_NAME%" \
                                    -var="dockerhub_pwd=%DockerhubPwd%" \
                                    -var="image_name=%IMAGE_NAME%"
                                terraform output -raw instance_ip > server_ip.txt
                            """
                        }

                        bat 'typeperf "\\Processor(_Total)\\% Processor Time" "\\Memory\\Available MBytes" -sc 1 >> resources_after.csv'

                         archiveArtifacts artifacts: 'resources_before.csv, resources_after.csv', fingerprint: true

//                     } else {
//                         echo "Deploy infrastructure skipped due to previous failure"
//                     }
                }
            }
        }

//         stage('Run the image') {
//             steps {
//                 script {
//                     bat '''
//                         cd terraform
//                     '''
//                     def address = bat(script: 'type "terraform\\server_ip.txt"', returnStdout: true).trim()
//                     def ip_address = address.split('\r?\n')[-1]
//                     echo "L'adresse IP lue est : ${ip_address}"
//                     withCredentials([string(credentialsId: 'DockerhubPwd', variable: 'DockerhubPwd')]) {
//                        sshCommand remote: [
//                             name: 'MyRemoteServer',
//                            host: ip_address,
//                            user: "${SERVER_USER}",
//                            credentialsId: 'ssh_key',
//                            allowAnyHosts: false
//                        ], command: """
//                            sudo docker login -u ${DOCKER_USER_NAME} -p ${DockerhubPwd}
//                            sudo docker pull ${IMAGE_NAME}
//                            sudo docker container rm -f test_pipeline || true
//                            sudo docker run -d -p 8080:8080 --name test_pipeline ${IMAGE_NAME}
//                        """
//                    }
//                 }
//             }
//         }

    }
}
