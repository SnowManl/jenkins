pipeline {
    agent any
    environment {
        DOCKER_HUB = "snowmanf"
        PORT = "${env.BRANCH_NAME == 'main' ? '3000' : '3001'}"
        CONTAINER_NAME = "${env.BRANCH_NAME == 'main' ? 'nodemain' : 'nodedev'}"
        IMAGE_TAG = "v1.0"
        START_SCRIPT = "${env.BRANCH_NAME == 'main' ? 'start:prod' : 'start:dev'}"  // Added
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
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PWD'
                    )]) {
                        sh """
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                            docker login -u $DOCKER_USER -p $DOCKER_PWD
                            docker run -d -p ${PORT}:${PORT} -e PORT=${PORT} \
                                --name ${CONTAINER_NAME} \
                                ${DOCKER_HUB}/${CONTAINER_NAME}:${IMAGE_TAG} \
                                npm run ${START_SCRIPT}
                        """
                    }
                }
            }
        }
    }
}
