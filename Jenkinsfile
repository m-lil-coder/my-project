pipeline {
    agent any

    environment {
        FRONTEND_DOCKER_IMAGE = "tanu12docker/frontend:latest"
        BACKEND_DOCKER_IMAGE = "tanu12docker/backend:latest"
        DOCKER_CREDENTIALS = 'DOCKER_CREDENTIALS_ID'
        GITHUB_CREDENTIALS = 'jenkins-new'
        HELM_RELEASE_NAME = 'my-project-release'
        HELM_NAMESPACE = 'kube-system'
        HELM_CHART_DIR = 'helm-project'
        KUBE_CONFIG_CREDENTIALS = 'kube-credentials'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.GITHUB_CREDENTIALS, usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_TOKEN']]) {
                        def gitUrl = "https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/m-lil-coder/my-project.git"
                        git url: gitUrl, branch: 'main'
                    }
                }
            }
        }

        stage('Check Workspace') {
            steps {
                sh 'ls -la' // This will show the files in the workspace
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    // Build frontend Docker image
                    sh 'docker build -f Frontend/Dockerfile -t $FRONTEND_DOCKER_IMAGE Frontend/'

                    // Build backend Docker image
                    sh 'docker build -f backend/Dockerfile -t $BACKEND_DOCKER_IMAGE backend/'
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

        stage('Push Docker Images to Docker Hub') {
            steps {
                script {
                    // Push frontend image to Docker Hub
                    sh 'docker push $FRONTEND_DOCKER_IMAGE'

                    // Push backend image to Docker Hub
                    sh 'docker push $BACKEND_DOCKER_IMAGE'
                }
            }
        }

        stage('Deploy to Kubernetes with Helm') {
            steps {
                script {
                    // Set AWS credentials for authentication
                    withCredentials([string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            export AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID
                            export AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY
                            aws configure set aws_access_key_id \$AWS_ACCESS_KEY_ID
                            aws configure set aws_secret_access_key \$AWS_SECRET_ACCESS_KEY
                            aws configure set region us-east-1
                            aws eks update-kubeconfig --name my-cluster
                        """
                    }

                    // Helm deployment
                    sh """
                        cd ${HELM_CHART_DIR}
                        helm upgrade -i ${HELM_RELEASE_NAME} . \\
                        --set image.frontendTag="latest" \\
                        --set image.backendTag="latest" \\
                        --set ingress.host.name=tanushree.online \\
                        -n ${HELM_NAMESPACE} --create-namespace
                    """
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    // If you have a docker-compose.yml file, deploy using Docker Compose for local testing
                    sh 'docker-compose -f docker-compose.yml up -d'
                }
            }
        }
    }

    post {
        always {
            // Clean up images after build and push
            sh 'docker rmi $FRONTEND_DOCKER_IMAGE $BACKEND_DOCKER_IMAGE'
        }
    }
}
