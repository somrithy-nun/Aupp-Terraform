pipeline {
    agent {
        docker {
            image 'terraform-awscli:terraform-1.7.5-awscli-2.15.22'
            args '--entrypoint=""'
        }
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    parameters {
        choice(name: 'TF_ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action to run.')
    }

    environment {
        TERRAFORM_VERSION = '1.7.5'
        AWS_CLI_VERSION = '2.15.22'
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Tool Versions') {
            steps {
                sh '''
                    set -eux

                    terraform version
                    aws --version

                    terraform version -json | grep "\\"terraform_version\\":\\"${TERRAFORM_VERSION}\\""
                    aws --version 2>&1 | grep "aws-cli/${AWS_CLI_VERSION}"
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    set -eux

                    terraform init -input=false
                '''
            }
        }

        stage('Terraform Format') {
            steps {
                sh '''
                    set -eux

                    terraform fmt -check
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    set -eux

                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            when {
                anyOf {
                    expression { params.TF_ACTION == 'plan' }
                    expression { params.TF_ACTION == 'apply' }
                }
            }
            steps {
                sh '''
                    set -eux

                    terraform plan -input=false -out=tfplan
                '''
            }
        }

        stage('Approve Apply') {
            agent none
            when {
                expression { params.TF_ACTION == 'apply' }
            }
            steps {
                input message: 'Apply this Terraform plan to AWS?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.TF_ACTION == 'apply' }
            }
            steps {
                sh '''
                    set -eux

                    terraform apply -input=false -auto-approve tfplan
                '''
            }
        }

        stage('Approve Destroy') {
            agent none
            when {
                expression { params.TF_ACTION == 'destroy' }
            }
            steps {
                input message: 'Destroy the Terraform-managed AWS infrastructure?', ok: 'Destroy'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.TF_ACTION == 'destroy' }
            }
            steps {
                sh '''
                    set -eux

                    terraform destroy -input=false -auto-approve
                '''
            }
        }
    }

    post {
        success {
            echo "Terraform deployment SUCCESS"
        }

        failure {
            echo "Terraform deployment FAILED"
        }

        always {
            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
        }
    }
}
