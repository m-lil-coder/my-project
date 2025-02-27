pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tanu12docker/my-project:latest"
        DOCKER_CREDENTIALS = 'DOCKER_CREDENTIALS_ID'
        GITHUB_CREDENTIALS = 'git-new-PAT1' // Correct credential ID here
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    // Use credentials binding to securely access the token
                    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.GITHUB_CREDENTIALS, usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_TOKEN']]) {
                        def gitUrl = "https://${GIT_TOKEN}@github.com/m-lil-coder/my-project.git"
                        git url: gitUrl, branch: 'main'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
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
                sh 'docker push $DOCKER_IMAGE'
            }
        }
    }

    post {
        always {
            sh 'docker rmi $DOCKER_IMAGE'
        }
    }
}
