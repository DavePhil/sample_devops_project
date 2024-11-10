pipeline {
    agent any
    tools {
        maven 'Maven3'
    }
    environment {
        APP_NAME = "devops-test"
        DOCKER_USER_NAME = "davechedjoun"
        IMAGE_NAME = "${DOCKER_USER_NAME}" + "/" + "${APP_NAME}"
        CONTAINER_NAME = "${BUILD_NUMBER}"
    }
    stages{
        stage('Build Project') {
            steps {
                checkout scmGit(branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/DavePhil/sample_devops_project']])
                bat 'mvn -B -DskipTests clean install'
            }
        }
        stage('Test') {
            steps {
                bat 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Build Docker'){
            steps {
                bat "docker build -t ${IMAGE_NAME} ."
            }
        }
        stage('Deploy to Docker Hub'){
            steps {
               script{
                   withCredentials([string(credentialsId: 'DockerhubPwd', variable: 'DockerhubPwd')]) {
                       bat "docker login -u ${DOCKER_USER_NAME} -p ${DockerhubPwd}"
                    }
                    bat "docker push ${IMAGE_NAME}"
               }
            }
        }
        stage('Run the image'){
            steps{
                script{
                    bat "docker container rm -f test_pipeline || true"
                    bat "docker run -d -p 8081:8081 --name test_pipeline  ${IMAGE_NAME}"
                }
            }
        }
    }
}