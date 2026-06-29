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
        APP_DIR           = '/home/ubuntu/app'
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
                sh 'apk add --no-cache aws-cli openssh-client'
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
                            terraform plan -input=false -replace="aws_instance.web" -out=tfplan
                        else
                            terraform plan -input=false -out=tfplan
                        fi

                        terraform apply    -input=false -auto-approve tfplan

                    '''
                }
            }
        }

        stage('Setup EC2 & Deploy') {
            steps {
                withCredentials([
                    // ── This is how you use Secret File type ──
                    file(credentialsId: 'vockey', variable: 'SSH_KEY_FILE'),
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        set -eux

                        EC2_IP=$(cat /tmp/ec2_ip.txt)

                        # Copy & fix permission of the .pem file
                        cp $SSH_KEY_FILE /tmp/labsuser.pem
                        chmod 600 /tmp/labsuser.pem

                        SSH_OPTS="-i /tmp/labsuser.pem -o StrictHostKeyChecking=no -o ConnectTimeout=30"

                        # ── Wait for EC2 to be SSH-ready ──────────────────────────
                        echo "Waiting for EC2 to be ready..."
                        for i in $(seq 1 15); do
                            ssh $SSH_OPTS ubuntu@$EC2_IP "echo connected" && break
                            echo "Attempt $i failed, retrying in 15s..."
                            sleep 15
                        done

                        # ── Run everything on EC2 ─────────────────────────────────
                        ssh $SSH_OPTS ubuntu@$EC2_IP << ENDSSH
                            set -eux

                            # 1. Install Docker
                            sudo apt-get update -y
                            sudo apt-get install -y ca-certificates curl gnupg

                            sudo install -m 0755 -d /etc/apt/keyrings
                            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                            sudo chmod a+r /etc/apt/keyrings/docker.gpg

                            echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | \
                                sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

                            sudo apt-get update -y
                            sudo apt-get install -y docker-ce docker-ce-cli containerd.io

                            sudo systemctl enable docker
                            sudo systemctl start docker
                            sudo usermod -aG docker ubuntu
                            newgrp docker

                            # 2. Clone or pull the repo
                            if [ -d "/home/ubuntu/app" ]; then
                                echo "Repo exists, pulling latest..."
                                cd /home/ubuntu/app && git pull
                            else
                                git clone $REPO_URL /home/ubuntu/app
                            fi

                            cd /home/ubuntu/app

                            # 3. Stop existing container if running
                            sudo docker stop myapp 2>/dev/null || true
                            sudo docker rm   myapp 2>/dev/null || true

                            # 4. Build Docker image
                            sudo docker build -t myapp .

                            # 5. Run container on port 3000
                            sudo docker run -d \
                                --name myapp \
                                --restart always \
                                -p 3000:3000 \
                                myapp

                            echo "App is running!"
                        ENDSSH

                        echo "✅ App deployed at http://$EC2_IP:3000"
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
