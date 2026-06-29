pipeline {
    agent {
        docker {
            image 'hashicorp/terraform:1.7.5'
            args '--entrypoint=""'
        }
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Version') {
            steps {
                sh 'terraform version'
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    terraform init
                    terraform plan
                    terraform apply -auto-approve
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Terraform deployment SUCCESS"
        }

        failure {
            echo "❌ Terraform deployment FAILED"
        }

        always {
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
        }
    }
}
