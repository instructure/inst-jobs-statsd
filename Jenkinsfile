#!/usr/bin/env groovy

pipeline {
    agent {
        label 'docker'
    }

    options {
        ansiColor("xterm")
        buildDiscarder(logRotator(numToKeepStr: '50'))
        timeout(time: 20, unit: 'MINUTES')
    }

    stages {
        stage('Build') {
            steps {
                sh 'docker-compose down --rmi=all --volumes --remove-orphans'
                sh 'docker-compose build --pull'
            }
        }

        stage('Test') {
            steps {
                sh 'docker-compose run --rm app /bin/bash -lc "rvm-exec 3.2.0 bin/rubocop"'
                sh 'docker-compose run --name coverage app'
            }

            post {
                always {
                    sh 'docker cp coverage:/app/coverage .'

                    publishHTML target: [
                      allowMissing: false,
                      alwaysLinkToLastBuild: false,
                      keepAll: true,
                      reportDir: 'coverage',
                      reportFiles: 'index.html',
                      reportName: 'Coverage Report'
                    ]
                }
            }
        }

        stage('Publish') {
            when {
                allOf {
                expression { GERRIT_BRANCH == "main" }
                environment name: "GERRIT_EVENT_TYPE", value: "change-merged"
                }
            }
            steps {
                withCredentials([string(credentialsId: 'rubygems-rw', variable: 'GEM_HOST_API_KEY')]) {
                    sh 'docker run -e GEM_HOST_API_KEY --rm inst-jobs-statsd_app /bin/bash -lc "./bin/publish.sh"'
                }
            }
        }
    }

    post {
        always {
            sh 'docker-compose down --rmi=all --volumes --remove-orphans'
        }
    }
}
