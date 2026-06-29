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
            steps { checkout scm }
        }

        stage('Install AWS CLI') {
            steps {
                sh 'apk add --no-cache aws-cli'
            }
        }

        stage('Validate Tools') {
            steps {
                sh '''
                    terraform version
                    aws --version
                '''
            }
        }

        stage('Terraform Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id',     variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        set -eux

                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

                        aws sts get-caller-identity   # verify credentials work

                        terraform init     -input=false
                        terraform validate
                        terraform plan     -input=false -out=tfplan
                        terraform apply    -input=false -auto-approve tfplan
                    '''
                }
            }
        }
    }

    post {
        always { archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true }
        success { echo "Deployment SUCCESS" }
        failure { echo "Deployment FAILED"  }
    }
}