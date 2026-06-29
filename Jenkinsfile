pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:1.7.5'
            args '--entrypoint="" -u root'
        }
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION  = 'true'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Install AWS CLI') {
            steps {
                sh '''
                    set -eux
                    apk add --no-cache aws-cli   # terraform image is Alpine-based
                '''
            }
        }

        stage('Tool Versions') {
            steps {
                sh '''
                    terraform version
                    aws --version
                '''
            }
        }

        stage('Terraform Deploy') {
            steps {
                sh '''
                    set -eux
                    terraform init  -input=false
                    terraform validate
                    terraform plan  -input=false -out=tfplan
                    terraform apply -input=false -auto-approve tfplan
                '''
            }
        }
    }

    post {
        always { archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true }
        success { echo "Deployment SUCCESS" }
        failure { echo "Deployment FAILED"  }
    }
}