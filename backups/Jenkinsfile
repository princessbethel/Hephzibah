pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'SonarQubeServer'
        SCANNER_HOME = tool name: 'SonarQubeScanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
        DIGITALOCEAN_TOKEN = credentials('digitalocean_token')
        DIGITALOCEAN_REGION = credentials('digitalocean_region')
        DOCKER_COMPOSE = '/usr/local/bin/docker-compose'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/ogeeDeveloper/TestProject_CICD.git', branch: 'master'
            }
        }

        stage('Build') {
            steps {
                withMaven(maven: 'Maven') {
                    sh 'mvn clean install'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=java-tomcat-sample -Dsonar.sources=src -Dsonar.host.url=${SONARQUBE_ENV} -Dsonar.login=${SONARQUBE_LOGIN}"
                }
            }
        }

        stage('IaC Validation') {
            steps {
                sh '''
                cd terraform
                terraform init
                terraform validate
                '''
            }
        }

        stage('OWASP ZAP Scan') {
            steps {
                sh '''
                docker run -d --name zap -u zap -p 8081:8080 -v $(pwd):/zap/wrk/:rw owasp/zap2docker-stable zap.sh -daemon -port 8080 -config api.disablekey=true
                sleep 15
                docker exec zap zap-cli status -t 120
                docker exec zap zap-cli open-url http://your-application-url
                docker exec zap zap-cli spider http://your-application-url
                docker exec zap zap-cli active-scan --scanners all http://your-application-url
                docker exec zap zap-cli report -o /zap/wrk/zap_report.html -f html
                docker stop zap
                docker rm zap
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([string(credentialsId: 'digitalocean_token', variable: 'DO_TOKEN'),
                                 string(credentialsId: 'digitalocean_region', variable: 'DO_REGION')]) {
                    sh '''
                    cd terraform
                    terraform apply -var "digitalocean_token=${DO_TOKEN}" -var "region=${DO_REGION}" -auto-approve
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh "${DOCKER_COMPOSE} -f ${WORKSPACE}/docker-compose.yml up -d" // Use docker-compose from the repository
            }
        }
    }

    post {
        always {
            echo 'Cleaning up...'
            sh "${DOCKER_COMPOSE} -f ${WORKSPACE}/docker-compose.yml down" // Use docker-compose from the repository
        }
        success {
            emailext subject: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                    body: "Great news! The job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' was successful. \nCheck it out at ${env.BUILD_URL}",
                    to: 'your_email@example.com'
        }
        failure {
            emailext subject: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
                    body: "Unfortunately, the job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' failed. \nCheck it out at ${env.BUILD_URL}",
                    to: 'your_email@example.com'
        }
    }
}
