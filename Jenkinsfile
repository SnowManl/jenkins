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
                script {
                    sh """
                        rm -f public/logo.svg
                        cp public/logo-${env.BRANCH_NAME}.svg public/logo.svg
                    """
                }
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
                script {
                    sh "docker build -t ${DOCKER_HUB}/${CONTAINER_NAME}:${IMAGE_TAG} ."
                }
            }
        }
        stage('Scan Docker Image') {
            steps {
                script {
                    sh "trivy image --exit-code 0 --severity HIGH,MEDIUM,LOW --no-progress ${DOCKER_HUB}/${CONTAINER_NAME}:${IMAGE_TAG}"
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PWD'
                    )]) {
                        sh "docker login -u $DOCKER_USER -p $DOCKER_PWD"
                        sh "docker push ${DOCKER_HUB}/${CONTAINER_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"
                    sh "docker run -d -p ${PORT}:${PORT} --name ${CONTAINER_NAME} ${DOCKER_HUB}/${CONTAINER_NAME}:${IMAGE_TAG}"
                }
            }
        }
        stage('Trigger Deployment Pipeline') {
            steps {
                script {
                    build job: "CD_deploy_${env.BRANCH_NAME}", wait: false
                }
            }
        }
    }
}
