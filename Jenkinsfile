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
                    terraform init -input=false -no-color
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    terraform plan \
                    -input=false \
                    -no-color \
                    -out=tfplan
                '''
            }
        }

        stage('Approval') {
            steps {
                input message: "Do you want to apply Terraform changes?"
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
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
