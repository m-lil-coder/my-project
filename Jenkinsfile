pipeline {
    agent any

    environment {
        // Docker credentials and image details
        DOCKER_IMAGE = 'tanu12docker/hellotanushree'  // Docker Hub image name
        DOCKER_TAG = '1.0.0'  // Docker image tag
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds'  // Jenkins credential ID for Docker Hub
        K8S_CONTEXT = 'k8s-cluster-context'  // Kubernetes context
        HELM_RELEASE_NAME = 'hellotanushree'  // Helm release name
        HELM_NAMESPACE = 'default'  // Kubernetes namespace
        CHART_DIR = './charts/hellotanushree'  // Path to Helm chart directory
        VALUES_FILE = './charts/hellotanushree/values.yaml'  // Path to Helm values.yaml
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                // Checkout the code from GitHub repository
                git 'https://github.com/yourusername/your-repository.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image from Dockerfile
                    echo "Building Docker image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    // Log in to Docker Hub using Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                    }
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Push the Docker image to Docker Hub
                    echo "Pushing Docker image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy to Kubernetes using Helm') {
            steps {
                script {
                    // Pull the Docker image securely from Docker Hub using credentials
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                    }

                    // Update the values.yaml file with the latest Docker image
                    sh """
                    sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${DOCKER_TAG}|g' ${VALUES_FILE}
                    """

                    // Deploy the application using Helm with updated values
                    sh """
                    helm upgrade --install ${HELM_RELEASE_NAME} ${CHART_DIR} \
                    --namespace ${HELM_NAMESPACE} \
                    --values ${VALUES_FILE}
                    """
                }
            }
        }

        stage('Verify Helm Deployment') {
            steps {
                script {
                    // Verify the deployment using Helm
                    sh """
                    kubectl rollout status deployment/${HELM_RELEASE_NAME} -n ${HELM_NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
