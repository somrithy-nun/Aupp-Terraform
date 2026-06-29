pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Version Check') {
            steps {
                sh 'terraform version'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Plan') {
            steps {
                sh '''
                    terraform plan \
                    -var-file=terraform.tfvars \
                    -out=tfplan
                '''
            }
        }

        stage('Apply') {
            steps {
                echo "Apply enabled"
                // sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
