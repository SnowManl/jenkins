pipeline {
    agent any
    tools {
        nodejs 'node'  // Matches Global Tools configuration
    }
    stages {
        stage('Checkout SCM') {
            steps { checkout scm }
        }
        stage('Build') {
            steps { sh 'npm install' }
        }
        stage('Test') {
            steps { sh 'npm test' }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def imageName = (env.BRANCH_NAME == 'main') ? 
                        "nodemain:${env.BUILD_ID}" : 
                        "nodedev:${env.BUILD_ID}"
                    docker.build(imageName)
                }
            }
        }
        stage('Scan Docker Image') {
            steps {
                script {
                    def imageName = (env.BRANCH_NAME == 'main') ? 
                        "nodemain:${env.BUILD_ID}" : 
                        "nodedev:${env.BUILD_ID}"
                    sh "trivy image --exit-code 0 --severity HIGH,MEDIUM,LOW --no-progress ${imageName}"
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    def port = (env.BRANCH_NAME == 'main') ? "3000" : "3001"
                    def containerName = (env.BRANCH_NAME == 'main') ? "nodemain" : "nodedev"
                    sh "docker stop ${containerName} || true"
                    sh "docker rm ${containerName} || true"
                    sh "docker run -d -p ${port}:${port} --name ${containerName} ${imageName}"
                }
            }
        }
    }
}
