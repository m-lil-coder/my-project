pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "mylilcoder/my-project:latest"  // Docker image name you want to push to Docker Hub
        DOCKER_CREDENTIALS = 'docker-hub-credentials'  // Docker Hub credentials ID in Jenkins
        GITHUB_CREDENTIALS = 'github-ssh-key'  // GitHub SSH credentials ID
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    // Checkout code from GitHub using SSH credentials
                    sshagent([env.GITHUB_CREDENTIALS]) {
                        git 'git@github.com:m-lil-coder/my-project.git'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image from Dockerfile and tag it with the DOCKER_IMAGE tag
                    sh 'docker build -t $DOCKER_IMAGE .'
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    // Log in to Docker Hub using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Push the newly built Docker image to Docker Hub
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }
    }

    post {
        always {
            // Clean up, remove the image after pushing
            sh 'docker rmi $DOCKER_IMAGE'
        }
    }
}
