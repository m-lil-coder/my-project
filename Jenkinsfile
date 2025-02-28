pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "tanu12docker/my-project:latest"
        DOCKER_CREDENTIALS = 'DOCKER_CREDENTIALS_ID'
        GITHUB_CREDENTIALS = 'git-new-PAT1'
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

        stage('Add Helm Repositories') {
            steps {
                script {
                    // Add the AWS EKS Helm chart repository and update the local repo cache
                    sh 'helm repo add eks https://aws.github.io/eks-charts'
                    sh 'helm repo update'
                }
            }
        }

        stage('Deploy to Kubernetes with Helm') {
            steps {
                script {
                    withCredentials([string(credentialsId: env.KUBE_CONFIG_CREDENTIALS, variable: 'KUBE_CONFIG_CONTENT'),
                                     string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),  
                                     string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {  
                        writeFile file: 'kubeconfig', text: KUBE_CONFIG_CONTENT
                        sh 'export KUBECONFIG=$PWD/kubeconfig'

                        // Set AWS credentials for authentication
                        sh """
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        aws configure set region us-east-1  
                        aws eks update-kubeconfig --name my-cluster  
                        """

                        // Deploy to Kubernetes using Helm
                        sh """
                            helm upgrade --install ${HELM_RELEASE_NAME} ${HELM_CHART_DIR} \
                            --namespace ${HELM_NAMESPACE} \
                            --set image.repository=${DOCKER_IMAGE.split(':')[0]},image.tag=${DOCKER_IMAGE.split(':')[1]}

                            # Deploy AWS Load Balancer Controller
                            helm upgrade --install my-project-release eks/aws-load-balancer-controller \
                            --namespace kube-system \
                            --set clusterName=my-cluster \
                            --set region=us-east-1 \
                            --set serviceAccount.create=false \
                            --set serviceAccount.name=aws-load-balancer-controller \
                            --set ingress.enabled=true \
                            --set ingress.hostname=tanushree.online \
                            --set ingress.port=80 \
                            --values ${HELM_CHART_DIR}/values.yaml

                            # Apply the updated ingress values from the GitHub repo (assuming the values.yaml is part of the repo)
                            helm upgrade --install my-ingress-release ${HELM_CHART_DIR} \
                            --namespace ${HELM_NAMESPACE} \
                            -f ${HELM_CHART_DIR}/values.yaml \
                            -f ${HELM_CHART_DIR}/ingress.yaml  # Assuming your ingress.yaml file is in the repo directory
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
