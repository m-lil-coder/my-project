pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "tanu12docker/my-project:latest"  
        DOCKER_CREDENTIALS = 'DOCKER_CREDENTIALS_ID'  
        GITHUB_TOKEN = credentials('git-new-PAT1')  // Define PAT credentials ID here
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    // Use the GitHub repository URL with the Personal Access Token
                    def gitUrl = "https://$GITHUB_TOKEN@github.com/m-lil-coder/my-project.git"
                    git url: gitUrl, branch: 'main'  // Adjust branch if needed
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_IMAGE .'
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }
    }

    post {
        always { 
            sh 'docker rmi $DOCKER_IMAGE'
        }
    }
}
