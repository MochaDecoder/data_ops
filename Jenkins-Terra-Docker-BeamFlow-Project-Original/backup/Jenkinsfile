pipeline {
    agent any

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout') {
            steps {
                // Pull latest code from the repository
                checkout scm
            }
        }
        //stage('Clean Workspace') {
        //    steps {
        //        cleanWs()
        //    }
        //}
        stage('Run Tests') {
            steps {
                // Show the current directory
                sh 'pwd'
                // List the files in the test/ directory
                sh 'ls -la test/'
                // Run the tests using pytest
                sh 'pytest test/'
            }
        }

        stage('Prepare for Deploy') {
            steps {
                // Copy the test module to the main project directory and rename
                // sh 'cp test/test_cleanse_data_module.py your_project_name/cleanse_data_module.py'
                sh 'echo "===== test pass ====="'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Login to DockerHub
                withCredentials([usernamePassword(credentialsId: 'dockerhub_credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                }

                // Build the Docker image
                sh 'docker build -t thaibigdata/cicd_for_realtime_data_pipeline:latest .'
                
                // Push the Docker image to your registry
                sh 'docker push thaibigdata/cicd_for_realtime_data_pipeline:latest'
            }
        }
    }

    post {
        success {
            echo 'All stages completed successfully!'
        }
        failure {
            echo 'Something went wrong!'
        }
    }
}
