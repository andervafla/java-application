pipeline {
    agent any

    environment {
        GITHUB_REPO = 'https://github.com/andervafla/java_deploy.git'
        TERRAFORM_DIR = 'terraformAWS'
    }

    stages {
        stage('Print Hello World') {
            steps {
                echo 'Hello, World!'
            }
        }

        stage('Checkout from Git') {
            steps {
                // Клонування з параметром clean
                checkout([$class: 'GitSCM', 
                    branches: [[name: 'main']], 
                    userRemoteConfigs: [[url: "${GITHUB_REPO}"]],
                    extensions: [[$class: 'CleanBeforeCheckout']]
                ])
            }
        }

        stage('List Files in Root Directory') {
            steps {
                sh 'ls -la'
            }
        }

        stage('List Files in Terraform Directory') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh 'ls -la' 
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    script {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        terraform apply -auto-approve
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check the logs.'
        }
    }
}
