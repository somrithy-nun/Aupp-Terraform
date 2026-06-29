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
        REPO_URL          = 'https://github.com/somrithy-nun/app-x-terraform.git'
        EC2_KEY_PAIR_NAME = 'vockey'
        EC2_USER          = 'ec2-user'
        APP_URL_FILE      = '/tmp/app_url.txt'
    }

    parameters {
        booleanParam(
            name: 'REPLACE_EC2_INSTANCE',
            defaultValue: false,
            description: 'Delete and recreate only aws_instance.web. Use this when you need the instance relaunched with the vockey key pair.'
        )
    }

    stages {
        stage('Checkout Code') {
            steps { checkout scm }
        }

        stage('Install Tools') {
            steps {
                sh 'apk add --no-cache aws-cli curl openssh-client'
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

                        aws sts get-caller-identity

                        terraform init     -input=false
                        terraform validate

                        if [ "${REPLACE_EC2_INSTANCE}" = "true" ]; then
                            terraform plan -input=false -var="key_pair_name=$EC2_KEY_PAIR_NAME" -replace="aws_instance.web" -out=tfplan
                        else
                            terraform plan -input=false -var="key_pair_name=$EC2_KEY_PAIR_NAME" -out=tfplan
                        fi

                        terraform apply    -input=false -auto-approve tfplan

                        terraform output -raw public_ip  > /tmp/ec2_ip.txt
                        terraform output -raw website_url > $APP_URL_FILE
                        echo "EC2 IP: $(cat /tmp/ec2_ip.txt)"
                        echo "App URL: $(cat $APP_URL_FILE)"
                    '''
                }
            }
        }

        stage('Verify EC2 Deploy') {
            steps {
                withCredentials([
                    file(credentialsId: 'vockey', variable: 'SSH_KEY_FILE')
                ]) {
                    sh '''
                        set -eux

                        EC2_IP=$(cat /tmp/ec2_ip.txt)
                        APP_URL=$(cat $APP_URL_FILE)

                        # Copy & fix permission of the .pem file
                        cp "$SSH_KEY_FILE" /tmp/labsuser.pem
                        chmod 600 /tmp/labsuser.pem

                        SSH_OPTS="-i /tmp/labsuser.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30"

                        # Wait for EC2 to accept SSH with the key pair Terraform attached.
                        echo "Waiting for EC2 to be ready..."
                        CONNECTED=false
                        for i in $(seq 1 15); do
                            if ssh $SSH_OPTS $EC2_USER@$EC2_IP "echo connected"; then
                                CONNECTED=true
                                break
                            fi
                            echo "Attempt $i failed, retrying in 15s..."
                            sleep 15
                        done

                        if [ "$CONNECTED" != "true" ]; then
                            echo "SSH failed. Make sure Terraform launched this instance with key_pair_name=$EC2_KEY_PAIR_NAME."
                            exit 1
                        fi

                        # Terraform user_data performs the install/build/run. SSH is only for diagnostics.
                        ssh $SSH_OPTS $EC2_USER@$EC2_IP << 'ENDSSH'
set -eux

if ! sudo cloud-init status --wait; then
    sudo tail -200 /var/log/cloud-init-output.log || true
    sudo tail -200 /var/log/user-data.log || true
    exit 1
fi

sudo systemctl status docker --no-pager
sudo docker ps --filter "name=terraform-docker-app"
sudo docker logs --tail=80 terraform-docker-app || true
curl -fsS http://localhost/
ENDSSH

                        echo "Waiting for app HTTP endpoint..."
                        for i in $(seq 1 20); do
                            if curl -fsS "$APP_URL" >/dev/null; then
                                echo "App deployed at $APP_URL"
                                exit 0
                            fi
                            echo "HTTP attempt $i failed, retrying in 10s..."
                            sleep 10
                        done

                        echo "App did not become reachable at $APP_URL"
                        exit 1
                    '''
                }
            }
        }
    }

    post {
        always { archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true }
        success { echo "Deployment SUCCESS" }
        failure { echo "Deployment FAILED" }
    }
}
