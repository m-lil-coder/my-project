pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tanu12docker/my-project:latest"
        DOCKER_CREDENTIALS = 'DOCKER_CREDENTIALS_ID'
        GITHUB_CREDENTIALS = 'git-new-PAT1'
        HELM_RELEASE_NAME = 'my-project-release'
        HELM_NAMESPACE = 'kube-system'
        HELM_CHART_DIR = 'helm-project' // Directory of helm chart within the repo.
        KUBE_CONFIG_CREDENTIALS = 'kube-credentials' // credential id for kubeconfig file.
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                script {
                    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.GITHUB_CREDENTIALS, usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_TOKEN']]) {
                        def gitUrl = "https://${GIT_TOKEN}@github.com/m-lil-coder/my-project.git"
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
                    withCredentials([string(credentialsId: env.KUBE_CONFIG_CREDENTIALS, variable: 'KUBE_CONFIG_CONTENT')]) {
                        writeFile file: 'kubeconfig', text: "${KUBE_CONFIG_CONTENT}"
                        sh 'export KUBECONFIG=$PWD/kubeconfig'
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
            sh 'docker rmi $DOCKER_IMAGE'
        }
    }
}
