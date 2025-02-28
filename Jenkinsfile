pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tanu12docker/my-project:latest"
        DOCKER_CREDENTIALS = 'DOCKER_CREDENTIALS_ID'
        GITHUB_CREDENTIALS = 'git-new-PAT1'
        HELM_RELEASE_NAME = 'my-project-release'
        HELM_NAMESPACE = 'kube-system'
        HELM_CHART_DIR = 'helm-project'  // Directory of helm chart within the repo.
        KUBE_CONFIG_CREDENTIALS = 'kube-credentials'  // credential id for kubeconfig file.
        KUBECONFIG = '/var/lib/jenkins/.kube/config'  // Set KUBECONFIG environment variable globally
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    // Use withCredentials to inject secrets securely into environment variables
                    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.GITHUB_CREDENTIALS, usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_TOKEN']]) {
                        // Instead of using Groovy string interpolation, use environment variables securely
                        def gitUrl = "https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/m-lil-coder/my-project.git"
                        // Perform Git Checkout using the secure credentials
                        git url: gitUrl, branch: 'main'
                    }
                }
            }
        }

        stage('Check Workspace') {
            steps {
                sh 'ls -la'  // This will show the files in the workspace
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

        stage('Deploy to Kubernetes with Helm') {
            steps {
                script {
                    // Retrieve the kubeconfig from Jenkins credentials securely
                    withCredentials([string(credentialsId: env.KUBE_CONFIG_CREDENTIALS, variable: 'KUBE_CONFIG_CONTENT')]) {
                        // Write the kubeconfig content securely to a file
                        writeFile file: 'kubeconfig', text: KUBE_CONFIG_CONTENT

                        // Set the KUBECONFIG environment variable to the kubeconfig file location
                        sh 'export KUBECONFIG=$PWD/kubeconfig'
                        sh "aws eks update-kubeconfig --name my-cluster"
                        // Deploy to Kubernetes using Helm
                        sh """
                        helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_DIR} \
                        --namespace ${HELM_NAMESPACE} \
                        --set image.repository=${DOCKER_IMAGE.split(':')[0]},image.tag=${DOCKER_IMAGE.split(':')[1]}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            // Cleanup: remove the Docker image after the build is finished
            sh 'docker rmi $DOCKER_IMAGE'
        }
    }
}
