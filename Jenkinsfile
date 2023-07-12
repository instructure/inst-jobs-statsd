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
                // Re-enable Rubocop after upgrading and resolving offenses.
                // sh 'docker-compose run --rm test /bin/bash -lc "rvm-exec 2.7 bundle exec rubocop --fail-level autocorrect"'
                sh 'docker-compose run --name coverage app'
            }

            post {
                always {
                    sh 'docker cp coverage:/app/coverage .'
                    sh 'docker-compose down --rmi=all --volumes --remove-orphans'

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
    }
}
