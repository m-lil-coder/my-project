pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = "tanu12docker/my-project:latest"  
        DOCKER_CREDENTIALS = 'DOCKER_CREDENTIALS_ID'  
        GITHUB_CREDENTIALS = 'github-ssh-key'   //changes in file
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    
                    sshagent([env.GITHUB_CREDENTIALS]) {
                        git 'git@github.com:m-lil-coder/my-project.git'
                    }
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
