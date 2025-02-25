pipeline {
    agent any

    environment {
        // Docker credentials and image details
        DOCKER_IMAGE = 'tanu12docker/hellotanushree'  // Docker Hub image name
        DOCKER_TAG = '1.0.0'  // Docker image tag
        DOCKER_CREDENTIALS_ID = 'docker-hub-creds'  // Jenkins credential ID for Docker Hub
        K8S_CONTEXT = 'k8s-cluster-context'  // Kubernetes context
        HELM_RELEASE_NAME = 'hellotanushree'  // Helm release name
        HELM_NAMESPACE = 'kube-system'  // Kubernetes namespace
        CHART_DIR = 'helm-project' // Relative path
        VALUES_FILE = 'helm-project/values.yaml' // Relative Path
        GITHUB_CREDENTIALS = 'GITHUB_CREDENTIAL'
    }

//     stage('Checkout Source Code') {
//     steps {
//         script {
//             sshagent([env.GITHUB_CREDENTIALS]) {
//                  sh 'git clone git@github.com:m-lil-coder/my-project.git'
//             }
//         }
//     }
// }

stage('Checkout Source Code') {
    steps {
        script {
            sshagent([env.GITHUB_CREDENTIALS]) {
                // Attempt to connect to GitHub to add its host key to known_hosts
                try {
                    sh 'ssh -T git@github.com -o StrictHostKeyChecking=yes -o UserKnownHostsFile=/dev/null' //This will fail, but add the key.
                } catch (Exception e) {
                    echo "Adding GitHub host key to known_hosts..."
                }

                // Clone the repository
                sh 'git clone git@github.com:m-lil-coder/my-project.git'
            }
        }
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
            sh """
            helm upgrade --install ${HELM_RELEASE_NAME} ${CHART_DIR} \
            --namespace ${HELM_NAMESPACE} \
            --set image.repository=${DOCKER_IMAGE},image.tag=${DOCKER_TAG}
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
