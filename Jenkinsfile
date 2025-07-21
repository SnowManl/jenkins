pipeline {
    agent any
    environment {
        DOCKER_HUB = "your-dockerhub-username"
        PORT = "${env.BRANCH_NAME == 'main' ? '3000' : '3001'}"
        CONTAINER_NAME = "${env.BRANCH_NAME == 'main' ? 'nodemain' : 'nodedev'}"
        IMAGE_TAG = "v1.0"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh "cp public/logo-${env.BRANCH_NAME}.svg public/logo.svg"
            }
        }
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB}/${CONTAINER_NAME}:${IMAGE_TAG} ."
            }
        }
        stage('Deploy') {
            steps {
                sh "docker stop ${CONTAINER_NAME} || true"
                sh "docker rm ${CONTAINER_NAME} || true"
                sh "docker run -d -p ${PORT}:${PORT} --name ${CONTAINER_NAME} ${DOCKER_HUB}/${CONTAINER_NAME}:${IMAGE_TAG}"
            }
        }
    }
}
